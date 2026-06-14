import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_strings.dart';
import 'package:mrmichaelashrafdashboard/core/enums/grade.dart';
import 'package:mrmichaelashrafdashboard/core/enums/highlights_types.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/logic/highlights_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/logic/highlights_state.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/auth_text_field.dart';
import 'package:mrmichaelashrafdashboard/shared/dialogs/dashboard_sheet.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/picker_field.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/date_picker_field.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/sheet_sub_section_label.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_assets.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/data/models/highlight.dart';

class HighlightSheet extends StatefulWidget {
  final Highlight? existingHighlight;

  const HighlightSheet({super.key, this.existingHighlight});

  @override
  State<HighlightSheet> createState() => _HighlightsManagerState();
}

class _HighlightsManagerState extends State<HighlightSheet> {
  final TextEditingController _messageController = TextEditingController();
  Grade? _selectedGrade;
  HighlightType? _selectedHighlightType;
  DateTime? _startDate;
  DateTime? _endDate;
  bool isEditing = false;

  /// True once any field has been touched. Drives the discard-warning flow.
  bool _hasUnsavedChanges = false;

  /// Armed by the first close attempt so the second one actually pops.
  bool _confirmedClose = false;

  // ─── Per-field validation errors ───────────────────────────────────────
  // Each is null when valid, or a localized error string when not.
  // Populated by [_validateFields] on save and cleared as the user edits.
  String? _gradeError;
  String? _typeError;
  String? _startDateError;
  String? _endDateError;
  String? _messageError;

  @override
  void initState() {
    super.initState();
    // Populate FIRST — `_loadExistingHighlight` calls
    // `_messageController.text = ...` which would otherwise fire the listener
    // and mark the form dirty on open.
    if (widget.existingHighlight != null) {
      isEditing = false; // Start in view mode for existing highlights
      _loadExistingHighlight();
    } else {
      isEditing = true; // New highlights start in edit mode
    }
    // Attach the dirty-tracker AFTER load so it only fires for real edits.
    _messageController.addListener(_onFieldChanged);
    // Also clear the inline message error the moment the admin types.
    _messageController.addListener(_clearMessageError);
  }

  /// Flip the dirty flag on first change. Cheap — only setState's once.
  void _onFieldChanged() {
    if (!_hasUnsavedChanges) {
      setState(() => _hasUnsavedChanges = true);
    }
  }

  /// Runs all 5 field rules and writes the results into the per-field error
  /// slots. Returns `true` when every field is valid. Called from the save
  /// handler so the admin gets inline red text next to the offending field
  /// instead of a generic "fill all" snackbar.
  bool _validateFields() {
    final gradeError = _selectedGrade == null
        ? 'يرجى اختيار الصف الدراسي'
        : null;
    final typeError = _selectedHighlightType == null
        ? 'يرجى اختيار نوع الملاحظة'
        : null;
    final startError = _startDate == null ? 'يرجى تحديد تاريخ البداية' : null;
    String? endError;
    if (_endDate == null) {
      endError = 'يرجى تحديد تاريخ النهاية';
    } else if (_startDate != null && _endDate!.isBefore(_startDate!)) {
      // Catch the case where the admin picked End before Start — common
      // mistake, the date pickers don't enforce this on their own once
      // dates are already set.
      endError = 'تاريخ النهاية يجب أن يكون بعد تاريخ البداية';
    }
    final messageError = _messageController.text.trim().isEmpty
        ? 'يرجى كتابة نص الملاحظة'
        : null;

    setState(() {
      _gradeError = gradeError;
      _typeError = typeError;
      _startDateError = startError;
      _endDateError = endError;
      _messageError = messageError;
    });

    return gradeError == null &&
        typeError == null &&
        startError == null &&
        endError == null &&
        messageError == null;
  }

  /// Listener attached to the message controller so red text disappears
  /// the moment the admin starts typing.
  void _clearMessageError() {
    if (_messageError != null && _messageController.text.trim().isNotEmpty) {
      setState(() => _messageError = null);
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

  void _loadExistingHighlight() {
    final highlight = widget.existingHighlight!;
    _messageController.text = highlight.message;
    _selectedGrade = highlight.grade;
    _selectedHighlightType = highlight.type;
    _startDate = highlight.startTime;
    _endDate = highlight.endTime;
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HighlightsCubit, HighlightsState>(
      listener: (context, state) {
        if (state is PublishHighlightSuccess ||
            state is SaveHighlightUpdatesSuccess) {
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          DashboardHelper.showSuccessBar(
            context,
            message: AppStrings.success.highlightPublished,
          );
        } else if (state is DeleteHighlightSuccess) {
          // Close the confirm dialog (if still up) and the sheet itself.
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          DashboardHelper.showSuccessBar(
            context,
            message: AppStrings.success.highlightDeleted,
          );
        } else if (state.errorMessage != null) {
          DashboardHelper.showErrorBar(context, error: state.errorMessage!);
        }
      },
      builder: (context, state) {
        final isLoading =
            state is PublishHighlightLoading ||
            state is SaveHighlightUpdatesLoading ||
            state is DeleteHighlightLoading;

        return PopScope(
          canPop: !_hasUnsavedChanges || _confirmedClose,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _attemptClose();
          },
          child: DashboardSheet(
            title: widget.existingHighlight != null
                ? 'تعديل الملاحظة'
                : 'الملاحظات',

            isEditing: isEditing,
            isSaving: isLoading,
            isExistingItem: widget.existingHighlight != null,
            onEditToggle: () => setState(() => isEditing = !isEditing),
            onDelete: () {
              context.read<HighlightsCubit>().deleteHighlight(
                widget.existingHighlight!.id,
              );
            },
            onSave: () {
              // Per-field validation drives red inline messages under each
              // input so the admin sees exactly which field needs attention.
              if (!_validateFields()) return;

              if (widget.existingHighlight != null) {
                context.read<HighlightsCubit>().saveHighlightUpdates(
                  highlightId: widget.existingHighlight!.id,
                  highlightText: _messageController.text.trim(),
                  grade: _selectedGrade!.name,
                  type: _selectedHighlightType!.name,
                  startDate: Timestamp.fromDate(_startDate!),
                  endDate: Timestamp.fromDate(_endDate!),
                );
              } else {
                context.read<HighlightsCubit>().publishHighlight(
                  highlightText: _messageController.text.trim(),
                  grade: _selectedGrade!.name,
                  type: _selectedHighlightType!.name,
                  startDate: Timestamp.fromDate(_startDate!),
                  endDate: Timestamp.fromDate(_endDate!),
                );
              }
            },
            onCancel: _attemptClose,
            saveButtonTitle: widget.existingHighlight != null
                ? 'حفظ التغييرات'
                : 'إرسال',
            deleteDescription: widget.existingHighlight != null
                ? 'هل أنت متأكد من حذف هذه الملاحظة؟\n\n'
                      '${widget.existingHighlight!.message.length > 50 ? widget.existingHighlight!.message.substring(0, 50) : widget.existingHighlight!.message}...'
                : '',
            deleteLottiePath: AppAssets.animations.emptyHighlightList,
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SheetSubSectionLabel(label: 'الصف الدراسي'),
                const SizedBox(height: 8),
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
                        _gradeError = null; // clear inline error on pick
                      });
                      _onFieldChanged();
                    }
                  },
                  hint: 'أختر الصف الدراسي',
                ),
                _FieldError(message: _gradeError),
                const SizedBox(height: 20),
                const SheetSubSectionLabel(label: 'النوع'),
                const SizedBox(height: 8),
                PickerField(
                  key: ValueKey(
                    'type_${_selectedHighlightType?.label ?? 'null'}',
                  ),
                  pickerList: HighlightType.values.map((h) => h.label).toList(),
                  currentValue: _selectedHighlightType?.label,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedHighlightType = HighlightType.values
                            .firstWhere(
                              (h) => h.label == value,
                              orElse: () => HighlightType.note,
                            );
                        _typeError = null;
                      });
                      _onFieldChanged();
                    }
                  },
                  hint: 'أختر نوع الملاحظة',
                ),
                _FieldError(message: _typeError),
                const SizedBox(height: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SheetSubSectionLabel(label: 'تاريخ البداية'),
                    const SizedBox(height: 8),
                    DatePickerField(
                      key: ValueKey(
                        'startDate_${_startDate?.toString() ?? 'null'}',
                      ),
                      selectedDate: _startDate,
                      onDateChanged: (date) {
                        setState(() {
                          _startDate = date;
                          _startDateError = null;
                          // Picking a new start may invalidate the end again
                          // — clear so the rule re-runs on next save.
                          if (_endDate != null &&
                              date != null &&
                              !_endDate!.isBefore(date)) {
                            _endDateError = null;
                          }
                        });
                        _onFieldChanged();
                      },
                      hint: 'اختر تاريخ البداية',
                      icon: FontAwesomeIcons.calendar,
                      firstDate: DateTime.now(),
                    ),
                    _FieldError(message: _startDateError),
                  ],
                ),
                const SizedBox(height: 20),
                const SheetSubSectionLabel(label: 'تاريخ النهاية'),
                const SizedBox(height: 8),
                DatePickerField(
                  key: ValueKey('endDate_${_endDate?.toString() ?? 'null'}'),
                  selectedDate: _endDate,
                  onDateChanged: (date) {
                    setState(() {
                      _endDate = date;
                      _endDateError = null;
                    });
                    _onFieldChanged();
                  },
                  hint: 'اختر تاريخ النهاية',
                  icon: FontAwesomeIcons.calendar,
                  firstDate: _startDate ?? DateTime.now(),
                ),
                _FieldError(message: _endDateError),
                const SizedBox(height: 20),
                const SheetSubSectionLabel(label: 'نص الملاحظة'),
                const SizedBox(height: 8),
                AuthTextField(
                  hint: 'اكتب نص الملاحظة هنا...',
                  keyboardType: TextInputType.multiline,
                  controller: _messageController,
                  validationFunction: (v) => null,
                  maxLines: 3,
                ),
                _FieldError(message: _messageError),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Tiny inline error label rendered under each highlight form field.
/// When [message] is null this renders nothing (zero height), so adding it
/// after every input is free in the happy-path layout.
class _FieldError extends StatelessWidget {
  final String? message;
  const _FieldError({required this.message});

  @override
  Widget build(BuildContext context) {
    if (message == null || message!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(top: 6, right: 4),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 13,
            color: AppColors.tomatoRed,
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              message!,
              style: GoogleFonts.amiri(
                fontSize: 12,
                color: AppColors.tomatoRed,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
