import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/enums/button_state.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/admin_hover_button.dart';
import 'package:mrmichaelashrafdashboard/shared/dialogs/app_dialog.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/app_sub_button.dart';

class DashboardSheet extends StatefulWidget {
  final String title;
  final Widget body;
  final bool isEditing;
  final bool isExistingItem;
  final bool isSaving;
  final VoidCallback? onEditToggle;
  final VoidCallback onDelete;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  final String saveButtonTitle;
  final String deleteDescription;
  final String deleteLottiePath;

  const DashboardSheet({
    super.key,
    required this.title,
    required this.body,
    required this.isEditing,
    required this.isExistingItem,
    required this.isSaving,
    this.onEditToggle,
    required this.onDelete,
    required this.onSave,
    required this.onCancel,
    this.saveButtonTitle = 'حفظ التغييرات',
    required this.deleteDescription,
    required this.deleteLottiePath,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required DashboardSheet sheet,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => sheet,
    );
  }

  @override
  State<DashboardSheet> createState() => _DashboardSheetState();
}

class _DashboardSheetState extends State<DashboardSheet> {
  /// Mirrors widget.isSaving so the delete-confirmation dialog (which lives
  /// on a separate route, off-tree) can listen and rebuild its confirm button
  /// state. Without this, the dialog would be frozen at whatever isSaving was
  /// when the admin first tapped the trash icon — there'd be no loading
  /// indicator while the delete is in flight.
  late final ValueNotifier<bool> _isSavingNotifier = ValueNotifier<bool>(
    widget.isSaving,
  );

  @override
  void didUpdateWidget(covariant DashboardSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSaving != widget.isSaving) {
      _isSavingNotifier.value = widget.isSaving;
    }
  }

  @override
  void dispose() {
    _isSavingNotifier.dispose();
    super.dispose();
  }

  // Convenience accessors so the existing body of build() reads exactly like
  // the old StatelessWidget version.
  String get title => widget.title;
  Widget get body => widget.body;
  bool get isEditing => widget.isEditing;
  bool get isExistingItem => widget.isExistingItem;
  bool get isSaving => widget.isSaving;
  VoidCallback? get onEditToggle => widget.onEditToggle;
  VoidCallback get onDelete => widget.onDelete;
  VoidCallback get onSave => widget.onSave;
  VoidCallback get onCancel => widget.onCancel;
  String get saveButtonTitle => widget.saveButtonTitle;
  String get deleteDescription => widget.deleteDescription;
  String get deleteLottiePath => widget.deleteLottiePath;

  @override
  Widget build(BuildContext context) {
    final shouldDisable = isExistingItem && !isEditing;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 40),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Stack(
        children: [
          // Scrollable body — sits behind the fixed header and footer
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  top: 80,
                  bottom: isEditing ? 120 + bottomInset : 40 + bottomInset,
                  left: 20,
                  right: 20,
                ),
                child: AbsorbPointer(
                  absorbing: isSaving || shouldDisable,
                  child: body,
                ),
              ),
            ),
          ),

          // Fixed header
          Positioned(top: 0, left: 0, right: 0, child: _buildHeader(context)),

          // Fixed footer — only visible when editing
          if (isEditing)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildFooter(context, bottomInset),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          bottom: BorderSide(color: AppColors.strokeHairlineDark, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Delete (left side)
          IconButton(
            icon: Icon(
              Icons.delete,
              color: AppColors.posterRed.withAlpha(
                isExistingItem && isEditing ? 255 : 57,
              ),
            ),
            onPressed: isExistingItem && isEditing
                ? () => showDialog(
                    context: context,
                    barrierDismissible: false,
                    // ValueListenableBuilder rebuilds the AppDialog whenever
                    // _isSavingNotifier ticks (via didUpdateWidget when the
                    // parent emits a new isSaving). That makes the confirm
                    // button's spinner reflect the live delete progress.
                    builder: (_) => ValueListenableBuilder<bool>(
                      valueListenable: _isSavingNotifier,
                      builder: (_, saving, _) => AppDialog(
                        header: 'تأكيد الحذف',
                        description: deleteDescription,
                        lottiePath: deleteLottiePath,
                        onConfirm: onDelete,
                        onConfirmState: saving
                            ? ButtonState.loading
                            : ButtonState.idle,
                        confirmTitle: 'حذف',
                        cancelTitle: 'إلغاء',
                      ),
                    ),
                  )
                : null,
          ),

          // Title + optional subtitle (center)
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.scheherazadeNew(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: AppColors.appWhite,
                    height: 1.7,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Edit toggle (right side)
          IconButton(
            onPressed: isExistingItem && onEditToggle != null
                ? onEditToggle
                : null,
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                isEditing ? Icons.check : Icons.edit_rounded,
                key: ValueKey(isEditing),
                color: AppColors.skyBlue.withAlpha(isExistingItem ? 255 : 57),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, double bottomInset) {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomInset),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark.withAlpha(242),
        border: const Border(
          top: BorderSide(color: AppColors.strokeHairlineDark, width: 1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: AppSubButton(
              title: saveButtonTitle,
              backgroundColor: AppColors.royalBlue,
              state: isSaving ? ButtonState.loading : ButtonState.idle,
              onTap: onSave,
              height: 45,
            ),
          ),
          const SizedBox(width: 8),
          AdminHoverButton(title: 'إلغاء', icon: Icons.cancel, onTap: onCancel),
        ],
      ),
    );
  }
}
