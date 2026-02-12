import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mrmichaelashrafdashboard/core/config/app_strings.dart';
import 'package:mrmichaelashrafdashboard/core/enums/grade.dart';
import 'package:mrmichaelashrafdashboard/core/enums/highlights_types.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/logic/admin_highlights_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/logic/admin_highlights_state.dart';
import 'package:mrmichaelashrafdashboard/shared/components/auth_text_field.dart';
import 'package:mrmichaelashrafdashboard/shared/components/manager_layout.dart';
import 'package:mrmichaelashrafdashboard/shared/components/picker_field.dart';
import 'package:mrmichaelashrafdashboard/shared/components/date_picker_field.dart';
import 'package:mrmichaelashrafdashboard/core/config/app_assets.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/data/models/highlight.dart';

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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AdminHighlightsCubit, AdminHighlightsState>(
      listener: (context, state) {
        if (state is HighlightPublished || state is HighlightUpdatesSaved) {
          if (context.mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
          }
          DashboardHelper.showSuccessBar(
            context,
            message: AppStrings.success.highlightPublished,
          );
        } else if (state is HighlightUpdatesSaved) {
          // This block seems unreachable/redundant as HighlightUpdatesSaved is caught above,
          // but preserving logic just in case (though previous logic had duplicate checks).
          // Simplified to match intent.
        } else if (state is HighlightDeleted) {
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
        } else if (state is HighlightsError) {
          DashboardHelper.showErrorBar(context, error: state.message);
        }
      },
      builder: (context, state) {
        final isLoading =
            state is PublishingHighlight ||
            state is SavingHighlightUpdates ||
            state is DeletingHighlight;

        return ManagerLayout(
          title: widget.existingHighlight != null
              ? 'تعديل الملاحظة'
              : 'الملاحظات',
          subtitle: widget.existingHighlight != null
              ? 'تعديل ملاحظة موجودة'
              : 'إرسال ملاحظات واخبار للمستخدمين',
          isEditing: isEditing,
          isLoading: isLoading,
          isExistingItem: widget.existingHighlight != null,
          onEditToggle: () => setState(() => isEditing = !isEditing),
          onDelete: () {
            context.read<AdminHighlightsCubit>().deleteHighlight(
              widget.existingHighlight!.id,
            );
          },
          onSave: () {
            if (_selectedGrade == null ||
                _selectedHighlightType == null ||
                _startDate == null ||
                _endDate == null ||
                _messageController.text.trim().isEmpty) {
              DashboardHelper.showErrorBar(
                context,
                error: AppStrings.errors.requiredFieldsNotFilled,
              );
              return;
            }

            if (widget.existingHighlight != null) {
              context.read<AdminHighlightsCubit>().saveHighlightUpdates(
                highlightId: widget.existingHighlight!.id,
                highlightText: _messageController.text.trim(),
                grade: _selectedGrade!.name,
                type: _selectedHighlightType!.name,
                startDate: Timestamp.fromDate(_startDate!),
                endDate: Timestamp.fromDate(_endDate!),
              );
            } else {
              context.read<AdminHighlightsCubit>().publishHighlight(
                highlightText: _messageController.text.trim(),
                grade: _selectedGrade!.name,
                type: _selectedHighlightType!.name,
                startDate: Timestamp.fromDate(_startDate!),
                endDate: Timestamp.fromDate(_endDate!),
              );
            }
          },
          onCancel: () {
            if (Navigator.canPop(context)) {
              Navigator.of(context).pop();
            }
          },
          saveButtonTitle: widget.existingHighlight != null
              ? 'حفظ التغييرات'
              : 'إرسال',
          deleteDescription: widget.existingHighlight != null
              ? 'هل أنت متأكد من حذف هذه الملاحظة؟\n\n'
                    '${widget.existingHighlight!.message.length > 50 ? widget.existingHighlight!.message.substring(0, 50) : widget.existingHighlight!.message}...'
              : '',
          deleteLottiePath: AppAssets.animations.emptyHighlightList,
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
              const SizedBox(height: 6),
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
              const SizedBox(height: 20),
              Text(
                'النوع',
                style: GoogleFonts.scheherazadeNew(
                  fontSize: 16,
                  color: AppColors.appWhite,
                ),
              ),
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
                      _selectedHighlightType = HighlightType.values.firstWhere(
                        (h) => h.label == value,
                        orElse: () => HighlightType.note,
                      );
                    });
                  }
                },
                hint: 'أختر نوع الملاحظة',
              ),
              const SizedBox(height: 20),
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
                  const SizedBox(height: 8),
                  DatePickerField(
                    key: ValueKey(
                      'startDate_${_startDate?.toString() ?? 'null'}',
                    ),
                    selectedDate: _startDate,
                    onDateChanged: (date) => setState(() => _startDate = date),
                    hint: 'اختر تاريخ البداية',
                    icon: FontAwesomeIcons.calendar,
                    firstDate: DateTime.now(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                'تاريخ النهاية',
                style: GoogleFonts.scheherazadeNew(
                  fontSize: 16,
                  color: AppColors.appWhite,
                ),
              ),
              const SizedBox(height: 8),
              DatePickerField(
                key: ValueKey('endDate_${_endDate?.toString() ?? 'null'}'),
                selectedDate: _endDate,
                onDateChanged: (date) => setState(() => _endDate = date),
                hint: 'اختر تاريخ النهاية',
                icon: FontAwesomeIcons.calendar,
                firstDate: _startDate ?? DateTime.now(),
              ),
              const SizedBox(height: 20),
              Text(
                'نص الملاحظة',
                style: GoogleFonts.scheherazadeNew(
                  fontSize: 16,
                  color: AppColors.appWhite,
                ),
              ),
              const SizedBox(height: 8),
              AuthTextField(
                hint: 'اكتب نص الملاحظة هنا...',
                keyboardType: TextInputType.multiline,
                controller: _messageController,
                validationFunction: (v) => null,
                maxLines: 3,
              ),
            ],
          ),
        );
      },
    );
  }
}
