import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/Core/Config/app_gaps.dart';
import 'package:mrmichaelashrafdashboard/Core/Config/app_strings.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/grade.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/sub_button_state.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/subject.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/teacher.dart';
import 'package:mrmichaelashrafdashboard/Core/Themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/Core/Utilities/_app_validator.dart';
import 'package:mrmichaelashrafdashboard/Core/Utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/Features/Admin/Logic/Cubits/AdminFunctions/admin_functions_cubit.dart';
import 'package:mrmichaelashrafdashboard/Shared/Components/app_sub_button.dart';
import 'package:mrmichaelashrafdashboard/Shared/Components/app_dialog.dart';
import 'package:mrmichaelashrafdashboard/Shared/Components/auth_text_field.dart';
import 'package:mrmichaelashrafdashboard/Shared/Components/picker_field.dart';
import 'package:mrmichaelashrafdashboard/Core/Config/app_assets.dart';
import 'package:mrmichaelashrafdashboard/Shared/Models/course.dart';
import 'package:mrmichaelashrafdashboard/Shared/Models/lesson.dart';

class CoursesManager extends StatefulWidget {
  final Course? existingCourse;
  final BuildContext context;
  final Function(Course)? onSaveUpdates;
  final Function()? onPublish;
  final Function()? onDelete;

  const CoursesManager({
    super.key,
    this.existingCourse,
    this.onSaveUpdates,
    this.onPublish,
    this.onDelete,
    required this.context,
  });

  @override
  State<CoursesManager> createState() => _CoursesManagerState();
}

class _CoursesManagerState extends State<CoursesManager> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;
  late TextEditingController priceController;
  bool isEditing = false;
  bool _hasUnsavedChanges = false;
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
      titleController.addListener(_onFieldChanged);
      descriptionController.addListener(_onFieldChanged);
      // price is fixed to 0 (free courses), no need to track changes

      if (widget.existingCourse != null) {
        isEditing = false; // Start in view mode for existing courses
        _loadExistingCourse();
      } else {
        isEditing = true; // New courses start in edit mode
        _addLesson();
        _addLearningPoint();
      }
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

  void _loadExistingCourse() {
    try {
      final c = widget.existingCourse!;
      titleController.text = c.title;
      descriptionController.text = c.description;
      priceController.text = '0';
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

    const double price = 0;

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
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      startDate: DateTime.now(),
      durationDays: 0,
      background: AppAssets.images.courseDefault,
      teacher: selectedTeacher ?? '',
      grade: selectedGradeEnum,
      subject: selectedSubjectEnum,
      price: price,
      content: _learningPoints
          .map((c) => c.text.trim())
          .where((t) => t.isNotEmpty)
          .toList(),
      lessons: lessons
          .map(
            (l) => Lesson(
              lessonID:
                  l['lessonID']?.text ??
                  DateTime.now().millisecondsSinceEpoch.toString(),
              title: l['title']!.text.trim(),
              videoURL: l['video']!.text.trim().isEmpty
                  ? null
                  : l['video']!.text.trim(),
              pdfURL: l['pdf']!.text.trim().isEmpty
                  ? AppAssets.pdfs.lessonPlaceholder
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminFunctionsCubit, AdminFunctionsState>(
      listener: (context, state) {
        if (state is AdminCoursePublished) {
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          AppHelper.showSuccessBar(
            context,
            message: AppStrings.success.coursePublished,
          );
        } else if (state is AdminCourseUpdatesSaved) {
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          AppHelper.showSuccessBar(
            context,
            message: AppStrings.success.courseUpdated,
          );
        } else if (state is AdminCourseDeleted) {
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          AppHelper.showSuccessBar(
            context,
            message: AppStrings.success.courseDeleted,
          );
        } else if (state is AdminFunctionsError) {
          AppHelper.showErrorBar(context, error: state.error);
        }
      },
      builder: (context, state) {
        final isLoading =
            state is AdminPublishingCourse ||
            state is AdminSavingCourseUpdates ||
            state is AdminDeletingCourse;
        final shouldDisable = widget.existingCourse != null && !isEditing;
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 100),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeaderSection(isLoading),
                AppGaps.v6,
                AbsorbPointer(
                  absorbing: isLoading || shouldDisable,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _sectionTitle('معلومات الكورس'),
                      _buildCourseInfo(),
                      AppGaps.v6,
                      _sectionTitle('هنتعلم اي في الكورس'),
                      _buildLearningPointsSection(),
                      AppGaps.v6,
                      _sectionTitle('الدروس'),
                      _buildLessonsSection(),
                      AppGaps.v10,
                      _buildFooterSection(isLoading),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────── UI Helpers ───────────────────────────
  Widget _sectionTitle(String title) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: GoogleFonts.scheherazadeNew(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.appWhite,
          height: 2,
        ),
      ),
      AppGaps.v3,
    ],
  );

  TextStyle _labelStyle() => GoogleFonts.scheherazadeNew(
    fontSize: 18,
    fontWeight: FontWeight.w300,
    color: AppColors.appWhite,
    height: 1.5,
  );

  Widget _hoverButton(String title, IconData icon, VoidCallback onTap) =>
      MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              color: AppColors.surfaceDark.withOpacity(0.8),
              border: Border.all(color: AppColors.appNavy, width: 1.2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 14, color: AppColors.skyBlue),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 16,
                    color: AppColors.skyBlue,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  // ─────────────────────────── Sections ───────────────────────────
  Widget _buildHeaderSection(bool isLoading) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      IconButton(
        onPressed: widget.existingCourse != null
            ? () => setState(() => isEditing = !isEditing)
            : null,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return ScaleTransition(
              scale: animation,
              child: child,
            );
          },
          child: Icon(
            isEditing ? FontAwesomeIcons.check : FontAwesomeIcons.penToSquare,
            key: ValueKey(isEditing),
            color: AppColors.skyBlue.withOpacity(
              widget.existingCourse != null ? 1.0 : 0.3,
            ),
          ),
        ),
      ),
      Text(
        widget.existingCourse != null ? 'تعديل الكورس' : 'إضافة كورس جديد',
        style: GoogleFonts.scheherazadeNew(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.appWhite,
        ),
      ),
      // Delete button - only shown when editing existing course
      IconButton(
        icon: Icon(
          FontAwesomeIcons.trashCan,
          color: AppColors.posterRed.withOpacity(
            (widget.existingCourse != null && isEditing) ? 1.0 : 0.3,
          ),
        ),
        onPressed: (widget.existingCourse != null && isEditing)
            ? () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogContext) => AppDialog(
                    header: 'حذف الكورس',
                    description:
                        'هل أنت متأكد من حذف هذا الكورس؟ سيتم حذف جميع بياناته نهائياً.',
                    lottiePath: AppAssets.animations.emptyCoursesList,
                    onConfirm: () {
                      context.read<AdminFunctionsCubit>().deleteCourse(
                        courseId: widget.existingCourse!.courseID,
                      );
                      if (widget.onDelete != null) {
                        widget.onDelete!();
                      }
                    },
                    onConfirmState: isLoading
                        ? SubButtonState.loading
                        : SubButtonState.idle,
                    confirmTitle: 'حذف',
                    cancelTitle: 'إلغاء',
                  ),
                );
              }
            : null,
      ),
    ],
  );

  Widget _buildCourseInfo() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // background
      Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          image: DecorationImage(
            image: AssetImage(AppAssets.images.courseDefault) as ImageProvider,
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              AppColors.appBlack.withOpacity(0.5),
              BlendMode.darken,
            ),
          ),
        ),
      ),
      AppGaps.v4,
      Text('عنوان الكورس', style: _labelStyle()),
      AuthTextField(
        hint: 'مثلاً: مقدمة في الجغرافيا',
        controller: titleController,
        keyboardType: TextInputType.text,
        validationFunction: AppValidator.validateCourseTitle,
      ),
      AppGaps.v3,
      Text('الوصف', style: _labelStyle()),
      AuthTextField(
        hint: 'اشرح بإيجاز محتوى الكورس',
        controller: descriptionController,
        maxLines: 3,
        keyboardType: TextInputType.text,
        validationFunction: AppValidator.validateCourseDescription,
      ),
      AppGaps.v3,
      Text('المدرس', style: _labelStyle()),
      PickerField(
        hint: 'اختر المدرس',
        pickerList: Teacher.values.map((t) => t.label).toList(),
        currentValue: selectedTeacher,
        onChanged: (v) {
          if (v != null) {
            setState(() => selectedTeacher = v);
          }
        },
      ),
      AppGaps.v3,
      Text('المادة', style: _labelStyle()),
      PickerField(
        hint: 'اختر المادة',
        pickerList: Subject.values.map((s) => s.label).toList(),
        currentValue: selectedSubject,
        onChanged: (v) {
          if (v != null) {
            setState(() => selectedSubject = v);
          }
        },
      ),
      AppGaps.v3,
      Text('الصف الدراسي', style: _labelStyle()),
      PickerField(
        hint: 'أختر الصف الدراسي',
        pickerList: Grade.values.map((g) => g.label).toList(),
        currentValue: selectedGrade,
        onChanged: (v) {
          if (v != null) {
            setState(() => selectedGrade = v);
          }
        },
      ),
      AppGaps.v3,
      Text('السعر \$', style: _labelStyle()),
      AuthTextField(
        hint: 'مجاني',
        keyboardType: TextInputType.number,
        controller: priceController,
        validationFunction: (_) => null,
        isEnabled: false,
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
                  validationFunction: (v) =>
                      v!.isEmpty ? 'أضف نقطة صالحة' : null,
                ),
              ),
              if (_learningPoints.length > 1)
                IconButton(
                  onPressed: () => _removeLearningPoint(e.key),
                  icon: const Icon(
                    FontAwesomeIcons.trashCan,
                    size: 16,
                    color: AppColors.posterRed,
                  ),
                ),
            ],
          ),
        ),
      ),
      Align(
        alignment: Alignment.centerRight,
        child: _hoverButton(
          'أضف نقطة',
          FontAwesomeIcons.plus,
          _addLearningPoint,
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
                color: Colors.black.withOpacity(0.1),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ExpansionTile(
            iconColor: AppColors.skyBlue,
            collapsedIconColor: AppColors.skyBlue,
            title: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.royalBlue.withOpacity(0.2),
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
                    ),
                    AuthTextField(
                      hint: 'رابط الفيديو',
                      controller: lesson['video']!,
                      validationFunction: (v) =>
                          AppValidator.validateUrl(v, 'رابط الفيديو'),
                      keyboardType: TextInputType.text,
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
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(
                          FontAwesomeIcons.trashCan,
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
      Align(
        alignment: Alignment.centerRight,
        child: _hoverButton('أضف درس', FontAwesomeIcons.plus, _addLesson),
      ),
    ],
  );

  Widget _buildFooterSection(bool isLoading) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Expanded(
        child: AppSubButton(
          title: widget.existingCourse != null ? 'حفظ التغييرات' : 'نشر الكورس',
          backgroundColor: AppColors.royalBlue,
          state: isLoading ? SubButtonState.loading : SubButtonState.idle,
          onTap: () {
            if (!_formKey.currentState!.validate()) return;
            final course = _buildCourseModel();
            if (widget.existingCourse != null) {
              context.read<AdminFunctionsCubit>().saveCourseUpdates(
                course: course,
              );
            } else {
              context.read<AdminFunctionsCubit>().publishCourse(course: course);
            }

            if (widget.onSaveUpdates != null && widget.existingCourse != null) {
              widget.onSaveUpdates!(course);
            } else if (widget.onPublish != null &&
                widget.existingCourse == null) {
              widget.onPublish!();
            }
          },
        ),
      ),
      AppGaps.h2,
      _hoverButton('إلغاء', FontAwesomeIcons.xmark, () {
        if (context.mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      }),
    ],
  );
}
