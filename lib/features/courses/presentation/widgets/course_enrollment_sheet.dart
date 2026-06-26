import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_assets.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_strings.dart';
import 'package:mrmichaelashrafdashboard/core/enums/enrollment_status.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/currency_formatter.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/firebase_error_messages.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course_enrollment.dart';
import 'package:mrmichaelashrafdashboard/features/courses/logic/courses_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/users/logic/users_cubit.dart';
import 'package:mrmichaelashrafdashboard/shared/dialogs/app_dialog.dart';

class CourseEnrollmentSheet extends StatefulWidget {
  final Course course;
  const CourseEnrollmentSheet({super.key, required this.course});

  @override
  State<CourseEnrollmentSheet> createState() => _CourseEnrollmentsSheetState();
}

class _CourseEnrollmentsSheetState extends State<CourseEnrollmentSheet> {
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  /// The enrollment whose confirm / reject / cancel action is in flight — only
  /// that tile shows a spinner and disables its buttons.
  String? _busyId;

  List<CourseEnrollment> _enrollments = const [];
  Map<String, String> _namesMap = const {};
  Map<String, String> _emailsMap = const {};

  @override
  void initState() {
    super.initState();
    _loadEnrollments();
  }

  Future<void> _loadEnrollments() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final cubit = context.read<CoursesCubit>();
      // User name/email lookup belongs to UsersCubit — it owns the
      // `users` collection. CoursesCubit only deals with courses/enrollments.
      // Captured before the awaits so we don't reach across an async gap.
      final studentsCubit = context.read<UsersCubit>();
      final enrollments = await cubit.fetchCourseEnrollments(
        widget.course.courseID,
      );
      final userIds = enrollments
          .map((e) => e.userID)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();
      final info = await studentsCubit.fetchUsersBasicInfo(userIds);

      if (!mounted) return;
      setState(() {
        _enrollments = enrollments;
        _namesMap = info.names;
        _emailsMap = info.emails;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      final translated = FirebaseErrorTranslator.translate(
        e,
        fallback: AppStrings.errors.courseLoadFailed,
      );
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = translated.message;
      });
    }
  }

  // Pending requests lead (they need action), then confirmed (active/ready).
  // Cancelled rows stay hidden. Newest `enrolledAt` first within each group.
  List<CourseEnrollment> get _visibleEnrollments {
    int rank(EnrollmentStatus s) => switch (s) {
      EnrollmentStatus.pending => 0,
      EnrollmentStatus.active => 1,
      EnrollmentStatus.ready => 1,
      EnrollmentStatus.cancelled => 2,
    };
    return _enrollments
        .where((e) => e.status != EnrollmentStatus.cancelled)
        .toList()
      ..sort((a, b) {
        final byRank = rank(a.status).compareTo(rank(b.status));
        return byRank != 0 ? byRank : b.enrolledAt.compareTo(a.enrolledAt);
      });
  }

  // Header badge counts confirmed students only — a pending request isn't an
  // "enrolled" student yet.
  int get _confirmedTotal => _enrollments
      .where(
        (e) =>
            e.status == EnrollmentStatus.active ||
            e.status == EnrollmentStatus.ready,
      )
      .length;

  Future<void> _confirmEnrollment(CourseEnrollment enrollment) async {
    final name = _namesMap[enrollment.userID] ?? 'هذا الطالب';
    // Amount charged = the course's live price (discounted if the offer is
    // still active, full price otherwise) — taken automatically, no entry.
    final amount = widget.course.getFinalPrice();

    final ok = await _showConfirmDialog(
      header: 'تأكيد تسجيل الطالب؟',
      description:
          'سيتم تأكيد تسجيل «$name» وتسجيل دفعة يدوية بقيمة '
          '${CurrencyFormatter.withCode(amount, 'EGP')}، وسيصبح الكورس جاهزاً له.',
      lottiePath: AppAssets.animations.checkedSuccess,
      confirmTitle: 'تأكيد التسجيل',
      confirmColor: AppColors.pastelGreen,
    );
    if (ok != true || !mounted) return;

    setState(() => _busyId = enrollment.enrollmentID);
    final cubit = context.read<CoursesCubit>();
    try {
      await cubit.confirmEnrollment(enrollment: enrollment, amount: amount);
      if (!mounted) return;
      DashboardHelper.showSuccessBar(context, message: 'تم تأكيد تسجيل الطالب');
      await _loadEnrollments();
    } catch (e) {
      if (!mounted) return;
      // The cubit throws localized Arabic strings for the known failure cases;
      // anything else gets translated through the Firebase helper.
      final msg = e is String
          ? e
          : FirebaseErrorTranslator.translate(
              e,
              fallback: 'تعذّر تأكيد التسجيل، حاول مجددًا',
            ).message;
      DashboardHelper.showErrorBar(context, error: msg);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _rejectEnrollment(CourseEnrollment enrollment) async {
    final name = _namesMap[enrollment.userID] ?? 'هذا الطالب';
    final ok = await _showConfirmDialog(
      header: 'رفض طلب التسجيل؟',
      description: 'سيتم رفض طلب «$name» للتسجيل في الكورس. يمكنه إرسال طلب جديد لاحقًا.',
      lottiePath: AppAssets.animations.redWarning,
      confirmTitle: 'تأكيد الرفض',
    );
    if (ok != true || !mounted) return;

    setState(() => _busyId = enrollment.enrollmentID);
    final cubit = context.read<CoursesCubit>();
    try {
      await cubit.rejectPendingEnrollment(enrollment: enrollment);
      if (!mounted) return;
      DashboardHelper.showSuccessBar(context, message: 'تم رفض طلب التسجيل');
      await _loadEnrollments();
    } catch (e) {
      if (!mounted) return;
      final msg = e is String
          ? e
          : FirebaseErrorTranslator.translate(
              e,
              fallback: 'تعذّر رفض الطلب، حاول مجددًا',
            ).message;
      DashboardHelper.showErrorBar(context, error: msg);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<void> _cancelEnrollment(CourseEnrollment enrollment) async {
    final ok = await _showConfirmDialog(
      header: 'إلغاء تسجيل الطالب؟',
      description:
          'سيفقد الطالب الوصول إلى محتوى الكورس. يمكن إعادة تسجيله لاحقًا.',
      lottiePath: AppAssets.animations.yellowWarning,
      confirmTitle: 'تأكيد الإلغاء',
    );
    if (ok != true || !mounted) return;

    setState(() => _busyId = enrollment.enrollmentID);
    final cubit = context.read<CoursesCubit>();
    try {
      await cubit.cancellingCourseEnrollment(
        userId: enrollment.userID,
        courseId: widget.course.courseID,
      );
      if (!mounted) return;
      DashboardHelper.showSuccessBar(context, message: 'تم إلغاء تسجيل الطالب');
      await _loadEnrollments();
    } catch (e) {
      if (!mounted) return;
      final translated = FirebaseErrorTranslator.translate(
        e,
        fallback: 'تعذّر إلغاء التسجيل، حاول مجددًا',
      );
      DashboardHelper.showErrorBar(context, error: translated.message);
    } finally {
      if (mounted) setState(() => _busyId = null);
    }
  }

  Future<bool?> _showConfirmDialog({
    required String header,
    required String description,
    required String lottiePath,
    required String confirmTitle,
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AppDialog(
          header: header,
          description: description,
          lottiePath: lottiePath,
          cancelTitle: 'تراجع',
          confirmTitle: confirmTitle,
          confirmColor: confirmColor,
          onConfirm: () => Navigator.of(dctx).pop(true),
        ),
      ),
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetHeader(course: widget.course),
            const SizedBox(height: 20),
            if (_isLoading)
              const _LoadingState()
            else if (_hasError)
              _ErrorState(message: _errorMessage, onRetry: _loadEnrollments)
            else
              _LoadedContent(
                enrollments: _visibleEnrollments,
                namesMap: _namesMap,
                emailsMap: _emailsMap,
                total: _confirmedTotal,
                busyId: _busyId,
                onConfirm: _confirmEnrollment,
                onReject: _rejectEnrollment,
                onCancel: _cancelEnrollment,
              ),
          ],
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  final Course course;
  const _SheetHeader({required this.course});

  @override
  Widget build(BuildContext context) {
    final shahr = GoogleFonts.scheherazadeNew();
    final amiri = GoogleFonts.amiri();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'مسجّلو الكورس',
                style: shahr.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                course.title,
                style: amiri.copyWith(
                  fontSize: 14,
                  color: AppColors.neutral500,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.midBlue.withAlpha(28),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.groups_2_rounded,
            color: AppColors.midBlue,
            size: 22,
          ),
        ),
      ],
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final amiri = GoogleFonts.amiri();

    return Column(
      children: [
        const SizedBox(height: 40),
        const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.midBlue),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'جاري تحميل قائمة المسجّلين...',
          style: amiri.copyWith(fontSize: 14, color: AppColors.neutral500),
        ),
        const SizedBox(height: 30),
        ...List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.surfaceAltDark.withAlpha(120),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final shahr = GoogleFonts.scheherazadeNew();
    final amiri = GoogleFonts.amiri();
    final detail = message.isNotEmpty
        ? message
        : 'تعذّر الاتصال بالخادم — حاول مرة أخرى';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.tomatoRed.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.tomatoRed,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'فشل تحميل المسجّلين',
              style: shahr.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                detail,
                textAlign: TextAlign.center,
                style: amiri.copyWith(
                  fontSize: 13,
                  color: AppColors.neutral500,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'إعادة المحاولة',
                style: shahr.copyWith(fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.midBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadedContent extends StatelessWidget {
  final List<CourseEnrollment> enrollments;
  final Map<String, String> namesMap;
  final Map<String, String> emailsMap;
  final int total;
  final String? busyId;
  final void Function(CourseEnrollment) onConfirm;
  final void Function(CourseEnrollment) onReject;
  final void Function(CourseEnrollment) onCancel;

  const _LoadedContent({
    required this.enrollments,
    required this.namesMap,
    required this.emailsMap,
    required this.total,
    required this.busyId,
    required this.onConfirm,
    required this.onReject,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final shahr = GoogleFonts.scheherazadeNew();
    final amiri = GoogleFonts.amiri();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section label + confirmed-count badge ──────────────────────
        Row(
          children: [
            const Icon(
              Icons.people_alt_rounded,
              color: AppColors.neutral500,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'قائمة المسجّلين',
              style: shahr.copyWith(
                fontSize: 18,
                color: AppColors.neutral300,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceAltDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$total طالب',
                style: amiri.copyWith(
                  fontSize: 13,
                  color: AppColors.neutral500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // ── Enrollment tiles ───────────────────────────────────────────
        if (enrollments.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'لا يوجد مسجّلون بعد',
                style: shahr.copyWith(fontSize: 16, color: Colors.white60),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: enrollments.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final e = enrollments[i];
              final name = namesMap[e.userID] ?? 'طالب غير معروف';
              final email = emailsMap[e.userID] ?? '';
              return _EnrollmentTile(
                enrollment: e,
                userName: name,
                userEmail: email,
                isBusy: busyId == e.enrollmentID,
                onConfirm: () => onConfirm(e),
                onReject: () => onReject(e),
                onCancel: () => onCancel(e),
              );
            },
          ),
      ],
    );
  }
}

class _EnrollmentTile extends StatelessWidget {
  final CourseEnrollment enrollment;
  final String userName;
  final String userEmail;
  final bool isBusy;
  final VoidCallback onConfirm;
  final VoidCallback onReject;
  final VoidCallback onCancel;

  const _EnrollmentTile({
    required this.enrollment,
    required this.userName,
    required this.userEmail,
    required this.isBusy,
    required this.onConfirm,
    required this.onReject,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final shahr = GoogleFonts.scheherazadeNew();
    final amiri = GoogleFonts.amiri();

    final accent = _accentFor(enrollment.status);
    final bg = accent.withAlpha(18);
    final initial = userName.trim().isNotEmpty ? userName.trim()[0] : '؟';
    final isPending = enrollment.status == EnrollmentStatus.pending;
    final expiryHint = isPending ? _expiryHint(enrollment.pendingExpiresAt) : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withAlpha(45), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accent.withAlpha(35),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: shahr.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: accent,
                      height: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Name + email (+ pending expiry hint)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: shahr.copyWith(
                        fontSize: 17,
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (userEmail.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        userEmail,
                        style: amiri.copyWith(
                          fontSize: 12,
                          color: AppColors.neutral500,
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (expiryHint != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.timer_outlined,
                            size: 12,
                            color: AppColors.royalYellow,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            expiryHint,
                            style: amiri.copyWith(
                              fontSize: 11,
                              color: AppColors.royalYellow,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(width: 10),

              _ResultChip(
                label: _labelFor(enrollment.status),
                color: accent,
                filled: true,
              ),

              // Active/ready tiles keep the inline cancel control.
              if (!isPending) ...[
                const SizedBox(width: 8),
                isBusy
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            AppColors.tomatoRed.withAlpha(200),
                          ),
                        ),
                      )
                    : IconButton(
                        onPressed: onCancel,
                        tooltip: 'إلغاء التسجيل',
                        icon: const Icon(
                          Icons.cancel_rounded,
                          color: AppColors.tomatoRed,
                          size: 22,
                        ),
                      ),
              ],
            ],
          ),

          // Pending tiles get the confirm / reject action row.
          if (isPending) ...[
            const SizedBox(height: 12),
            if (isBusy)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 6),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation(AppColors.pastelGreen),
                    ),
                  ),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: 'تأكيد',
                      icon: Icons.check_rounded,
                      color: AppColors.pastelGreen,
                      filled: true,
                      onTap: onConfirm,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _ActionButton(
                      label: 'رفض',
                      icon: Icons.close_rounded,
                      color: AppColors.tomatoRed,
                      onTap: onReject,
                    ),
                  ),
                ],
              ),
          ],
        ],
      ),
    );
  }

  /// Remaining-time label for a pending request's 3-day window.
  String? _expiryHint(DateTime? expiresAt) {
    if (expiresAt == null) return null;
    final left = expiresAt.difference(DateTime.now());
    if (left.isNegative) return 'انتهت صلاحية الطلب';
    final days = left.inDays;
    if (days >= 1) return 'ينتهي خلال $days ${days == 1 ? 'يوم' : 'أيام'}';
    final hours = left.inHours;
    if (hours >= 1) return 'ينتهي خلال $hours ${hours == 1 ? 'ساعة' : 'ساعات'}';
    return 'ينتهي قريبًا';
  }

  Color _accentFor(EnrollmentStatus s) => switch (s) {
    EnrollmentStatus.active => AppColors.pastelGreen,
    EnrollmentStatus.ready => AppColors.royalYellow,
    EnrollmentStatus.pending => AppColors.skyBlue,
    EnrollmentStatus.cancelled => AppColors.tomatoRed,
  };

  String _labelFor(EnrollmentStatus s) => switch (s) {
    EnrollmentStatus.active => 'نشط',
    EnrollmentStatus.ready => 'جاهز للبدء',
    EnrollmentStatus.pending => 'بانتظار التأكيد',
    EnrollmentStatus.cancelled => 'ملغى',
  };
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool filled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? color : color.withAlpha(22),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: filled
                ? null
                : Border.all(color: color.withAlpha(70), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: filled ? Colors.white : color),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.scheherazadeNew(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: filled ? Colors.white : color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ResultChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;

  const _ResultChip({
    required this.label,
    required this.color,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? color.withAlpha(55) : color.withAlpha(22),
        borderRadius: BorderRadius.circular(8),
        border: filled
            ? null
            : Border.all(color: color.withAlpha(60), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.amiri(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
