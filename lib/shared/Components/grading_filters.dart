import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/enums/grade.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';

class GradingFilters extends StatefulWidget {
  const GradingFilters({super.key, this.onChanged, this.selectedGrade});
  final ValueChanged<Grade>? onChanged;
  final Grade? selectedGrade;

  @override
  State<GradingFilters> createState() => _GrdadingFiltersState();
}

class _GrdadingFiltersState extends State<GradingFilters> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _updateSelectedIndex();
  }

  @override
  void didUpdateWidget(GradingFilters oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedGrade != widget.selectedGrade) {
      _updateSelectedIndex();
    }
  }

  void _updateSelectedIndex() {
    if (widget.selectedGrade != null) {
      setState(() {
        _selectedIndex = Grade.values.indexOf(widget.selectedGrade!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(20);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 4),
      child: SizedBox(
        height: 50,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsetsDirectional.only(start: 4, end: 4),
          itemCount: Grade.values.length,
          separatorBuilder: (_, _) => const SizedBox(width: 6),
          itemBuilder: (context, index) {
            final isSelected = _selectedIndex == index;

            return Material(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: radius),
              clipBehavior: Clip.antiAlias,
              child: Ink(
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.royalBlue
                      : AppColors.cardDark.withAlpha(102),
                  borderRadius: radius,
                ),
                child: InkWell(
                  borderRadius: radius,
                  onTap: () {
                    if (_selectedIndex == index) return;
                    HapticFeedback.selectionClick();
                    setState(() => _selectedIndex = index);
                    widget.onChanged?.call(Grade.values[index]);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.fastEaseInToSlowEaseOut,
                    height: 50,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 25,
                      vertical: 6,
                    ),
                    alignment: Alignment.center,
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.fastEaseInToSlowEaseOut,
                      style: GoogleFonts.scheherazadeNew(
                        fontSize: isSelected ? 20 : 16,
                        fontWeight: isSelected
                            ? FontWeight.w500
                            : FontWeight.w300,
                        color: isSelected
                            ? AppColors.appWhite
                            : AppColors.neutral300,
                      ),
                      child: Text(
                        Grade.values[index].label,
                        textAlign: TextAlign.center,
                      ),
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
