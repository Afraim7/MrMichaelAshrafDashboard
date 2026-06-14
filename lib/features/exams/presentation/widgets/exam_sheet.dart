import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_strings.dart';
import 'package:mrmichaelashrafdashboard/core/enums/grade.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/app_validator.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/features/exams/logic/exams_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/exams/logic/exams_state.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/admin_hover_button.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/auth_text_field.dart';
import 'package:mrmichaelashrafdashboard/shared/dialogs/dashboard_sheet.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/picker_field.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/date_picker_field.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_assets.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/exam.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/question.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/sheet_section_header.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/sheet_sub_section_label.dart';

class ExamSheet extends StatefulWidget {
  final Exam? existingExam;
  final Function(Exam)? onSaveUpdates;
  final Function()? onPublish;
  final Function()? onDelete;

  const ExamSheet({
    super.key,
    this.existingExam,
    this.onSaveUpdates,
    this.onPublish,
    this.onDelete,
  });

  @override
  State<ExamSheet> createState() => _ExamsManagerState();
}

class _ExamsManagerState extends State<ExamSheet> {
  late TextEditingController titleController;
  late TextEditingController durationController;
  late TextEditingController maxTrialsController;
  bool isEditing = false;
  bool _hasUnsavedChanges = false;

  /// "Armed" state for the tap-twice-to-confirm close pattern — mirrors the
  /// same flow used in CoursesManager / HighlightsManager so admins get one
  /// consistent UX across every form sheet.
  bool _confirmedClose = false;

  Grade? selectedGrade;
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
      // Default to a single attempt — the most common configuration. Admins
      // override per-exam from the form when they want re-takes.
      maxTrialsController = TextEditingController(text: '1');

      // Populate FIRST — `_loadExistingExam` calls `.text = ...` which would
      // otherwise fire every listener and mark the form dirty on open.
      if (widget.existingExam != null) {
        isEditing = false; // Start in view mode for existing exams
        _loadExistingExam();
      } else {
        isEditing = true; // New exams start in edit mode
        _addQuestion();
      }

      // Attach the dirty-tracker AFTER load so it only fires for real edits.
      titleController.addListener(_onFieldChanged);
      durationController.addListener(_onFieldChanged);
      maxTrialsController.addListener(_onFieldChanged);
    } catch (e) {
      debugPrint('Error initializing ExamsManager: $e');
    }
  }

  /// Single close-flow entry point — see CoursesManager._attemptClose for the
  /// full rationale of the tap-twice-to-confirm pattern.
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
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) setState(() => _confirmedClose = false);
    });
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
      // Default back to "1" when an older exam has no trials value persisted —
      // matches the form's new-exam default so the field is never blank.
      maxTrialsController.text = (e.maxTrials ?? 1).toString();
      selectedGrade = e.grade;
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
            'questionID': TextEditingController(text: q.questionID),
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

    // State is now computed dynamically, so we don't save it
    // Set to null - it will be computed when loading exams

    // Parse duration
    int? examDuration;
    if (durationController.text.trim().isNotEmpty) {
      examDuration = int.tryParse(durationController.text.trim());
    }

    // Parse maxTrials — clamp to >= 1 so an admin can't accidentally lock the
    // exam by typing "0". Blank / non-numeric falls back to the default 1.
    final parsedTrials = int.tryParse(maxTrialsController.text.trim());
    final examMaxTrials = (parsedTrials == null || parsedTrials < 1)
        ? 1
        : parsedTrials;

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
        questionID:
            q['questionID']?.text ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        question: q['question']?.text.trim() ?? '',
        mark: mark,
        options: options?.isNotEmpty == true ? options : null,
        correctAnswer: correctAnswer,
      );
    }).toList();

    return Exam(
      examID:
          widget.existingExam?.examID ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      title: titleController.text.trim(),
      state: null,
      // New exams start hidden — the admin reviews then toggles them visible
      // from the card. Editing preserves the current flag.
      isVisible: widget.existingExam?.isVisible ?? false,
      grade: selectedGrade ?? Grade.allGrades,
      startTime: startTime,
      endTime: endTime,
      duration: examDuration,
      questions: examQuestions,
      maxTrials: examMaxTrials,
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    durationController.dispose();
    maxTrialsController.dispose();
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
    return BlocConsumer<ExamsCubit, ExamsState>(
      listener: (context, state) {
        if (state is PublishExamSuccess || state is SaveExamUpdatesSuccess) {
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          DashboardHelper.showSuccessBar(
            context,
            message: widget.existingExam != null
                ? AppStrings.success.updatesSaved
                : AppStrings.success.examPublished,
          );
        } else if (state is DeleteExamSuccess) {
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
        } else if (state.errorMessage != null) {
          DashboardHelper.showErrorBar(context, error: state.errorMessage!);
        }
      },
      builder: (context, state) {
        final isLoading =
            state is PublishExamLoading ||
            state is SaveExamUpdatesLoading ||
            state is DeleteExamLoading;

        return PopScope(
          canPop: !_hasUnsavedChanges || _confirmedClose,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _attemptClose();
          },
          child: DashboardSheet(
            title: widget.existingExam != null
                ? 'تعديل الامتحان'
                : 'إضافة امتحان جديد',
            isEditing: isEditing,
            isSaving: isLoading,
            isExistingItem: widget.existingExam != null,
            onEditToggle: () => setState(() => isEditing = !isEditing),
            onDelete: () {
              context.read<ExamsCubit>().deleteExam(
                examId: widget.existingExam!.examID,
              );
              if (widget.onDelete != null) {
                widget.onDelete!();
              }
            },
            onSave: () {
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

              // Guard: publishing an exam with zero total marks means students
              // can never pass it (any score / 0 = NaN, badges break, results
              // sheet's pass-rate divides by zero). Catch it here so admins get
              // a clear message instead of a silently broken exam.
              if (exam.fullExamMark() <= 0) {
                DashboardHelper.showErrorBar(
                  context,
                  error:
                      'إجمالي درجات الامتحان يجب أن يكون أكبر من صفر. تأكد من إدخال درجة لكل سؤال.',
                );
                return;
              }

              if (widget.existingExam != null) {
                context.read<ExamsCubit>().saveExamUpdates(exam: exam);
              } else {
                context.read<ExamsCubit>().publishExam(exam: exam);
              }

              // Call callbacks if provided
              if (widget.onSaveUpdates != null && widget.existingExam != null) {
                widget.onSaveUpdates!(exam);
              } else if (widget.onPublish != null &&
                  widget.existingExam == null) {
                widget.onPublish!();
              }
            },
            onCancel: _attemptClose,
            saveButtonTitle: widget.existingExam != null
                ? 'حفظ التغييرات'
                : 'نشر الامتحان',
            deleteDescription:
                'هل أنت متأكد من حذف هذا الامتحان؟ سيتم حذف جميع بياناته نهائياً.',
            deleteLottiePath: AppAssets.animations.emptyExamsList,
            body: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SheetSectionHeader(
                    label: 'معلومات الامتحان',
                    icon: Icons.info_outline_rounded,
                  ),
                  const SizedBox(height: 10),
                  _buildExamInfo(),
                  const SizedBox(height: 50),
                  SheetSectionHeader(
                    label: 'الأسئلة',
                    icon: Icons.question_answer,
                  ),
                  const SizedBox(height: 10),
                  _buildQuestionsSection(),
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

  Widget _buildExamInfo() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SheetSubSectionLabel(label: 'عنوان الامتحان'),
      const SizedBox(height: 8),
      AuthTextField(
        hint: 'مثلاً: امتحان منتصف الفصل في الفيزياء',
        controller: titleController,
        keyboardType: TextInputType.text,
        validationFunction: AppValidator.validateCourseTitle,
      ),
      const SizedBox(height: 8),
      const SheetSubSectionLabel(label: 'الصف الدراسي'),
      const SizedBox(height: 8),
      PickerField(
        hint: 'أختر الصف الدراسي',
        pickerList: Grade.values.map((g) => g.label).toList(),
        currentValue: selectedGrade?.label,
        onChanged: (v) {
          if (v != null) {
            setState(
              () =>
                  selectedGrade = Grade.values.firstWhere((g) => g.label == v),
            );
          }
        },
      ),
      const SizedBox(height: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetSubSectionLabel(label: 'تاريخ ووقت البداية'),
          const SizedBox(height: 8),
          DatePickerField(
            selectedDate: startTime,
            onDateChanged: (date) => setState(() => startTime = date),
            hint: 'اختر تاريخ ووقت البداية',
            icon: FontAwesomeIcons.calendar,
            firstDate: DateTime.now(),
            withTime: true,
          ),
        ],
      ),
      const SizedBox(height: 8),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SheetSubSectionLabel(label: 'تاريخ ووقت النهاية'),
          const SizedBox(height: 8),
          DatePickerField(
            selectedDate: endTime,
            onDateChanged: (date) => setState(() => endTime = date),
            hint: 'اختر تاريخ ووقت النهاية',
            icon: FontAwesomeIcons.calendar,
            firstDate: startTime ?? DateTime.now(),
            withTime: true,
          ),
        ],
      ),
      const SizedBox(height: 8),
      const SheetSubSectionLabel(label: 'المدة (بالدقائق)'),
      const SizedBox(height: 8),
      AuthTextField(
        hint: 'مثلاً: 45',
        keyboardType: TextInputType.number,
        controller: durationController,
        validationFunction: (v) => v!.isEmpty ? 'أدخل المدة بالدقائق' : null,
      ),
      const SizedBox(height: 8),
      const SheetSubSectionLabel(label: 'عدد المحاولات المسموح بها'),
      const SizedBox(height: 8),
      AuthTextField(
        hint: 'الافتراضي: 1',
        keyboardType: TextInputType.number,
        controller: maxTrialsController,
        // Soft validation: empty / "0" silently coerce to 1 on save (see
        // `_buildExamModel`). The validator only rejects non-numeric input.
        validationFunction: (v) {
          final t = v?.trim() ?? '';
          if (t.isEmpty) return null;
          final n = int.tryParse(t);
          if (n == null) return 'أدخل رقمًا صحيحًا';
          return null;
        },
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
                    const SheetSubSectionLabel(label: 'الخيارات'),
                    const SizedBox(height: 8),
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
                      child: AdminHoverButton(
                        title: 'أضف خيار',
                        icon: FontAwesomeIcons.plus,
                        onTap: () => _addOption(index),
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
        child: AdminHoverButton(
          title: 'أضف سؤال',
          icon: FontAwesomeIcons.plus,
          onTap: _addQuestion,
        ),
      ),
    ],
  );
}
