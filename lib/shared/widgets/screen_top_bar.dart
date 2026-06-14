import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/enums/button_state.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/features/home/data/models/top_bar_action.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/app_sub_button.dart';

class ScreenTopBar extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<TopBarAction>? actions;

  const ScreenTopBar({
    super.key,
    required this.title,
    required this.subtitle,
    this.actions,
  });

  bool _isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 900;

  @override
  Widget build(BuildContext context) {
    final isCompact = _isCompact(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 40),
      child: isCompact
          ? _buildCompactLayout(context)
          : _buildDesktopLayout(context),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        _buildTitleSection(
          crossAxisAlignment: CrossAxisAlignment.start,
          textAlign: TextAlign.start,
        ),

        const Spacer(),

        if (actions?.isNotEmpty ?? false)
          Wrap(spacing: 8, runSpacing: 8, children: _buildActions()),
      ],
    );
  }

  Widget _buildCompactLayout(BuildContext context) {
    return Align(
      alignment: AlignmentGeometry.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildTitleSection(
            crossAxisAlignment: CrossAxisAlignment.center,
            textAlign: TextAlign.center,
          ),

          if (actions?.isNotEmpty ?? false) ...[
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: _buildActions(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTitleSection({
    required CrossAxisAlignment crossAxisAlignment,
    required TextAlign textAlign,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: crossAxisAlignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          textAlign: textAlign,
          style: GoogleFonts.scheherazadeNew(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.appWhite,
          ),
        ),

        const SizedBox(height: 6),

        Flexible(
          child: Text(
            subtitle,
            textAlign: textAlign,
            style: GoogleFonts.scheherazadeNew(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondaryDark,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActions() {
    return actions!
        .map(
          (action) => AppSubButton(
            title: action.label,
            onTap: action.onPressed,
            backgroundColor: action.isPrimary
                ? AppColors.royalBlue
                : AppColors.midBlue.withAlpha(40),
            state: ButtonState.idle,
            titleColor: AppColors.appWhite,
            height: 42,
            width: 170,
            borderRadius: 14,
            // Removed fixed width to prevent overflow
          ),
        )
        .toList();
  }
}
