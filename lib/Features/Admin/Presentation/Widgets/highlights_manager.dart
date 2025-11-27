import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mrmichaelashrafdashboard/Core/Config/app_gaps.dart';
import 'package:mrmichaelashrafdashboard/Core/Config/app_strings.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/grade.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/highlights_types.dart';
import 'package:mrmichaelashrafdashboard/Core/Themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/sub_button_state.dart';
import 'package:mrmichaelashrafdashboard/Core/Utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/Features/Admin/Logic/Cubits/AdminFunctions/admin_functions_cubit.dart';
import 'package:mrmichaelashrafdashboard/Shared/Components/auth_text_field.dart';
import 'package:mrmichaelashrafdashboard/Shared/Components/app_sub_button.dart';
import 'package:mrmichaelashrafdashboard/Shared/Components/picker_field.dart';
import 'package:mrmichaelashrafdashboard/Shared/Components/date_picker_field.dart';
import 'package:mrmichaelashrafdashboard/Shared/Components/app_dialog.dart';
import 'package:mrmichaelashrafdashboard/Core/Config/app_assets.dart';
import 'package:mrmichaelashrafdashboard/Shared/Models/highlight.dart';

class HighlightsManager extends StatefulWidget {
  final Highlight? existingHighlight;

  const HighlightsManager({super.key, this.existingHighlight});

  @override
  State<HighlightsManager> createState() => _HighlightsManagerState();
}

class _HighlightsManagerState extends State<HighlightsManager> {
  final TextEditingController _messageController = TextEditingController();
  Grade? _selectedGrade;
  HighlightType? _selectedHighlightType;
  DateTime? _startDate;
  DateTime? _endDate;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingHighlight != null) {
      isEditing = false; // Start in view mode for existing highlights
      _loadExistingHighlight();
    } else {
      isEditing = true; // New highlights start in edit mode
    }
  }

  void _loadExistingHighlight() {
    final highlight = widget.existingHighlight!;
    _messageController.text = highlight.message;
    _selectedGrade = highlight.grade;
    _selectedHighlightType = highlight.type;
    _startDate = highlight.startTime;
    _endDate = highlight.endTime;
  }

  void _clearFields() {
    _messageController.clear();
    setState(() {
      _selectedGrade = null;
      _selectedHighlightType = null;
      _startDate = null;
      _endDate = null;
    });
  }

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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminFunctionsCubit, AdminFunctionsState>(
      listener: (context, state) {
        if (state is AdminHighlightPublished) {
          _clearFields();
          AppHelper.showSuccessBar(
            context,
            message: AppStrings.success.highlightPublished,
          );
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        } else if (state is AdminHighlightUpdatesSaved) {
          AppHelper.showSuccessBar(
            context,
            message: AppStrings.success.highlightPublished,
          );
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        } else if (state is AdminHighlightDeleted) {
          AppHelper.showSuccessBar(
            context,
            message: AppStrings.success.highlightDeleted,
          );
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        } else if (state is AdminFunctionsError) {
          AppHelper.showErrorBar(context, error: state.error);
        }
      },
      builder: (context, state) {
        final isLoading =
            state is AdminPublishingHighlight ||
            state is AdminSavingHighlightUpdates ||
            state is AdminDeletingHighlight;
        final shouldDisable = widget.existingHighlight != null && !isEditing;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔔 Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: widget.existingHighlight != null
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
                      isEditing
                          ? FontAwesomeIcons.check
                          : FontAwesomeIcons.penToSquare,
                      key: ValueKey(isEditing),
                      color: AppColors.skyBlue.withOpacity(
                        widget.existingHighlight != null ? 1.0 : 0.3,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        widget.existingHighlight != null
                            ? 'تعديل الملاحظة'
                            : 'الملاحظات',
                        style: GoogleFonts.scheherazadeNew(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.appWhite,
                          height: 1.7,
                        ),
                      ),
                      Text(
                        widget.existingHighlight != null
                            ? 'تعديل ملاحظة موجودة'
                            : 'إرسال ملاحظات واخبار للمستخدمين',
                        style: GoogleFonts.scheherazadeNew(
                          fontSize: 14,
                          color: AppColors.textSecondaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                // Delete button - only shown when editing existing highlight
                IconButton(
                  icon: Icon(
                    FontAwesomeIcons.trashCan,
                    color: AppColors.posterRed.withOpacity(
                      (widget.existingHighlight != null && isEditing)
                          ? 1.0
                          : 0.3,
                    ),
                  ),
                  onPressed: (widget.existingHighlight != null && isEditing)
                      ? () {
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (dialogContext) =>
                                BlocListener<
                                  AdminFunctionsCubit,
                                  AdminFunctionsState
                                >(
                                  listener: (context, state) {
                                    if (state is AdminHighlightDeleted) {
                                      Future.microtask(() {
                                        if (Navigator.canPop(dialogContext)) {
                                          Navigator.of(dialogContext).pop();
                                        }
                                      });
                                    } else if (state is AdminFunctionsError) {
                                      AppHelper.showErrorBar(
                                        context,
                                        error: state.error,
                                      );
                                    }
                                  },
                                  child: AppDialog(
                                    header: 'حذف الملاحظة',
                                    description:
                                        'هل أنت متأكد من حذف هذه الملاحظة؟\n\n'
                                        '${widget.existingHighlight!.message.length > 50 ? widget.existingHighlight!.message.substring(0, 50) : widget.existingHighlight!.message}...',
                                    lottiePath:
                                        AppAssets.animations.emptyCoursesList,
                                    onConfirm: () {
                                      context
                                          .read<AdminFunctionsCubit>()
                                          .deleteHighlight(
                                            widget.existingHighlight!.id,
                                          );
                                    },
                                    onConfirmState:
                                        state is AdminDeletingHighlight
                                        ? SubButtonState.loading
                                        : SubButtonState.idle,
                                    confirmTitle: 'حذف',
                                    cancelTitle: 'إلغاء',
                                  ),
                                ),
                          );
                        }
                      : null,
                ),
              ],
            ),
            AppGaps.v8,

            // 📩 Form
            AbsorbPointer(
              absorbing: isLoading || shouldDisable,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الصف الدراسي',
                    style: GoogleFonts.scheherazadeNew(
                      fontSize: 16,
                      color: AppColors.appWhite,
                    ),
                  ),
                  AppGaps.v2,
                  PickerField(
                    key: ValueKey('grade_${_selectedGrade?.label ?? 'null'}'),
                    pickerList: Grade.values.map((g) => g.label).toList(),
                    currentValue: _selectedGrade?.label,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedGrade = Grade.values.firstWhere(
                            (g) => g.label == value,
                            orElse: () => Grade.allGrades,
                          );
                        });
                      }
                    },
                    hint: 'أختر الصف الدراسي',
                  ),
                  AppGaps.v6,

                  Text(
                    'النوع',
                    style: GoogleFonts.scheherazadeNew(
                      fontSize: 16,
                      color: AppColors.appWhite,
                    ),
                  ),
                  AppGaps.v2,
                  PickerField(
                    key: ValueKey(
                      'type_${_selectedHighlightType?.label ?? 'null'}',
                    ),
                    pickerList: HighlightType.values
                        .map((h) => h.label)
                        .toList(),
                    currentValue: _selectedHighlightType?.label,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedHighlightType = HighlightType.values
                              .firstWhere(
                                (h) => h.label == value,
                                orElse: () => HighlightType.note,
                              );
                        });
                      }
                    },
                    hint: 'أختر نوع الملاحظة',
                  ),
                  AppGaps.v6,

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تاريخ البداية',
                        style: GoogleFonts.scheherazadeNew(
                          fontSize: 16,
                          color: AppColors.appWhite,
                        ),
                      ),
                      AppGaps.v2,
                      DatePickerField(
                        key: ValueKey(
                          'startDate_${_startDate?.toString() ?? 'null'}',
                        ),
                        selectedDate: _startDate,
                        onDateChanged: (date) =>
                            setState(() => _startDate = date),
                        hint: 'اختر تاريخ البداية',
                        icon: FontAwesomeIcons.calendar,
                        firstDate: DateTime.now(),
                      ),
                    ],
                  ),

                  AppGaps.v6,
                  Text(
                    'تاريخ النهاية',
                    style: GoogleFonts.scheherazadeNew(
                      fontSize: 16,
                      color: AppColors.appWhite,
                    ),
                  ),
                  AppGaps.v2,
                  DatePickerField(
                    key: ValueKey('endDate_${_endDate?.toString() ?? 'null'}'),
                    selectedDate: _endDate,
                    onDateChanged: (date) => setState(() => _endDate = date),
                    hint: 'اختر تاريخ النهاية',
                    icon: FontAwesomeIcons.calendar,
                    firstDate: _startDate ?? DateTime.now(),
                  ),

                  AppGaps.v6,

                  Text(
                    'نص الملاحظة',
                    style: GoogleFonts.scheherazadeNew(
                      fontSize: 16,
                      color: AppColors.appWhite,
                    ),
                  ),
                  AppGaps.v2,
                  AuthTextField(
                    hint: 'اكتب نص الملاحظة هنا...',
                    keyboardType: TextInputType.multiline,
                    controller: _messageController,
                    validationFunction: (v) => null,
                    maxLines: 3,
                  ),
                  AppGaps.v6,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: AppSubButton(
                          title: widget.existingHighlight != null
                              ? 'حفظ التغييرات'
                              : 'إرسال',
                          backgroundColor: AppColors.royalBlue,
                          state:
                              (state is AdminPublishingHighlight ||
                                  state is AdminSavingHighlightUpdates)
                              ? SubButtonState.loading
                              : SubButtonState.idle,
                          onTap: () {
                            if (_selectedGrade == null ||
                                _selectedHighlightType == null ||
                                _startDate == null ||
                                _endDate == null ||
                                _messageController.text.trim().isEmpty) {
                              AppHelper.showErrorBar(
                                context,
                                error:
                                    AppStrings.errors.requiredFieldsNotFilled,
                              );
                              return;
                            }

                            if (widget.existingHighlight != null) {
                              context
                                  .read<AdminFunctionsCubit>()
                                  .saveHighlightUpdates(
                                    highlightId: widget.existingHighlight!.id,
                                    highlightText: _messageController.text
                                        .trim(),
                                    grade: _selectedGrade!.name,
                                    type: _selectedHighlightType!.name,
                                    startDate: Timestamp.fromDate(_startDate!),
                                    endDate: Timestamp.fromDate(_endDate!),
                                  );
                            } else {
                              context
                                  .read<AdminFunctionsCubit>()
                                  .publishHighlight(
                                    highlightText: _messageController.text
                                        .trim(),
                                    grade: _selectedGrade!.name,
                                    type: _selectedHighlightType!.name,
                                    startDate: Timestamp.fromDate(_startDate!),
                                    endDate: Timestamp.fromDate(_endDate!),
                                  );
                            }
                          },
                        ),
                      ),
                      AppGaps.h2,
                      _hoverButton('إلغاء', FontAwesomeIcons.xmark, () {
                        if (Navigator.canPop(context)) {
                          Navigator.of(context).pop();
                        }
                      }),
                    ],
                  ),

                  AppGaps.v6,
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
