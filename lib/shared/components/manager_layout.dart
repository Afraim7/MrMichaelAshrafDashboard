import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/enums/sub_button_state.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/shared/components/admin_hover_button.dart';
import 'package:mrmichaelashrafdashboard/shared/components/app_dialog.dart';
import 'package:mrmichaelashrafdashboard/shared/components/app_sub_button.dart';

class ManagerLayout extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isEditing;
  final bool isLoading;
  final bool isExistingItem;
  final VoidCallback? onEditToggle;
  final VoidCallback onDelete;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final String saveButtonTitle;
  final Widget child;
  final String deleteDescription;
  final String deleteLottiePath;

  const ManagerLayout({
    super.key,
    required this.title,
    this.subtitle,
    required this.isEditing,
    required this.isLoading,
    required this.isExistingItem,
    this.onEditToggle,
    required this.onDelete,
    required this.onSave,
    required this.onCancel,
    required this.saveButtonTitle,
    required this.child,
    required this.deleteDescription,
    required this.deleteLottiePath,
  });

  @override
  Widget build(BuildContext context) {
    final shouldDisable = isExistingItem && !isEditing;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          const SizedBox(height: 20),
          AbsorbPointer(
            absorbing: isLoading || shouldDisable,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                child,
                const SizedBox(height: 30),
                if (isEditing) _buildFooter(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: isExistingItem && onEditToggle != null
              ? onEditToggle
              : null,
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) {
              return ScaleTransition(scale: animation, child: child);
            },
            child: Icon(
              isEditing ? FontAwesomeIcons.check : FontAwesomeIcons.penToSquare,
              key: ValueKey(isEditing),
              color: AppColors.skyBlue.withAlpha(isExistingItem ? 255 : 57),
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: GoogleFonts.scheherazadeNew(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.appWhite,
                  height: 1.7,
                ),
                textAlign: TextAlign.center,
              ),
              if (subtitle != null)
                Text(
                  subtitle!,
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 14,
                    color: AppColors.textSecondaryDark,
                  ),
                  textAlign: TextAlign.center,
                ),
            ],
          ),
        ),
        IconButton(
          icon: Icon(
            FontAwesomeIcons.trashCan,
            color: AppColors.posterRed.withAlpha(
              (isExistingItem && isEditing) ? 255 : 57,
            ),
          ),
          onPressed: (isExistingItem && isEditing)
              ? () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (dialogContext) => AppDialog(
                      header: 'تأكيد الحذف',
                      description: deleteDescription,
                      lottiePath: deleteLottiePath,
                      onConfirm: onDelete,
                      onConfirmState: isLoading
                          ? SubButtonState.loading
                          : SubButtonState.idle,
                      confirmTitle: 'حذف',
                      cancelTitle: 'إلغاء',
                    ),
                  );
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: AppSubButton(
            title: saveButtonTitle,
            backgroundColor: AppColors.royalBlue,
            state: isLoading ? SubButtonState.loading : SubButtonState.idle,
            onTap: onSave,
          ),
        ),
        const SizedBox(width: 6),
        AdminHoverButton(
          title: 'إلغاء',
          icon: FontAwesomeIcons.xmark,
          onTap: onCancel,
        ),
      ],
    );
  }
}
