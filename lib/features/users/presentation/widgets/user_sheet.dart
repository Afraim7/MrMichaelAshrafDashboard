import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/enums/enrollment_status.dart';
import 'package:mrmichaelashrafdashboard/core/enums/gender.dart';
import 'package:mrmichaelashrafdashboard/core/enums/government.dart';
import 'package:mrmichaelashrafdashboard/core/enums/grade.dart';
import 'package:mrmichaelashrafdashboard/core/enums/stage.dart';
import 'package:mrmichaelashrafdashboard/core/enums/study_type.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/currency_formatter.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course_enrollment.dart';
import 'package:mrmichaelashrafdashboard/features/courses/logic/courses_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/exam.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/exam_result.dart';
import 'package:mrmichaelashrafdashboard/features/exams/logic/exams_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/payments/core/payment_gateway.dart';
import 'package:mrmichaelashrafdashboard/features/payments/core/payment_record_status.dart';
import 'package:mrmichaelashrafdashboard/features/payments/data/models/payment_record.dart';
import 'package:mrmichaelashrafdashboard/features/payments/logic/payments_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/users/data/models/app_user.dart';
import 'package:mrmichaelashrafdashboard/features/users/logic/users_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/users/logic/users_state.dart';
import 'package:mrmichaelashrafdashboard/features/users/presentation/widgets/user_course_tile.dart';
import 'package:mrmichaelashrafdashboard/features/users/presentation/widgets/user_exam_tile.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/sheet_section_header.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/sheet_sub_section_label.dart';

class UserSheet extends StatefulWidget {
  final AppUser student;
  final List<Course> enrolledCourses;
  final List<CourseEnrollment> enrollments;
  final List<Exam> takenExams;
  final List<ExamResult> examResults;
  final VoidCallback? onResetPassword;

  const UserSheet({
    super.key,
    required this.student,
    this.enrolledCourses = const [],
    this.enrollments = const [],
    this.takenExams = const [],
    this.examResults = const [],
    this.onResetPassword,
  });

  @override
  State<UserSheet> createState() => _UserSheetState();
}

typedef _CommitField =
    Future<bool> Function({
      required String key,
      required Object value,
      required AppUser Function(AppUser) update,
    });

class _UserSheetState extends State<UserSheet> {
  late AppUser _student = widget.student;
  List<PaymentRecord>? _payments;
  List<CourseEnrollment>? _enrollments;
  List<Course>? _enrolledCourses;
  List<ExamResult>? _examResults;
  List<Exam>? _takenExams;

  @override
  void initState() {
    super.initState();
    _loadPayments();
    _loadCoursesAndEnrollments();
    _loadExamsAndResults();
  }

  Future<void> _loadPayments() async {
    final result = await context.read<PaymentsCubit>().fetchPaymentsByUser(
      widget.student.userID,
    );
    if (!mounted) return;
    setState(() => _payments = result);
  }

  Future<void> _loadCoursesAndEnrollments() async {
    if (widget.enrollments.isNotEmpty && widget.enrolledCourses.isNotEmpty) {
      setState(() {
        _enrollments = widget.enrollments;
        _enrolledCourses = widget.enrolledCourses;
      });
      return;
    }
    try {
      final cubit = context.read<CoursesCubit>();
      final enrollments = await cubit.fetchEnrollmentsByUser(
        widget.student.userID,
      );
      final courseIds = enrollments.map((e) => e.courseID).toSet().toList();
      final courses = await cubit.fetchCoursesByIds(courseIds);
      if (!mounted) return;
      setState(() {
        _enrollments = enrollments;
        _enrolledCourses = courses;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _enrollments = const [];
        _enrolledCourses = const [];
      });
    }
  }

  Future<void> _loadExamsAndResults() async {
    if (widget.examResults.isNotEmpty && widget.takenExams.isNotEmpty) {
      setState(() {
        _examResults = widget.examResults;
        _takenExams = widget.takenExams;
      });
      return;
    }
    try {
      final cubit = context.read<ExamsCubit>();
      final results = await cubit.fetchResultsByUser(widget.student.userID);
      final examIds = results.map((r) => r.examID).toSet().toList();
      final exams = await cubit.fetchExamsByIds(examIds);
      if (!mounted) return;
      setState(() {
        _examResults = results;
        _takenExams = exams;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _examResults = const [];
        _takenExams = const [];
      });
    }
  }

  List<PaymentRecord> get _confirmedPayments => (_payments ?? const [])
      .where((p) => p.status == PaymentRecordStatus.success)
      .toList();

  Future<bool> _commitField({
    required String key,
    required Object value,
    required AppUser Function(AppUser) update,
  }) async {
    final raw = value is Enum ? value.name : value;
    final cubit = context.read<UsersCubit>();
    final ok = await cubit.updateUserField(
      userID: _student.userID,
      updates: {key: raw},
    );
    if (!mounted) return false;
    if (ok) {
      setState(() => _student = update(_student));
      DashboardHelper.showSuccessBar(context, message: 'تم حفظ التعديلات');
    } else {
      DashboardHelper.showErrorBar(
        context,
        error: cubit.state.errorMessage ?? 'تعذّر حفظ التعديلات، حاول مجددًا',
      );
    }
    return ok;
  }

  @override
  Widget build(BuildContext context) {
    final student = _student;
    final enrolledCourses = _enrolledCourses;
    final enrollments = _enrollments;
    final takenExams = _takenExams;
    final examResults = _examResults;

    final enrollmentMap = {
      for (final e in enrollments ?? const <CourseEnrollment>[]) e.courseID: e,
    };
    final resultMap = {
      for (final r in examResults ?? const <ExamResult>[]) r.examID: r,
    };

    final visibleCourses = enrolledCourses?.where((c) {
      final enr = enrollmentMap[c.courseID];
      return enr != null &&
          (enr.status == EnrollmentStatus.active ||
              enr.status == EnrollmentStatus.ready);
    }).toList();

    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profile header ─────────────────────────────────────────────
            _ProfileHeader(student: student),

            const SizedBox(height: 50),

            // ── معلومات الطالب ─────────────────────────────────────────────
            SheetSectionHeader(
              label: 'معلومات الطالب',
              icon: Icons.info_outline_rounded,
            ),
            const SizedBox(height: 14),
            _InfoColumn(student: student, commit: _commitField),

            const SizedBox(height: 50),

            // ── إحصائيات الطالب ────────────────────────────────────────────
            SheetSectionHeader(
              label: 'إحصائيات الطالب',
              icon: Icons.analytics_outlined,
            ),

            const SizedBox(height: 6),

            // Counter quick stats — every number is a live count derived from
            // the lazy-fetched lists, NOT the (stale) counters on the user doc.
            // `…` while the async fetch is in flight.
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  _QuickStatBox(
                    icon: Icons.menu_book_rounded,
                    iconColor: AppColors.midBlue,
                    value: visibleCourses == null
                        ? '…'
                        : visibleCourses.length.toString(),
                    label: 'كورسات مسجلة',
                  ),
                  const SizedBox(width: 10),
                  _QuickStatBox(
                    icon: Icons.assignment_rounded,
                    iconColor: AppColors.pastelYellow,
                    value: examResults == null
                        ? '…'
                        : examResults.length.toString(),
                    label: 'امتحانات مؤداة',
                  ),
                  const SizedBox(width: 10),
                  _QuickStatBox(
                    icon: Icons.money,
                    iconColor: AppColors.pastelGreen,
                    value: _payments == null
                        ? '…'
                        : _confirmedPayments.length.toString(),
                    label: 'المدفوعات المؤكدة',
                  ),
                ],
              ),
            ),

            // ── Sub-section: enrolled courses ─────────────────────────────
            SheetSubSectionLabel(label: 'الكورسات المسجلة'),
            const SizedBox(height: 10),

            if (visibleCourses == null)
              const _SubSectionLoading()
            else if (visibleCourses.isEmpty)
              _EmptyState(message: 'لا توجد كورسات مسجلة بعد')
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: visibleCourses.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final course = visibleCourses[i];
                  final enr = enrollmentMap[course.courseID];
                  if (enr == null) return const SizedBox.shrink();
                  return UserCourseTile(course: course, enrollment: enr);
                },
              ),

            const SizedBox(height: 20),

            // ── Sub-section: taken exams ──────────────────────────────────
            SheetSubSectionLabel(label: 'الامتحانات المؤداة'),
            const SizedBox(height: 10),

            if (takenExams == null)
              const _SubSectionLoading()
            else if (takenExams.isEmpty)
              _EmptyState(message: 'لا توجد امتحانات مؤداة بعد')
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: takenExams.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) {
                  final exam = takenExams[i];
                  final res = resultMap[exam.examID];
                  return UserExamTile(exam: exam, result: res);
                },
              ),

            const SizedBox(height: 20),

            // ── Sub-section: confirmed payments ───────────────────────────
            SheetSubSectionLabel(label: 'المدفوعات المؤكدة'),
            const SizedBox(height: 10),

            if (_payments == null)
              const _SubSectionLoading()
            else if (_confirmedPayments.isEmpty)
              _EmptyState(message: 'لا توجد مدفوعات مؤكدة بعد')
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _confirmedPayments.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (_, i) =>
                    _ConfirmedPaymentTile(payment: _confirmedPayments[i]),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final AppUser student;
  const _ProfileHeader({required this.student});

  @override
  Widget build(BuildContext context) {
    final shahr = GoogleFonts.scheherazadeNew();
    final poppins = GoogleFonts.poppins();
    final verified = student.emailVerified == true;

    return Column(
      children: [
        Center(child: _AvatarCircle(student: student, radius: 42)),
        const SizedBox(height: 14),

        // Name
        Center(
          child: Text(
            student.userName,
            style: poppins.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimaryDark,
            ),
          ),
        ),
        const SizedBox(height: 6),

        // Grade · Stage
        Center(
          child: Text(
            '${student.grade.label}  ·  ${student.stage.label}',
            style: poppins.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w300,
              color: AppColors.neutral500,
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Verification badge
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: verified
                  ? AppColors.pastelGreen.withAlpha(25)
                  : AppColors.neutral700.withAlpha(80),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: verified
                    ? AppColors.pastelGreen.withAlpha(60)
                    : AppColors.neutral600.withAlpha(60),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  verified ? Icons.verified_rounded : Icons.cancel_outlined,
                  size: 14,
                  color: verified
                      ? AppColors.pastelGreen
                      : AppColors.neutral500,
                ),
                const SizedBox(width: 6),
                Text(
                  verified ? 'الحساب مفعّل' : 'الحساب غير مفعّل',
                  style: shahr.copyWith(
                    fontSize: 13,
                    color: verified
                        ? AppColors.pastelGreen
                        : AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final AppUser student;

  /// Commits a single field change. Each editable row builds its own typed
  /// closure over this so the inline editor stays generic.
  final _CommitField commit;

  const _InfoColumn({required this.student, required this.commit});

  @override
  Widget build(BuildContext context) {
    final verified = student.emailVerified == true;

    return Column(
      children: [
        // اسم الطالب — editable text
        _EditableInfoRow.text(
          icon: Icons.badge_outlined,
          iconColor: AppColors.midBlue,
          label: 'اسم الطالب',
          displayValue: student.userName,
          keyboardType: TextInputType.text,
          onSave: (v) => commit(
            key: 'userName',
            value: v,
            update: (u) => u.copyWith(userName: v as String),
          ),
        ),
        const SizedBox(height: 10),

        // البريد الإلكتروني — read-only (Firebase Auth email change needs
        // re-authentication + verification, out of scope for inline editing).
        _EditableInfoRow.readOnly(
          icon: Icons.email_outlined,
          iconColor: AppColors.skyBlue,
          label: 'البريد الإلكتروني',
          displayValue: student.email,
        ),
        const SizedBox(height: 10),

        // رقم الهاتف — editable text
        _EditableInfoRow.text(
          icon: Icons.phone_android_rounded,
          iconColor: AppColors.pastelGreen,
          label: 'رقم الهاتف',
          displayValue: student.phone,
          keyboardType: TextInputType.phone,
          onSave: (v) => commit(
            key: 'phone',
            value: v,
            update: (u) => u.copyWith(phone: v as String),
          ),
        ),
        const SizedBox(height: 10),

        // هاتف ولي الأمر — editable text
        _EditableInfoRow.text(
          icon: Icons.phone_rounded,
          iconColor: AppColors.royalYellow,
          label: 'هاتف ولي الأمر',
          displayValue: student.parentPhone,
          keyboardType: TextInputType.phone,
          onSave: (v) => commit(
            key: 'parentPhone',
            value: v,
            update: (u) => u.copyWith(parentPhone: v as String),
          ),
        ),
        const SizedBox(height: 10),

        // المنطقة / الحي — editable text
        _EditableInfoRow.text(
          icon: Icons.location_city_rounded,
          iconColor: AppColors.energyOrange,
          label: 'المنطقة / الحي',
          displayValue: student.area,
          keyboardType: TextInputType.text,
          onSave: (v) => commit(
            key: 'area',
            value: v,
            update: (u) => u.copyWith(area: v as String),
          ),
        ),
        const SizedBox(height: 10),

        // الجنس — editable picker
        _EditableInfoRow.pick(
          icon: Icons.person_outline_rounded,
          iconColor: AppColors.appNavy,
          label: 'الجنس',
          displayValue: student.gender.label,
          current: student.gender,
          options: [for (final g in Gender.values) _PickOption(g.label, g)],
          onSave: (v) => commit(
            key: 'gender',
            value: v,
            update: (u) => u.copyWith(gender: v as Gender),
          ),
        ),
        const SizedBox(height: 10),

        // المحافظة — editable picker
        _EditableInfoRow.pick(
          icon: Icons.location_on_outlined,
          iconColor: AppColors.neutral500,
          label: 'المحافظة',
          displayValue: student.state.label,
          current: student.state,
          options: [for (final g in Government.values) _PickOption(g.label, g)],
          onSave: (v) => commit(
            key: 'state',
            value: v,
            update: (u) => u.copyWith(state: v as Government),
          ),
        ),
        const SizedBox(height: 10),

        // الصف الدراسي — editable picker
        _EditableInfoRow.pick(
          icon: Icons.school_outlined,
          iconColor: AppColors.midBlue,
          label: 'الصف الدراسي',
          displayValue: student.grade.label,
          current: student.grade,
          options: [for (final g in Grade.values) _PickOption(g.label, g)],
          onSave: (v) => commit(
            key: 'grade',
            value: v,
            update: (u) => u.copyWith(grade: v as Grade),
          ),
        ),
        const SizedBox(height: 10),

        // المرحلة الدراسية — editable picker
        _EditableInfoRow.pick(
          icon: Icons.stairs_rounded,
          iconColor: AppColors.emeraldGreen,
          label: 'المرحلة الدراسية',
          displayValue: student.stage.label,
          current: student.stage,
          options: [for (final s in Stage.values) _PickOption(s.label, s)],
          onSave: (v) => commit(
            key: 'stage',
            value: v,
            update: (u) => u.copyWith(stage: v as Stage),
          ),
        ),
        const SizedBox(height: 10),

        // طريقة الدراسة — editable picker
        _EditableInfoRow.pick(
          icon: Icons.featured_play_list_outlined,
          iconColor: AppColors.royalBlue,
          label: 'طريقة الدراسة',
          displayValue: student.studyType.label,
          current: student.studyType,
          options: [for (final t in StudyType.values) _PickOption(t.label, t)],
          onSave: (v) => commit(
            key: 'studyType',
            value: v,
            update: (u) => u.copyWith(studyType: v as StudyType),
          ),
        ),
        const SizedBox(height: 10),

        // حالة التحقق — read-only (toggled via separate admin action)
        _EditableInfoRow.readOnly(
          icon: verified ? Icons.verified_rounded : Icons.cancel_outlined,
          iconColor: verified ? AppColors.pastelGreen : AppColors.tomatoRed,
          label: 'حالة التحقق',
          displayValue: verified ? 'البريد مؤكد' : 'البريد غير مؤكد',
          valueColor: verified ? AppColors.pastelGreen : AppColors.tomatoRed,
        ),
      ],
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final AppUser student;
  final double radius;
  const _AvatarCircle({required this.student, required this.radius});

  @override
  Widget build(BuildContext context) {
    final iconPath = student.setProfileIcon;
    final initial = student.userName.trim().isNotEmpty
        ? student.userName.trim()[0]
        : '؟';

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(
        color: AppColors.appNavy,
        shape: BoxShape.circle,
      ),
      child: iconPath.isNotEmpty
          ? ClipOval(child: Image.asset(iconPath, fit: BoxFit.cover))
          : Center(
              child: Text(
                initial,
                style: GoogleFonts.scheherazadeNew(
                  fontSize: radius * 0.8,
                  fontWeight: FontWeight.bold,
                  color: AppColors.royalYellow,
                ),
              ),
            ),
    );
  }
}

class _QuickStatBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _QuickStatBox({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final amiri = GoogleFonts.amiri();

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceAltDark,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  value,
                  style: amiri.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryDark,
                    height: 1.1,
                  ),
                ),
              ],
            ),
            Text(
              label,
              style: amiri.copyWith(
                fontSize: 14,
                color: AppColors.neutral500,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
    decoration: BoxDecoration(
      color: AppColors.surfaceAltDark,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.neutral800, width: 1),
    ),
    child: Text(
      message,
      textAlign: TextAlign.center,
      style: GoogleFonts.scheherazadeNew(
        fontSize: 14,
        color: AppColors.neutral600,
      ),
    ),
  );
}

enum _EditKind { readOnly, text, pick }

class _PickOption {
  final String label;
  final Object value;
  const _PickOption(this.label, this.value);
}

class _EditableInfoRow extends StatefulWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String displayValue;
  final Color? valueColor;
  final _EditKind kind;
  final TextInputType keyboardType;
  final List<_PickOption> options;
  final Object? current;

  /// Receives the new raw value — a String for text rows, the chosen enum for
  /// pick rows. Returns true on a successful save.
  final Future<bool> Function(Object value)? onSave;

  const _EditableInfoRow.readOnly({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.displayValue,
    this.valueColor,
  }) : kind = _EditKind.readOnly,
       keyboardType = TextInputType.text,
       options = const [],
       current = null,
       onSave = null;

  const _EditableInfoRow.text({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.displayValue,
    required this.keyboardType,
    required this.onSave,
  }) : kind = _EditKind.text,
       valueColor = null,
       options = const [],
       current = null;

  const _EditableInfoRow.pick({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.displayValue,
    required this.options,
    required this.current,
    required this.onSave,
  }) : kind = _EditKind.pick,
       valueColor = null,
       keyboardType = TextInputType.text;

  @override
  State<_EditableInfoRow> createState() => _EditableInfoRowState();
}

class _EditableInfoRowState extends State<_EditableInfoRow> {
  bool _editing = false;
  bool _saving = false;
  final _controller = TextEditingController();
  Object? _selected;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _enterEdit() {
    if (widget.kind == _EditKind.text) {
      _controller.text = widget.displayValue;
    } else {
      _selected = widget.current;
    }
    setState(() => _editing = true);
  }

  void _cancel() => setState(() => _editing = false);

  Future<void> _save() async {
    final Object value = widget.kind == _EditKind.text
        ? _controller.text.trim()
        : _selected!;

    // Empty text → ignore. Unchanged → just collapse without a round-trip.
    if (widget.kind == _EditKind.text && (value as String).isEmpty) return;
    final unchanged = widget.kind == _EditKind.text
        ? value == widget.displayValue
        : value == widget.current;
    if (unchanged) {
      setState(() => _editing = false);
      return;
    }

    setState(() => _saving = true);
    final ok = await widget.onSave!(value);
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (ok) _editing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _tile(),
          if (_editing)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _saving ? null : _cancel,
                icon: const Icon(Icons.close_rounded, size: 16),
                label: Text(
                  'إلغاء',
                  style: GoogleFonts.scheherazadeNew(fontSize: 14),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.neutral500,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _tile() {
    final amiri = GoogleFonts.amiri();
    final editable = widget.kind != _EditKind.readOnly;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAltDark,
        borderRadius: BorderRadius.circular(14),
        border: _editing
            ? Border.all(color: AppColors.midBlue.withAlpha(120), width: 1)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: widget.iconColor.withAlpha(22),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(widget.icon, color: widget.iconColor, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.label,
                  style: amiri.copyWith(
                    fontSize: 12,
                    color: AppColors.neutral500,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: _editing ? _editor() : _readValue(),
                ),
              ],
            ),
          ),
          if (editable) ...[
            const SizedBox(width: 10),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
              child: _trailing(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _readValue() {
    return Text(
      widget.displayValue.isNotEmpty ? widget.displayValue : '—',
      key: const ValueKey('read'),
      style: GoogleFonts.scheherazadeNew(
        fontSize: 15,
        color: widget.valueColor ?? AppColors.textPrimaryDark,
        height: 1.4,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _editor() {
    if (widget.kind == _EditKind.text) {
      return TextField(
        key: const ValueKey('edit-text'),
        controller: _controller,
        autofocus: true,
        enabled: !_saving,
        keyboardType: widget.keyboardType,
        onSubmitted: (_) => _save(),
        style: GoogleFonts.scheherazadeNew(
          fontSize: 15,
          color: AppColors.textPrimaryDark,
        ),
        cursorColor: AppColors.midBlue,
        decoration: const InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(vertical: 6),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.neutral700),
          ),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.neutral700),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.midBlue, width: 1.5),
          ),
        ),
      );
    }
    // Picker (enum).
    return Align(
      key: const ValueKey('edit-pick'),
      alignment: Alignment.centerRight,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Object>(
          value: _selected,
          isDense: true,
          dropdownColor: AppColors.surfaceDark,
          iconEnabledColor: AppColors.midBlue,
          borderRadius: BorderRadius.circular(12),
          style: GoogleFonts.scheherazadeNew(
            fontSize: 15,
            color: AppColors.textPrimaryDark,
          ),
          items: [
            for (final o in widget.options)
              DropdownMenuItem<Object>(value: o.value, child: Text(o.label)),
          ],
          onChanged: _saving ? null : (v) => setState(() => _selected = v),
        ),
      ),
    );
  }

  Widget _trailing() {
    if (!_editing) {
      return _SmallActionButton(
        key: const ValueKey('pencil'),
        icon: Icons.edit_outlined,
        background: AppColors.neutral800,
        foreground: AppColors.neutral500,
        onTap: _enterEdit,
      );
    }
    if (_saving) {
      return const SizedBox(
        key: ValueKey('spin'),
        width: 30,
        height: 30,
        child: Padding(
          padding: EdgeInsets.all(7),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.pastelGreen),
          ),
        ),
      );
    }
    return _SmallActionButton(
      key: const ValueKey('check'),
      icon: Icons.check_rounded,
      background: AppColors.pastelGreen.withAlpha(30),
      foreground: AppColors.pastelGreen,
      onTap: _save,
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  const _SmallActionButton({
    super.key,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(icon, size: 16, color: foreground),
        ),
      ),
    );
  }
}

class _ConfirmedPaymentTile extends StatelessWidget {
  final PaymentRecord payment;
  const _ConfirmedPaymentTile({required this.payment});

  String _fmtDate(DateTime t) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(t.day)}/${two(t.month)}/${t.year}';
  }

  @override
  Widget build(BuildContext context) {
    final shahr = GoogleFonts.scheherazadeNew();
    final amiri = GoogleFonts.amiri();
    final accent = payment.status.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAltDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withAlpha(35), width: 1),
      ),
      child: Row(
        children: [
          // Gateway / method icon tile
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: payment.paymentGateway.color.withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              payment.paymentGateway.icon,
              color: payment.paymentGateway.color,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),

          // Method + date
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.paymentMethod.isNotEmpty
                      ? payment.paymentMethod
                      : payment.paymentGateway.label,
                  style: shahr.copyWith(
                    fontSize: 15,
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _fmtDate(payment.paidAt),
                  style: amiri.copyWith(
                    fontSize: 12,
                    color: AppColors.neutral500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Amount
          Text(
            CurrencyFormatter.egp(payment.amount),
            style: shahr.copyWith(
              fontSize: 15,
              color: accent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _SubSectionLoading extends StatelessWidget {
  const _SubSectionLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 22),
      decoration: BoxDecoration(
        color: AppColors.surfaceAltDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.neutral800, width: 1),
      ),
      child: const Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.midBlue),
          ),
        ),
      ),
    );
  }
}
