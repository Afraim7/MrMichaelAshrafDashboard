import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';

class PickerField extends StatelessWidget {
  final List<String> pickerList;
  final void Function(String?) onChanged;
  final String hint;
  final IconData? icon;
  final bool? isDecorated;
  final Color? collapsedColor;
  final Color? expandedColor;
  final Color? highlightColor;
  final String? currentValue;

  const PickerField({
    super.key,
    required this.pickerList,
    required this.onChanged,
    required this.hint,
    this.icon,
    this.isDecorated = true,
    this.collapsedColor,
    this.expandedColor,
    this.highlightColor,
    this.currentValue,
  });

  @override
  Widget build(BuildContext context) {
    final defaultCollapsed = AppColors.neutra2000;
    final defaultHighlight = AppColors.appNavy.withAlpha(25);

    return Padding(
      padding: isDecorated!
          ? const EdgeInsets.symmetric(vertical: 9)
          : EdgeInsets.zero,
      child: CustomDropdown<String>(
        items: pickerList.isNotEmpty ? pickerList : null,
        onChanged: onChanged,
        hintText: hint,
        initialItem: currentValue,
        decoration: CustomDropdownDecoration(
          closedBorderRadius: BorderRadius.circular(18),
          expandedBorderRadius: BorderRadius.circular(18),

          closedSuffixIcon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.appWhite.withAlpha(230),
            size: 24,
          ),

          expandedSuffixIcon: Icon(
            Icons.keyboard_arrow_up_rounded,
            color: AppColors.appWhite.withAlpha(230),
            size: 24,
          ),

          prefixIcon: icon != null
              ? Icon(icon, color: AppColors.appWhite, size: 24)
              : null,

          closedFillColor: collapsedColor ?? defaultCollapsed,
          expandedFillColor: AppColors.surfaceDark.withAlpha(240),

          hintStyle: GoogleFonts.scheherazadeNew(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: AppColors.neutral300,
            height: 1.5,
          ),
          headerStyle: GoogleFonts.scheherazadeNew(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: AppColors.neutral300,
            height: 1.5,
          ),
          listItemStyle: GoogleFonts.scheherazadeNew(
            fontSize: 20,
            fontWeight: FontWeight.w300,
            color: AppColors.neutral300,
            height: 1.5,
          ),

          listItemDecoration: ListItemDecoration(
            highlightColor: defaultHighlight,
            splashColor: defaultHighlight,
            selectedColor: defaultHighlight,
            selectedIconColor: defaultHighlight,
          ),
        ),

        canCloseOutsideBounds: true,
        listItemPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        itemsListPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 16,
        ),
        closedHeaderPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 18,
        ),
        expandedHeaderPadding: const EdgeInsets.all(16),
        hideSelectedFieldWhenExpanded: false,
      ),
    );
  }
}
