import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_assets.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_strings.dart';
import 'package:mrmichaelashrafdashboard/core/enums/enrollment_status.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/firebase_error_messages.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course_enrollment.dart';
import 'package:mrmichaelashrafdashboard/features/courses/logic/courses_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/users/logic/users_cubit.dart';
import 'package:mrmichaelashrafdashboard/shared/dialogs/app_dialog.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/sheet_action_tile.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/sheet_section_header.dart';

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
  String? _cancellingId;
  bool _isEnrollFormOpen = false;
  bool _isEnrolling = false;
  final _enrollController = TextEditingController();
  final _enrollFormKey = GlobalKey<FormState>();
  List<CourseEnrollment> _enrollments = const [];
  Map<String, String> _namesMap = const {};
  Map<String, String> _emailsMap = const {};

  @override
  void initState() {
    super.initState();
    _loadEnrollments();
  }

  @override
  void dispose() {
    _enrollController.dispose();
    super.dispose();
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

  List<CourseEnrollment> get _visibleEnrollments => _enrollments
      .where(
        (e) =>
            e.status == EnrollmentStatus.active ||
            e.status == EnrollmentStatus.ready,
      )
      .toList();

  int get _total => _visibleEnrollments.length;

  void _toggleEnrollForm() {
    if (_isEnrolling) return;
    setState(() {
      _isEnrollFormOpen = !_isEnrollFormOpen;
      if (!_isEnrollFormOpen) _enrollController.clear();
    });
  }

  Future<void> _submitEnrollForm() async {
    if (_isEnrolling) return;
    if (!_enrollFormKey.currentState!.validate()) return;

    setState(() => _isEnrolling = true);
    final cubit = context.read<CoursesCubit>();
    try {
      await cubit.enrollingAStudent(
        courseId: widget.course.courseID,
        email: _enrollController.text.trim(),
      );
      if (!mounted) return;
      DashboardHelper.showSuccessBar(
        context,
        message: 'تم تسجيل الطالب في الكورس بنجاح',
      );
      setState(() {
        _isEnrollFormOpen = false;
        _enrollController.clear();
      });
      await _loadEnrollments();
    } catch (e) {
      if (!mounted) return;
      // The cubit throws localized Arabic strings for the known failure
      // cases; anything else gets translated through the Firebase helper.
      final msg = e is String
          ? e
          : FirebaseErrorTranslator.translate(
              e,
              fallback: 'تعذّر تسجيل الطالب، حاول مجددًا',
            ).message;
      DashboardHelper.showErrorBar(context, error: msg);
    } finally {
      if (mounted) setState(() => _isEnrolling = false);
    }
  }

  Future<void> _cancelEnrollment(CourseEnrollment enrollment) async {
    final ok = await _confirmCancel();
    if (ok != true || !mounted) return;

    setState(() => _cancellingId = enrollment.enrollmentID);
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
      if (mounted) setState(() => _cancellingId = null);
    }
  }

  Future<bool?> _confirmCancel() {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AppDialog(
          header: 'إلغاء تسجيل الطالب؟',
          description:
              'سيفقد الطالب الوصول إلى محتوى الكورس. يمكن إعادة تسجيله لاحقًا.',
          lottiePath: AppAssets.animations.yellowWarning,
          cancelTitle: 'تراجع',
          confirmTitle: 'تأكيد الإلغاء',
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
                total: _total,
                cancellingId: _cancellingId,
                onCancel: _cancelEnrollment,
                onToggleEnrollForm: _toggleEnrollForm,
                onSubmitEnrollForm: _submitEnrollForm,
                isEnrollFormOpen: _isEnrollFormOpen,
                isEnrolling: _isEnrolling,
                enrollController: _enrollController,
                enrollFormKey: _enrollFormKey,
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
  final String? cancellingId;
  final void Function(CourseEnrollment) onCancel;

  // Inline enroll-form plumbing — owned by the stateful parent.
  final VoidCallback onToggleEnrollForm;
  final VoidCallback onSubmitEnrollForm;
  final bool isEnrollFormOpen;
  final bool isEnrolling;
  final TextEditingController enrollController;
  final GlobalKey<FormState> enrollFormKey;

  const _LoadedContent({
    required this.enrollments,
    required this.namesMap,
    required this.emailsMap,
    required this.total,
    required this.cancellingId,
    required this.onCancel,
    required this.onToggleEnrollForm,
    required this.onSubmitEnrollForm,
    required this.isEnrollFormOpen,
    required this.isEnrolling,
    required this.enrollController,
    required this.enrollFormKey,
  });

  @override
  Widget build(BuildContext context) {
    final shahr = GoogleFonts.scheherazadeNew();
    final amiri = GoogleFonts.amiri();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section label + count badge ────────────────────────────────
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
                isCancelling: cancellingId == e.enrollmentID,
                onCancel: () => onCancel(e),
              );
            },
          ),

        const SizedBox(height: 50),

        // ── Admin actions ─────────────────────────────────────────────
        SheetSectionHeader(
          label: 'إجراءات الإدارة',
          icon: Icons.admin_panel_settings_outlined,
        ),
        const SizedBox(height: 14),
        SheetActionTile(
          icon: Icons.person_add_alt_1_rounded,
          accentColor: AppColors.pastelGreen,
          title: 'تسجيل طالب يدويًا',
          subtitle: isEnrollFormOpen
              ? 'أدخل البريد الإلكتروني للطالب أدناه'
              : 'أدخل بريد الطالب لتسجيله مباشرة في الكورس',
          onTap: onToggleEnrollForm,
        ),

        // Animated reveal of the inline enroll form — drops in below the
        // action tile so the admin's focus stays in place instead of
        // jumping to a modal.
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: isEnrollFormOpen
              ? _EnrollInlineForm(
                  controller: enrollController,
                  formKey: enrollFormKey,
                  isSubmitting: isEnrolling,
                  onAdd: onSubmitEnrollForm,
                  onCancel: onToggleEnrollForm,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _EnrollInlineForm extends StatelessWidget {
  final TextEditingController controller;
  final GlobalKey<FormState> formKey;
  final bool isSubmitting;
  final VoidCallback onAdd;
  final VoidCallback onCancel;

  const _EnrollInlineForm({
    required this.controller,
    required this.formKey,
    required this.isSubmitting,
    required this.onAdd,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final shahr = GoogleFonts.scheherazadeNew();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceAltDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.pastelGreen.withAlpha(40),
            width: 1,
          ),
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: controller,
                autofocus: true,
                enabled: !isSubmitting,
                keyboardType: TextInputType.emailAddress,
                onFieldSubmitted: (_) => isSubmitting ? null : onAdd(),
                style: shahr.copyWith(
                  fontSize: 16,
                  color: AppColors.textPrimaryDark,
                ),
                validator: (v) {
                  final t = v?.trim() ?? '';
                  if (t.isEmpty) return 'أدخل البريد الإلكتروني للطالب';
                  if (!t.contains('@') || !t.contains('.')) {
                    return 'صيغة البريد غير صحيحة';
                  }
                  return null;
                },
                decoration: InputDecoration(
                  hintText: 'student@example.com',
                  hintStyle: shahr.copyWith(
                    fontSize: 14,
                    color: AppColors.neutral600,
                  ),
                  prefixIcon: const Icon(
                    Icons.alternate_email_rounded,
                    color: AppColors.neutral500,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: AppColors.surfaceDark,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.pastelGreen,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isSubmitting ? null : onCancel,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.appNavy,
                    ),
                    child: Text('إلغاء', style: shahr.copyWith(fontSize: 15)),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: isSubmitting ? null : onAdd,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.pastelGreen,
                    ),
                    child: isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.pastelGreen,
                              ),
                            ),
                          )
                        : Text(
                            'إضافة',
                            style: shahr.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnrollmentTile extends StatelessWidget {
  final CourseEnrollment enrollment;
  final String userName;
  final String userEmail;
  final bool isCancelling;
  final VoidCallback onCancel;

  const _EnrollmentTile({
    required this.enrollment,
    required this.userName,
    required this.userEmail,
    required this.isCancelling,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final shahr = GoogleFonts.scheherazadeNew();
    final amiri = GoogleFonts.amiri();

    final accent = _accentFor(enrollment.status);
    final bg = accent.withAlpha(18);
    final initial = userName.trim().isNotEmpty ? userName.trim()[0] : '؟';
    final isCancelled = enrollment.status == EnrollmentStatus.cancelled;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withAlpha(45), width: 1),
      ),
      child: Row(
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

          // Name + email
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
              ],
            ),
          ),

          const SizedBox(width: 10),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ResultChip(
                label: _labelFor(enrollment.status),
                color: accent,
                filled: true,
              ),
            ],
          ),

          const SizedBox(width: 8),

          if (!isCancelled)
            isCancelling
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
      ),
    );
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
    EnrollmentStatus.pending => 'بانتظار الدفع',
    EnrollmentStatus.cancelled => 'ملغى',
  };
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
