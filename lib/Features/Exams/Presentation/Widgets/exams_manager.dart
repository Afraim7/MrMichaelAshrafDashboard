import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/Core/Config/app_strings.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/grade.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/sub_button_state.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/exam_status.dart';
import 'package:mrmichaelashrafdashboard/Core/Themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/Core/Utilities/app_validator.dart';
import 'package:mrmichaelashrafdashboard/Core/Utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/Features/Admin/Logic/admin_functions_cubit.dart';
import 'package:mrmichaelashrafdashboard/Shared/Components/app_sub_button.dart';
import 'package:mrmichaelashrafdashboard/Shared/Components/app_dialog.dart';
import 'package:mrmichaelashrafdashboard/Shared/Components/auth_text_field.dart';
import 'package:mrmichaelashrafdashboard/Shared/Components/picker_field.dart';
import 'package:mrmichaelashrafdashboard/Shared/Components/date_picker_field.dart';
import 'package:mrmichaelashrafdashboard/Core/Config/app_assets.dart';
import 'package:mrmichaelashrafdashboard/Features/Exams/Data/Models/exam.dart';
import 'package:mrmichaelashrafdashboard/Features/Exams/Data/Models/question.dart';

class ExamsManager extends StatefulWidget {
  final Exam? existingExam;
  final Function(Exam)? onSaveUpdates;
  final Function()? onPublish;
  final Function()? onDelete;

  const ExamsManager({
    super.key,
    this.existingExam,
    this.onSaveUpdates,
    this.onPublish,
    this.onDelete,
  });

  @override
  State<ExamsManager> createState() => _ExamsManagerState();
}

class _ExamsManagerState extends State<ExamsManager> {
  late TextEditingController titleController;
  late TextEditingController durationController;
  bool isEditing = false;
  bool _hasUnsavedChanges = false;
  String? selectedGrade;
  String? selectedState;
  DateTime? startTime;
  DateTime? endTime;
  List<Map<String, dynamic>> questions = [];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    try {
      titleController = TextEditingController();
      durationController = TextEditingController();
      titleController.addListener(_onFieldChanged);
      durationController.addListener(_onFieldChanged);

      if (widget.existingExam != null) {
        isEditing = false; // Start in view mode for existing exams
        _loadExistingExam();
      } else {
        isEditing = true; // New exams start in edit mode
        _addQuestion();
      }
    } catch (e) {
      debugPrint('Error initializing ExamsManager: $e');
    }
  }

  void _onFieldChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  void _loadExistingExam() {
    try {
      final e = widget.existingExam!;
      titleController.text = e.title;
      durationController.text = e.duration?.toString() ?? '';
      selectedGrade = e.grade;
      selectedState = (e.state ?? e.computeAdminExamState()).label;
      startTime = e.startTime;
      endTime = e.endTime;

      if (e.questions != null && e.questions!.isNotEmpty) {
        for (final q in e.questions!) {
          final optionControllers = q.options != null && q.options!.isNotEmpty
              ? q.options!.map((o) => TextEditingController(text: o)).toList()
              : <TextEditingController>[];

          // Find which option index matches the correct answer
          int? correctAnswerIndex;
          if (q.correctAnswer.isNotEmpty && optionControllers.isNotEmpty) {
            for (int i = 0; i < optionControllers.length; i++) {
              if (optionControllers[i].text.trim() == q.correctAnswer.trim()) {
                correctAnswerIndex = i;
                break;
              }
            }
          }

          final controllers = {
            'questionID': TextEditingController(text: q.id),
            'question': TextEditingController(text: q.question),
            'mark': TextEditingController(text: q.mark.toString()),
            'correctAnswerIndex': correctAnswerIndex,
            'options': optionControllers,
          };
          questions.add(controllers);
        }
      } else {
        _addQuestion();
      }
    } catch (e) {
      debugPrint('Error loading existing exam: $e');
      if (questions.isEmpty) _addQuestion();
    }
  }

  void _addQuestion() {
    setState(() {
      final q = {
        'questionID': TextEditingController(),
        'question': TextEditingController(),
        'mark': TextEditingController(),
        'correctAnswerIndex': null as int?,
        'options': <TextEditingController>[],
      };
      // Add default options for MCQ (all questions are MCQ)
      for (int i = 0; i < 4; i++) {
        (q['options'] as List<TextEditingController>).add(
          TextEditingController(),
        );
      }
      questions.add(q);
    });
  }

  void _removeQuestion(int i) => setState(() {
    final q = questions[i];
    q['question']?.dispose();
    q['mark']?.dispose();
    if (q['options'] != null) {
      for (var opt in (q['options'] as List<TextEditingController>)) {
        opt.dispose();
      }
    }
    questions.removeAt(i);
  });

  void _addOption(int questionIndex) {
    setState(() {
      final q = questions[questionIndex];
      if (q['options'] == null) {
        q['options'] = <TextEditingController>[];
      }
      (q['options'] as List<TextEditingController>).add(
        TextEditingController(),
      );
    });
  }

  void _removeOption(int questionIndex, int optionIndex) {
    final q = questions[questionIndex];
    if (q['options'] != null) {
      (q['options'] as List<TextEditingController>)[optionIndex].dispose();
      (q['options'] as List<TextEditingController>).removeAt(optionIndex);
    }
  }

  Exam _buildExamModel() {
    // Generate question IDs if they don't exist
    for (var i = 0; i < questions.length; i++) {
      if (!questions[i].containsKey('questionID') ||
          questions[i]['questionID'] == null) {
        questions[i]['questionID'] = TextEditingController(
          text: '${DateTime.now().millisecondsSinceEpoch}_$i',
        );
      }
    }

    // Convert selected grade label to grade name or keep as label
    String examGrade = selectedGrade ?? '';

    // State is now computed dynamically, so we don't save it
    // Set to null - it will be computed when loading exams

    // Parse duration
    int? examDuration;
    if (durationController.text.trim().isNotEmpty) {
      examDuration = int.tryParse(durationController.text.trim());
    }

    // Build questions list (all questions are MCQ)
    List<Question> examQuestions = questions.map((q) {
      // Extract options for MCQ
      List<String>? options;
      if (q['options'] != null) {
        options = (q['options'] as List<TextEditingController>)
            .map((opt) => opt.text.trim())
            .where((opt) => opt.isNotEmpty)
            .toList();
      }

      // Parse mark
      double mark = 0.0;
      if (q['mark'] != null && q['mark'].text.trim().isNotEmpty) {
        mark = double.tryParse(q['mark'].text.trim()) ?? 0.0;
      }

      // Get correct answer from selected option index
      String correctAnswer = '';
      final correctAnswerIndex = q['correctAnswerIndex'] as int?;
      final optionControllers = q['options'] as List<TextEditingController>?;
      if (correctAnswerIndex != null &&
          optionControllers != null &&
          correctAnswerIndex >= 0 &&
          correctAnswerIndex < optionControllers.length) {
        correctAnswer = optionControllers[correctAnswerIndex].text.trim();
      }

      return Question(
        id:
            q['questionID']?.text ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        question: q['question']?.text.trim() ?? '',
        mark: mark,
        options: options?.isNotEmpty == true ? options : null,
        correctAnswer: correctAnswer,
      );
    }).toList();

    return Exam(
      id:
          widget.existingExam?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text.trim(),
      state: null,
      grade: examGrade,
      startTime: startTime,
      endTime: endTime,
      duration: examDuration,
      questions: examQuestions,
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    durationController.dispose();
    for (var q in questions) {
      q['question']?.dispose();
      q['mark']?.dispose();
      q['questionID']?.dispose();
      if (q['options'] != null) {
        for (var opt in (q['options'] as List<TextEditingController>)) {
          opt.dispose();
        }
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminFunctionsCubit, AdminFunctionsState>(
      listener: (context, state) {
        if (state is AdminExamPublished || state is AdminExamUpdatesSaved) {
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          DashboardHelper.showSuccessBar(
            context,
            message: widget.existingExam != null
                ? AppStrings.success.updatesSaved
                : AppStrings.success.examPublished,
          );
        } else if (state is AdminExamDeleted) {
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          DashboardHelper.showSuccessBar(
            context,
            message: AppStrings.success.examDeleted,
          );
        } else if (state is AdminFunctionsError) {
          DashboardHelper.showErrorBar(context, error: state.error);
        }
      },
      builder: (context, state) {
        final isLoading =
            state is AdminPublishingExam ||
            state is AdminSavingExamUpdates ||
            state is AdminDeletingExam;
        final shouldDisable = widget.existingExam != null && !isEditing;
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
                const SizedBox(height: 20),
                AbsorbPointer(
                  absorbing: isLoading || shouldDisable,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _sectionTitle('معلومات الامتحان'),
                      _buildExamInfo(),
                      const SizedBox(height: 20),
                      _sectionTitle('الأسئلة'),
                      _buildQuestionsSection(),
                      const SizedBox(height: 30),
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
      const SizedBox(height: 8),
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
              color: AppColors.surfaceDark.withAlpha(204),
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
        onPressed: widget.existingExam != null
            ? () => setState(() => isEditing = !isEditing)
            : null,
        icon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) {
            return ScaleTransition(scale: animation, child: child);
          },
          child: Icon(
            isEditing ? FontAwesomeIcons.check : FontAwesomeIcons.penToSquare,
            key: ValueKey(isEditing),
            color: AppColors.skyBlue.withAlpha(
              widget.existingExam != null ? 255 : 57,
            ),
          ),
        ),
      ),
      Flexible(
        child: Text(
          widget.existingExam != null ? 'تعديل الامتحان' : 'إضافة امتحان جديد',
          style: GoogleFonts.scheherazadeNew(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.appWhite,
          ),
        ),
      ),
      IconButton(
        icon: Icon(
          FontAwesomeIcons.trashCan,
          color: AppColors.posterRed.withAlpha(
            (widget.existingExam != null && isEditing) ? 255 : 57,
          ),
        ),
        onPressed: (widget.existingExam != null && isEditing)
            ? () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (dialogContext) => AppDialog(
                    header: 'حذف الامتحان',
                    description:
                        'هل أنت متأكد من حذف هذا الامتحان؟ سيتم حذف جميع بياناته نهائياً.',
                    // Use the exams-specific Lottie asset instead of the courses one.
                    lottiePath: AppAssets.animations.emptyExamsList,
                    onConfirmState: isLoading
                        ? SubButtonState.loading
                        : SubButtonState.idle,
                    onConfirm: () {
                      context.read<AdminFunctionsCubit>().deleteExam(
                        examId: widget.existingExam!.id,
                      );
                      if (widget.onDelete != null) {
                        widget.onDelete!();
                      }
                    },
                    confirmTitle: 'حذف',
                    cancelTitle: 'إلغاء',
                  ),
                );
              }
            : null,
      ),
    ],
  );

  Widget _buildExamInfo() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('عنوان الامتحان', style: _labelStyle()),
      AuthTextField(
        hint: 'مثلاً: امتحان منتصف الفصل في الفيزياء',
        controller: titleController,
        keyboardType: TextInputType.text,
        validationFunction: AppValidator.validateCourseTitle,
      ),
      const SizedBox(height: 8),
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
      const SizedBox(height: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('تاريخ ووقت البداية', style: _labelStyle()),
          const SizedBox(height: 8),
          DatePickerField(
            selectedDate: startTime,
            onDateChanged: (date) => setState(() => startTime = date),
            hint: 'اختر تاريخ ووقت البداية',
            icon: FontAwesomeIcons.calendar,
            firstDate: DateTime.now(),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('تاريخ ووقت النهاية', style: _labelStyle()),
          const SizedBox(height: 8),
          DatePickerField(
            selectedDate: endTime,
            onDateChanged: (date) => setState(() => endTime = date),
            hint: 'اختر تاريخ ووقت النهاية',
            icon: FontAwesomeIcons.calendar,
            firstDate: startTime ?? DateTime.now(),
          ),
        ],
      ),
      const SizedBox(height: 8),
      Text('المدة (بالدقائق)', style: _labelStyle()),
      AuthTextField(
        hint: 'مثلاً: 45',
        keyboardType: TextInputType.number,
        controller: durationController,
        validationFunction: (v) => v!.isEmpty ? 'أدخل المدة بالدقائق' : null,
      ),
    ],
  );

  Widget _buildQuestionsSection() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      ...questions.asMap().entries.map((entry) {
        final index = entry.key;
        final question = entry.value;

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
                Expanded(
                  child: Text(
                    'السؤال ${index + 1}',
                    style: _labelStyle().copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    AuthTextField(
                      hint: 'نص السؤال',
                      controller: question['question']!,
                      validationFunction: (v) =>
                          v!.isEmpty ? 'أدخل نص السؤال' : null,
                      keyboardType: TextInputType.text,
                      maxLines: 2,
                    ),
                    const SizedBox(height: 8),
                    Text('الخيارات', style: _labelStyle()),
                    const SizedBox(height: 8),
                    ...((question['options'] as List<TextEditingController>?) ??
                            [])
                        .asMap()
                        .entries
                        .map((optEntry) {
                          final optIndex = optEntry.key;
                          final optController = optEntry.value;
                          final currentCorrectIndex =
                              question['correctAnswerIndex'] as int?;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: RadioGroup<int>(
                              groupValue: currentCorrectIndex,
                              onChanged: (value) {
                                setState(() {
                                  question['correctAnswerIndex'] = value;
                                });
                              },
                              child: Row(
                                children: [
                                  Radio<int>(
                                    value: optIndex,
                                    activeColor: AppColors.skyBlue,
                                  ),
                                  Expanded(
                                    child: AuthTextField(
                                      hint: 'الخيار ${optIndex + 1}',
                                      controller: optController,
                                      validationFunction: (v) => null,
                                      keyboardType: TextInputType.text,
                                    ),
                                  ),
                                  if ((question['options'] as List).length > 2)
                                    IconButton(
                                      onPressed: () {
                                        setState(() {
                                          if (currentCorrectIndex == optIndex) {
                                            question['correctAnswerIndex'] =
                                                null;
                                          } else if (currentCorrectIndex !=
                                                  null &&
                                              currentCorrectIndex > optIndex) {
                                            question['correctAnswerIndex'] =
                                                currentCorrectIndex - 1;
                                          }

                                          _removeOption(index, optIndex);
                                        });
                                      },
                                      icon: const Icon(
                                        FontAwesomeIcons.trashCan,
                                        size: 16,
                                        color: AppColors.posterRed,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        }),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _hoverButton(
                        'أضف خيار',
                        FontAwesomeIcons.plus,
                        () => _addOption(index),
                      ),
                    ),
                    const SizedBox(height: 8),
                    AuthTextField(
                      hint: 'الدرجة',
                      controller: question['mark']!,
                      validationFunction: (v) =>
                          v!.isEmpty ? 'أدخل الدرجة' : null,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(
                          FontAwesomeIcons.trashCan,
                          color: AppColors.posterRed,
                          size: 16,
                        ),
                        onPressed: () => _removeQuestion(index),
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
        child: _hoverButton('أضف سؤال', FontAwesomeIcons.plus, _addQuestion),
      ),
    ],
  );

  Widget _buildFooterSection(bool isLoading) => Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Expanded(
        child: AppSubButton(
          title: widget.existingExam != null ? 'حفظ التغييرات' : 'نشر الامتحان',
          backgroundColor: AppColors.royalBlue,
          state: isLoading ? SubButtonState.loading : SubButtonState.idle,
          onTap: () {
            if (!_formKey.currentState!.validate()) return;

            // Validate that all questions have a correct answer selected
            for (int i = 0; i < questions.length; i++) {
              final q = questions[i];
              final correctAnswerIndex = q['correctAnswerIndex'] as int?;
              if (correctAnswerIndex == null) {
                DashboardHelper.showErrorBar(
                  context,
                  error: 'يرجى تحديد الإجابة الصحيحة للسؤال ${i + 1}',
                );
                return;
              }
            }

            final exam = _buildExamModel();

            if (widget.existingExam != null) {
              context.read<AdminFunctionsCubit>().saveExamUpdates(exam: exam);
            } else {
              context.read<AdminFunctionsCubit>().publishExam(exam: exam);
            }

            // Call callbacks if provided
            if (widget.onSaveUpdates != null && widget.existingExam != null) {
              widget.onSaveUpdates!(exam);
            } else if (widget.onPublish != null &&
                widget.existingExam == null) {
              widget.onPublish!();
            }
          },
        ),
      ),
      const SizedBox(width: 6),
      _hoverButton('إلغاء', FontAwesomeIcons.xmark, () {
        Navigator.of(context).pop();
      }),
    ],
  );
}
