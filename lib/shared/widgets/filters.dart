import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';

class FilterItem<T> {
  const FilterItem({
    required this.value,
    required this.title,
    this.icon,
    this.color,
  });

  final T value;
  final String title;
  final IconData? icon;
  final Color? color;
}

class Filters<T> extends StatelessWidget {
  const Filters({
    super.key,
    required this.items,
    required this.selectedFilter,
    required this.onChanged,
    this.height = 42,
    this.selectedColor = AppColors.royalBlue,
    this.horizontalPadding = 24,
  });

  final List<FilterItem<T>> items;
  final T selectedFilter;
  final ValueChanged<T> onChanged;

  final double height;
  final double horizontalPadding;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(16);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: SizedBox(
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsetsDirectional.only(start: 4, end: 4),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final item = items[index];
            final isSelected = item.value == selectedFilter;

            final accent = item.color ?? selectedColor;

            return Material(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: radius),
              clipBehavior: Clip.antiAlias,
              child: Ink(
                decoration: BoxDecoration(
                  color: isSelected
                      ? accent
                      : AppColors.cardDark.withAlpha(102),
                  borderRadius: radius,
                  border: isSelected
                      ? null
                      : Border.all(color: accent.withAlpha(40)),
                ),
                child: InkWell(
                  borderRadius: radius,
                  onTap: () {
                    if (isSelected) return;

                    HapticFeedback.selectionClick();
                    onChanged(item.value);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.fastEaseInToSlowEaseOut,
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 4,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (item.icon != null) ...[
                          Icon(
                            item.icon,
                            size: 14,
                            color: isSelected ? AppColors.appWhite : accent,
                          ),
                          const SizedBox(width: 8),
                        ],

                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.fastEaseInToSlowEaseOut,
                          style: GoogleFonts.scheherazadeNew(
                            fontSize: isSelected ? 15 : 14,
                            fontWeight: isSelected
                                ? FontWeight.w500
                                : FontWeight.w300,
                            color: isSelected
                                ? AppColors.appWhite
                                : AppColors.neutral300,
                          ),
                          child: Text(item.title, textAlign: TextAlign.center),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
