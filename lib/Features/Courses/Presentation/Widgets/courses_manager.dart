import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/config/app_strings.dart';
import 'package:mrmichaelashrafdashboard/core/enums/grade.dart';
import 'package:mrmichaelashrafdashboard/core/enums/subject.dart';
import 'package:mrmichaelashrafdashboard/core/enums/teacher.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/app_validator.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/features/courses/logic/admin_courses_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/courses/logic/admin_courses_state.dart';
import 'package:mrmichaelashrafdashboard/shared/components/admin_hover_button.dart';
import 'package:mrmichaelashrafdashboard/shared/components/auth_text_field.dart';
import 'package:mrmichaelashrafdashboard/shared/components/manager_layout.dart';
import 'package:mrmichaelashrafdashboard/shared/components/picker_field.dart';
import 'package:mrmichaelashrafdashboard/shared/components/date_picker_field.dart';
import 'package:mrmichaelashrafdashboard/core/config/app_assets.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/lesson.dart';

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
  late TextEditingController discountController;
  DateTime? discountDate;
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
      discountController = TextEditingController(text: '0');

      titleController.addListener(_onFieldChanged);
      descriptionController.addListener(_onFieldChanged);
      priceController.addListener(_onFieldChanged);
      discountController.addListener(_onFieldChanged);

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
      title: titleController.text.trim(),
      description: descriptionController.text.trim(),
      startDate: DateTime.now(),
      durationDays: 0,
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
            (l) => Lesson(
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
    return BlocConsumer<AdminCoursesCubit, AdminCoursesState>(
      listener: (context, state) {
        if (state is CoursePublished) {
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          DashboardHelper.showSuccessBar(
            context,
            message: AppStrings.success.coursePublished,
          );
        } else if (state is CourseUpdatesSaved) {
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          DashboardHelper.showSuccessBar(
            context,
            message: AppStrings.success.updatesSaved,
          );
        } else if (state is CourseDeleted) {
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
        } else if (state is CoursesError) {
          DashboardHelper.showErrorBar(context, error: state.message);
        }
      },
      builder: (context, state) {
        final isLoading =
            state is PublishingCourse ||
            state is SavingCourseUpdates ||
            state is DeletingCourse;

        return ManagerLayout(
          title: widget.existingCourse != null
              ? 'تعديل الكورس'
              : 'إضافة كورس جديد',
          isEditing: isEditing,
          isLoading: isLoading,
          isExistingItem: widget.existingCourse != null,
          onEditToggle: () => setState(() => isEditing = !isEditing),
          onDelete: () {
            context.read<AdminCoursesCubit>().deleteCourse(
              courseId: widget.existingCourse!.courseID,
            );
            if (widget.onDelete != null) {
              widget.onDelete!();
            }
          },
          onSave: () {
            if (!_formKey.currentState!.validate()) return;
            final course = _buildCourseModel();
            if (widget.existingCourse != null) {
              context.read<AdminCoursesCubit>().saveCourseUpdates(
                course: course,
              );
            } else {
              context.read<AdminCoursesCubit>().publishCourse(course: course);
            }

            if (widget.onSaveUpdates != null && widget.existingCourse != null) {
              widget.onSaveUpdates!(course);
            } else if (widget.onPublish != null &&
                widget.existingCourse == null) {
              widget.onPublish!();
            }
          },
          onCancel: () => Navigator.of(context).pop(),
          saveButtonTitle: widget.existingCourse != null
              ? 'حفظ التغييرات'
              : 'نشر الكورس',
          deleteDescription:
              'هل أنت متأكد من حذف هذا الكورس؟ سيتم حذف جميع بياناته نهائياً.',
          deleteLottiePath: AppAssets.animations.emptyCoursesList,
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _sectionTitle('معلومات الكورس'),
                _buildCourseInfo(),
                const SizedBox(height: 40),
                _sectionTitle('هنتعلم اي في الكورس'),
                _buildLearningPointsSection(),
                const SizedBox(height: 40),
                _sectionTitle('الدروس'),
                _buildLessonsSection(),
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
      const SizedBox(height: 8),
    ],
  );

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
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: Container(
          key: ValueKey<String>(_getBackgroundImage()),
          height: 450,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(35),
            image: DecorationImage(
              image: AssetImage(_getBackgroundImage()) as ImageProvider,
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                AppColors.appBlack.withAlpha(30),
                BlendMode.darken,
              ),
            ),
          ),
        ),
      ),
      const SizedBox(height: 10),
      Text('عنوان الكورس', style: _labelStyle()),
      AuthTextField(
        hint: 'مثلاً: مقدمة في الجغرافيا',
        controller: titleController,
        keyboardType: TextInputType.text,
        isEnabled: isEditing,
        validationFunction: AppValidator.validateCourseTitle,
      ),
      const SizedBox(height: 8),
      Text('الوصف', style: _labelStyle()),
      AuthTextField(
        hint: 'اشرح بإيجاز محتوى الكورس',
        controller: descriptionController,
        maxLines: 3,
        keyboardType: TextInputType.text,
        isEnabled: isEditing,
        validationFunction: AppValidator.validateCourseDescription,
      ),
      const SizedBox(height: 8),
      Text('المدرس', style: _labelStyle()),
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
      Text('المادة', style: _labelStyle()),
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
      Text('الصف الدراسي', style: _labelStyle()),
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
      Text('سعر الكورس \$', style: _labelStyle()),
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
      Text('الخصم %', style: _labelStyle()),
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
      Text('تاريخ انتهاء الخصم', style: _labelStyle()),
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
                    FontAwesomeIcons.trashCan,
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
            icon: FontAwesomeIcons.plus,
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
      if (isEditing)
        Align(
          alignment: Alignment.centerRight,
          child: AdminHoverButton(
            title: 'أضف درس',
            icon: FontAwesomeIcons.plus,
            onTap: _addLesson,
          ),
        ),
    ],
  );
}
