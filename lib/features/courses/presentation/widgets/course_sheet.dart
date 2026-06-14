import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_strings.dart';
import 'package:mrmichaelashrafdashboard/core/enums/grade.dart';
import 'package:mrmichaelashrafdashboard/core/enums/subject.dart';
import 'package:mrmichaelashrafdashboard/core/enums/teacher.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/app_validator.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course_lesson.dart';
import 'package:mrmichaelashrafdashboard/features/courses/logic/courses_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/courses/logic/courses_state.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/admin_hover_button.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/auth_text_field.dart';
import 'package:mrmichaelashrafdashboard/shared/dialogs/dashboard_sheet.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/picker_field.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/date_picker_field.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_assets.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/sheet_section_header.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/sheet_sub_section_label.dart';

class CourseSheet extends StatefulWidget {
  final Course? existingCourse;
  final Function(Course)? onSaveUpdates;
  final Function()? onPublish;
  final Function()? onDelete;

  const CourseSheet({
    super.key,
    this.existingCourse,
    this.onSaveUpdates,
    this.onPublish,
    this.onDelete,
  });

  @override
  State<CourseSheet> createState() => _CoursesManagerState();
}

class _CoursesManagerState extends State<CourseSheet> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  late TextEditingController discountController;
  DateTime? discountDate;
  bool isEditing = false;
  bool _hasUnsavedChanges = false;

  /// "Armed" state for the tap-twice-to-confirm close pattern. When the user
  /// taps cancel / swipes the sheet with unsaved changes, we set this true,
  /// show the warning snackbar, and arm a 4-second window where the next
  /// dismiss attempt actually closes. After the window expires we reset it.
  bool _confirmedClose = false;
  String? selectedGrade;
  String? selectedSubject;
  String? selectedTeacher;
  final List<TextEditingController> _learningPoints = [];
  List<Map<String, TextEditingController>> lessons = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    try {
      titleController = TextEditingController();
      descriptionController = TextEditingController();
      priceController = TextEditingController(text: '0');
      discountController = TextEditingController(text: '0');

      // Populate the controllers FIRST — otherwise `_loadExistingCourse` does
      // `.text = ...` which fires every listener and falsely marks the form
      // as dirty before the admin has touched anything.
      if (widget.existingCourse != null) {
        isEditing = false; // Start in view mode for existing courses
        _loadExistingCourse();
      } else {
        isEditing = true; // New courses start in edit mode
        _addLesson();
        _addLearningPoint();
      }

      // Attach the dirty-tracker AFTER initial population so it only fires
      // for genuine user edits.
      titleController.addListener(_onFieldChanged);
      descriptionController.addListener(_onFieldChanged);
      priceController.addListener(_onFieldChanged);
      discountController.addListener(_onFieldChanged);
    } catch (e) {
      // Handle any initialization errors gracefully
      debugPrint('Error initializing CoursesManager: $e');
    }
  }

  void _onFieldChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  /// Returns `true` if there are no problematic URLs OR the admin explicitly
  /// confirmed they want to publish anyway. Empty URLs are fine (the model
  /// converts them to null) — we only flag non-empty values that don't start
  /// with `http://` or `https://`.
  Future<bool> _confirmSuspiciousLessonUrls() async {
    bool looksOk(String? raw) {
      if (raw == null) return true;
      final v = raw.trim();
      if (v.isEmpty) return true;
      return v.startsWith('http://') || v.startsWith('https://');
    }

    final flagged = <String>[];
    for (var i = 0; i < lessons.length; i++) {
      final video = lessons[i]['video']?.text;
      final pdf = lessons[i]['pdf']?.text;
      if (!looksOk(video)) flagged.add('الدرس ${i + 1} — رابط الفيديو');
      if (!looksOk(pdf)) flagged.add('الدرس ${i + 1} — رابط الـ PDF');
    }
    if (flagged.isEmpty) return true;

    final shahr = GoogleFonts.scheherazadeNew();
    final amiri = GoogleFonts.amiri();
    final accepted = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (dctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: AppColors.surfaceDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.royalYellow.withAlpha(35),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.royalYellow,
              size: 30,
            ),
          ),
          title: Text(
            'روابط مشبوهة في الدروس',
            textAlign: TextAlign.center,
            style: shahr.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryDark,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'الروابط التالية لا تبدأ بـ http أو https — قد تظهر للطلاب كصفحة فارغة:',
                textAlign: TextAlign.center,
                style: amiri.copyWith(
                  fontSize: 13,
                  color: AppColors.neutral300,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              // Cap at 5 entries so an admin with many bad URLs still gets
              // a readable list, not a wall of text.
              ...flagged
                  .take(5)
                  .map(
                    (label) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '• $label',
                        textAlign: TextAlign.center,
                        style: amiri.copyWith(
                          fontSize: 13,
                          color: AppColors.royalYellow,
                        ),
                      ),
                    ),
                  ),
              if (flagged.length > 5)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '… و ${flagged.length - 5} روابط أخرى',
                    style: amiri.copyWith(
                      fontSize: 12,
                      color: AppColors.neutral500,
                    ),
                  ),
                ),
            ],
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dctx).pop(false),
              child: Text(
                'تعديل الروابط',
                style: shahr.copyWith(
                  fontSize: 15,
                  color: AppColors.neutral300,
                ),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.royalYellow,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.of(dctx).pop(true),
              child: Text(
                'متابعة كما هي',
                style: shahr.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
    return accepted == true;
  }

  /// Single close-flow entry point used by both PopScope (drag-down / barrier
  /// tap) and the explicit "إلغاء" footer button. Falls through immediately
  /// when there's nothing to lose; otherwise shows the warning snackbar and
  /// requires a confirming second attempt to actually leave.
  void _attemptClose() {
    if (!_hasUnsavedChanges || _confirmedClose) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _confirmedClose = true);
    DashboardHelper.showWarningBar(
      context,
      message: 'لديك تعديلات غير محفوظة. اضغط مرة أخرى للتأكيد على الإلغاء',
    );
    // Disarm after a short window so an accidental second tap later doesn't
    // discard their work.
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _confirmedClose = false);
    });
  }

  void _loadExistingCourse() {
    try {
      final c = widget.existingCourse!;
      titleController.text = c.title;
      descriptionController.text = c.description;
      priceController.text = c.price.toString();
      discountController.text = c.discount.toString();
      if (c.discountDueDate > 0) {
        discountDate = DateTime.fromMillisecondsSinceEpoch(c.discountDueDate);
      }
      selectedGrade = c.grade.label;
      selectedSubject = c.subject.label;
      selectedTeacher = c.teacher;

      // Load lessons data - ensure lessons list exists
      if (c.lessons.isNotEmpty) {
        for (final l in c.lessons) {
          final controllers = {
            'lessonID': TextEditingController(text: l.lessonID),
            'title': TextEditingController(text: l.title),
            'video': TextEditingController(text: l.videoURL ?? ''),
            'pdf': TextEditingController(text: l.pdfURL ?? ''),
          };
          lessons.add(controllers);
        }
      } else {
        // Ensure at least one lesson exists
        _addLesson();
      }

      // Load learning points (content) - ensure content list exists
      if (c.content.isNotEmpty) {
        for (final p in c.content) {
          _learningPoints.add(TextEditingController(text: p));
        }
      } else {
        // Ensure at least one learning point exists
        _addLearningPoint();
      }
    } catch (e) {
      // Handle any loading errors gracefully
      debugPrint('Error loading existing course: $e');
      // Ensure basic structure exists even if loading fails
      if (lessons.isEmpty) _addLesson();
      if (_learningPoints.isEmpty) _addLearningPoint();
    }
  }

  void _addLesson() {
    setState(() {
      final c = {
        'title': TextEditingController(),
        'video': TextEditingController(),
        'pdf': TextEditingController(),
      };
      lessons.add(c);
    });
  }

  void _removeLesson(int i) => setState(() => lessons.removeAt(i));

  void _addLearningPoint() =>
      setState(() => _learningPoints.add(TextEditingController()));

  void _removeLearningPoint(int i) =>
      setState(() => _learningPoints.removeAt(i));

  Course _buildCourseModel() {
    for (var i = 0; i < lessons.length; i++) {
      if (!lessons[i].containsKey('lessonID') ||
          lessons[i]['lessonID'] == null) {
        lessons[i]['lessonID'] = TextEditingController(
          text: '${DateTime.now().millisecondsSinceEpoch}_$i',
        );
      }
    }

    double price = 0;
    double discount = 0;

    try {
      price = double.parse(priceController.text.trim());
    } catch (_) {}
    try {
      discount = double.parse(discountController.text.trim());
    } catch (_) {}

    // Convert selected grade label to Grade enum
    Grade selectedGradeEnum = Grade.allGrades;
    if (selectedGrade != null && selectedGrade!.isNotEmpty) {
      try {
        selectedGradeEnum = Grade.values.firstWhere(
          (g) => g.label == selectedGrade,
          orElse: () => Grade.allGrades,
        );
      } catch (e) {
        selectedGradeEnum = Grade.allGrades;
      }
    }

    // Convert selected subject label to Subject enum
    Subject selectedSubjectEnum = Subject.geography;
    if (selectedSubject != null && selectedSubject!.isNotEmpty) {
      try {
        selectedSubjectEnum = Subject.values.firstWhere(
          (s) => s.label == selectedSubject,
          orElse: () => Subject.geography,
        );
      } catch (e) {
        selectedSubjectEnum = Subject.geography;
      }
    }

    return Course(
      courseID:
          widget.existingCourse?.courseID ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      // New courses start hidden — the admin reviews then toggles them
      // visible from the card. Editing preserves the current flag.
      isVisible: widget.existingCourse?.isVisible ?? false,
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      background: _getBackgroundImage(),
      teacher: selectedTeacher ?? '',
      grade: selectedGradeEnum,
      subject: selectedSubjectEnum,
      price: price,
      discount: discount,
      discountDueDate: discountDate?.millisecondsSinceEpoch ?? 0,
      content: _learningPoints
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList(),
      lessons: lessons
          .map(
            (l) => CourseLesson(
              lessonID:
                  l['lessonID']?.text ??
                  DateTime.now().millisecondsSinceEpoch.toString(),
              title: l['title']!.text.trim(),
              videoURL: l['video']!.text.trim().isEmpty
                  ? null
                  : l['video']!.text.trim(),
              pdfURL: l['pdf']!.text.trim().isEmpty
                  ? null
                  : l['pdf']!.text.trim(),
            ),
          )
          .toList(),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    discountController.dispose();
    for (var l in lessons) {
      l['title']?.dispose();
      l['video']?.dispose();
      l['pdf']?.dispose();
      l['lessonID']?.dispose();
    }
    for (var c in _learningPoints) {
      c.dispose();
    }
    super.dispose();
  }

  String _getBackgroundImage() {
    if (selectedGrade == Grade.highSchool1.label ||
        selectedGrade == Grade.highSchool2.label) {
      return AppAssets.images.coursePlaceholder12;
    } else if (selectedGrade == Grade.highSchool3.label) {
      return AppAssets.images.coursePlaceholder3;
    } else {
      return AppAssets.images.courseDefault;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CoursesCubit, CoursesState>(
      listener: (context, state) {
        if (state is PublishCourseSuccess) {
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          DashboardHelper.showSuccessBar(
            context,
            message: AppStrings.success.coursePublished,
          );
        } else if (state is SaveCourseUpdatesSuccess) {
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          DashboardHelper.showSuccessBar(
            context,
            message: AppStrings.success.updatesSaved,
          );
        } else if (state is DeleteCourseSuccess) {
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          DashboardHelper.showSuccessBar(
            context,
            message: AppStrings.success.courseDeleted,
          );
        } else if (state.errorMessage != null) {
          DashboardHelper.showErrorBar(context, error: state.errorMessage!);
        }
      },
      builder: (context, state) {
        final isLoading =
            state is PublishCourseLoading ||
            state is SaveCourseUpdatesLoading ||
            state is DeleteCourseLoading;

        return PopScope(
          // Allow the pop when there are no edits, or when the user has
          // already armed the "discard" confirmation in the snackbar window.
          canPop: !_hasUnsavedChanges || _confirmedClose,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _attemptClose();
          },
          child: DashboardSheet(
            title: widget.existingCourse != null
                ? 'تعديل الكورس'
                : 'إضافة كورس جديد',
            isEditing: isEditing,
            isSaving: isLoading,
            isExistingItem: widget.existingCourse != null,
            onEditToggle: () => setState(() => isEditing = !isEditing),
            onDelete: () {
              context.read<CoursesCubit>().deleteCourse(
                courseId: widget.existingCourse!.courseID,
              );
              if (widget.onDelete != null) {
                widget.onDelete!();
              }
            },
            onSave: () async {
              if (!_formKey.currentState!.validate()) return;

              // Lint-style URL check: warn if any lesson video / pdf URL is
              // non-empty but doesn't look like an actual http(s) link. We
              // don't BLOCK — the admin may genuinely want a local path or a
              // staging URL — but we surface the issue so it isn't silently
              // shipped to students who would just see broken players.
              final shouldProceed = await _confirmSuspiciousLessonUrls();
              if (!shouldProceed || !context.mounted) return;

              final course = _buildCourseModel();
              if (widget.existingCourse != null) {
                context.read<CoursesCubit>().saveCourseUpdates(course: course);
              } else {
                context.read<CoursesCubit>().publishCourse(course: course);
              }

              if (widget.onSaveUpdates != null &&
                  widget.existingCourse != null) {
                widget.onSaveUpdates!(course);
              } else if (widget.onPublish != null &&
                  widget.existingCourse == null) {
                widget.onPublish!();
              }
            },
            onCancel: _attemptClose,
            saveButtonTitle: widget.existingCourse != null
                ? 'حفظ التغييرات'
                : 'نشر الكورس',
            deleteDescription:
                'هل أنت متأكد من حذف هذا الكورس؟ سيتم حذف جميع بياناته نهائياً.',
            deleteLottiePath: AppAssets.animations.emptyCoursesList,
            body: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SheetSectionHeader(
                    label: 'معلومات الكورس',
                    icon: Icons.info_outline_rounded,
                  ),
                  const SizedBox(height: 10),
                  _buildCourseInfo(),
                  const SizedBox(height: 50),
                  SheetSectionHeader(
                    label: 'هنتعلم اي في الكورس',
                    icon: Icons.question_answer,
                  ),
                  const SizedBox(height: 10),
                  _buildLearningPointsSection(),
                  const SizedBox(height: 50),
                  SheetSectionHeader(
                    label: 'محتوي الكورس',
                    icon: Icons.question_answer,
                  ),
                  const SizedBox(height: 10),
                  _buildLessonsSection(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  TextStyle _labelStyle() => GoogleFonts.scheherazadeNew(
    fontSize: 18,
    fontWeight: FontWeight.w300,
    color: AppColors.appWhite,
    height: 1.5,
  );

  Widget _buildCourseInfo() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // background
      const SizedBox(height: 10),
      const SheetSubSectionLabel(label: 'عنوان الكورس'),
      const SizedBox(height: 8),
      AuthTextField(
        hint: 'مثلاً: مقدمة في الجغرافيا',
        controller: titleController,
        keyboardType: TextInputType.text,
        isEnabled: isEditing,
        validationFunction: AppValidator.validateCourseTitle,
      ),
      const SizedBox(height: 8),
      const SheetSubSectionLabel(label: 'الوصف'),
      const SizedBox(height: 8),
      AuthTextField(
        hint: 'اشرح بإيجاز محتوى الكورس',
        controller: descriptionController,
        maxLines: 3,
        keyboardType: TextInputType.text,
        isEnabled: isEditing,
        validationFunction: AppValidator.validateCourseDescription,
      ),
      const SizedBox(height: 8),
      const SheetSubSectionLabel(label: 'المدرس'),
      const SizedBox(height: 8),
      AbsorbPointer(
        absorbing: !isEditing,
        child: PickerField(
          hint: 'اختر المدرس',
          pickerList: Teacher.values.map((t) => t.label).toList(),
          currentValue: selectedTeacher,
          onChanged: (v) {
            if (v != null) {
              setState(() => selectedTeacher = v);
            }
          },
        ),
      ),
      const SizedBox(height: 8),
      const SheetSubSectionLabel(label: 'المادة'),
      const SizedBox(height: 8),
      AbsorbPointer(
        absorbing: !isEditing,
        child: PickerField(
          hint: 'اختر المادة',
          pickerList: Subject.values.map((s) => s.label).toList(),
          currentValue: selectedSubject,
          onChanged: (v) {
            if (v != null) {
              setState(() => selectedSubject = v);
            }
          },
        ),
      ),
      const SizedBox(height: 8),
      const SheetSubSectionLabel(label: 'الصف الدراسي'),
      const SizedBox(height: 8),
      AbsorbPointer(
        absorbing: !isEditing,
        child: PickerField(
          hint: 'أختر الصف الدراسي',
          pickerList: Grade.values.map((g) => g.label).toList(),
          currentValue: selectedGrade,
          onChanged: (v) {
            if (v != null) {
              setState(() => selectedGrade = v);
            }
          },
        ),
      ),
      const SizedBox(height: 8),
      const SheetSubSectionLabel(label: 'سعر الكورس'),
      const SizedBox(height: 8),
      AuthTextField(
        hint: '0 \$',
        keyboardType: TextInputType.number,
        controller: priceController,
        validationFunction: (v) {
          if (v == null || v.isEmpty) return 'ادخل سعر الكورس';
          if (double.tryParse(v) == null) return 'ادخل رقم صحيح';
          return null;
        },
        isEnabled: isEditing,
      ),
      const SizedBox(height: 8),
      const SheetSubSectionLabel(label: 'الخصم %'),
      const SizedBox(height: 8),
      AuthTextField(
        hint: '0 %',
        keyboardType: TextInputType.number,
        controller: discountController,
        validationFunction: (v) {
          if (v != null && v.isNotEmpty) {
            final val = double.tryParse(v);
            if (val == null) return 'ادخل رقم صحيح';
            if (val < 0 || val > 100) return 'يجب أن يكون بين 0 و 100';
          }
          return null;
        },
        isEnabled: isEditing,
      ),
      const SizedBox(height: 8),
      const SheetSubSectionLabel(label: 'تاريخ انتهاء الخصم'),
      const SizedBox(height: 8),
      AbsorbPointer(
        absorbing: !isEditing,
        child: DatePickerField(
          selectedDate: discountDate,
          onDateChanged: (date) {
            setState(() {
              discountDate = date;
              _hasUnsavedChanges = true;
            });
          },
          hint: 'اختر تاريخ انتهاء الخصم',
          icon: Icons.calendar_today,
          firstDate: DateTime.now(),
        ),
      ),
      if (discountDate != null && isEditing)
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () {
              setState(() {
                discountDate = null;
                _hasUnsavedChanges = true;
              });
            },
            child: Text(
              'إلغاء التاريخ',
              style: TextStyle(color: AppColors.posterRed),
            ),
          ),
        ),
    ],
  );

  Widget _buildLearningPointsSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ..._learningPoints.asMap().entries.map(
        (e) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Expanded(
                child: AuthTextField(
                  hint: 'مثلاً: تعلم أساسيات الخرائط',
                  controller: e.value,
                  maxLines: 1,
                  keyboardType: TextInputType.text,
                  isEnabled: isEditing,
                  validationFunction: (v) => null,
                ),
              ),
              if (isEditing && _learningPoints.length > 1)
                IconButton(
                  onPressed: () => _removeLearningPoint(e.key),
                  icon: const Icon(
                    Icons.delete,
                    size: 16,
                    color: AppColors.posterRed,
                  ),
                ),
            ],
          ),
        ),
      ),
      if (isEditing)
        Align(
          alignment: Alignment.centerRight,
          child: AdminHoverButton(
            title: 'أضف نقطة',
            icon: Icons.add,
            onTap: _addLearningPoint,
          ),
        ),
    ],
  );

  Widget _buildLessonsSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ...lessons.asMap().entries.map((entry) {
        final index = entry.key;
        final lesson = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.neutra2000,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(26),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ExpansionTile(
            shape: const Border(),
            collapsedShape: const Border(),
            iconColor: AppColors.skyBlue,
            collapsedIconColor: AppColors.skyBlue,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.royalBlue.withAlpha(51),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(color: AppColors.textSecondaryDark),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'الدرس ${index + 1}',
                  style: _labelStyle().copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    AuthTextField(
                      hint: 'عنوان الدرس',
                      controller: lesson['title']!,
                      validationFunction: AppValidator.validateLessonTitle,
                      keyboardType: TextInputType.text,
                      isEnabled: isEditing,
                    ),
                    AuthTextField(
                      hint: 'رابط الفيديو (اختياري)',
                      controller: lesson['video']!,
                      validationFunction: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        return AppValidator.validateUrl(v, 'رابط الفيديو');
                      },
                      keyboardType: TextInputType.text,
                      isEnabled: isEditing,
                    ),
                    AuthTextField(
                      hint: 'رابط PDF (اختياري)',
                      controller: lesson['pdf']!,
                      validationFunction: (v) {
                        // Make PDF optional - only validate if provided
                        if (v == null || v.trim().isEmpty) {
                          return null; // Allow empty
                        }
                        return AppValidator.validatePdfUrl(v);
                      },
                      keyboardType: TextInputType.text,
                      isEnabled: isEditing,
                    ),
                    if (isEditing)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: AppColors.posterRed,
                            size: 16,
                          ),
                          onPressed: () => _removeLesson(index),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      if (isEditing)
        Align(
          alignment: Alignment.centerRight,
          child: AdminHoverButton(
            title: 'أضف درس',
            icon: Icons.add,
            onTap: _addLesson,
          ),
        ),
    ],
  );
}
