import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';

class AnalyticsCard extends StatefulWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const AnalyticsCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  State<AnalyticsCard> createState() => _AnalyticsCardState();
}

class _AnalyticsCardState extends State<AnalyticsCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: 175,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.neutra2000,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: _isHovered
                  ? widget.color.withAlpha(40)
                  : Colors.black.withAlpha(20),
              blurRadius: _isHovered ? 10 : 5,
              offset: Offset(0, _isHovered ? 8 : 5),
            ),
          ],
          border: Border.all(
            color: _isHovered
                ? widget.color.withAlpha(100)
                : widget.color.withAlpha(35),
            width: _isHovered ? 2 : 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _isHovered
                        ? widget.color.withAlpha(50)
                        : widget.color.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(widget.icon, color: widget.color, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Text(
              widget.value,
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.appWhite,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              widget.title,
              style: GoogleFonts.scheherazadeNew(
                fontSize: 16,
                color: AppColors.textSecondaryDark,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
