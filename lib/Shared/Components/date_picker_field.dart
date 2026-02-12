import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';

class DatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final void Function(DateTime?) onDateChanged;
  final String hint;
  final IconData? icon;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DatePickerField({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    required this.hint,
    this.icon,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: InkWell(
        onTap: () => _selectDate(context),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          decoration: BoxDecoration(
            color: AppColors.neutra2000,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.strokeHairlineDark, width: 1),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.appWhite, size: 24),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Text(
                  selectedDate != null
                      ? DateFormat('yyyy/MM/dd').format(selectedDate!)
                      : hint,
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                    color: selectedDate != null
                        ? AppColors.appWhite
                        : AppColors.neutral300,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    // 🔥 FIX: ensure initialDate is ALWAYS >= firstDate
    DateTime safeInitial = selectedDate ?? DateTime.now();

    if (firstDate != null && safeInitial.isBefore(firstDate!)) {
      safeInitial = firstDate!;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: safeInitial,
      firstDate: firstDate ?? DateTime(2010),
      lastDate: lastDate ?? DateTime(2050),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.royalBlue,
              onPrimary: AppColors.appWhite,
              surface: AppColors.surfaceDark,
              onSurface: AppColors.appWhite,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.surfaceDark,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      onDateChanged(picked);
    }
  }
}
