import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/features/authentication/data/models/admin.dart';
import 'package:mrmichaelashrafdashboard/features/authentication/logic/admin_auth_cubit.dart';

class AdminProfileDrawer extends StatefulWidget {
  final Admin? admin;
  const AdminProfileDrawer({super.key, this.admin});

  @override
  State<AdminProfileDrawer> createState() => _AdminProfileDrawerState();
}

class _AdminProfileDrawerState extends State<AdminProfileDrawer> {
  bool _sendingReset = false;

  String get _lastSignIn {
    final t = FirebaseAuth.instance.currentUser?.metadata.lastSignInTime;
    if (t == null) return '—';
    return DateFormat('d MMM yyyy – HH:mm').format(t.toLocal());
  }

  Future<void> _sendPasswordReset() async {
    if (_sendingReset) return;
    setState(() => _sendingReset = true);
    try {
      final email =
          FirebaseAuth.instance.currentUser?.email ?? widget.admin!.email;
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        DashboardHelper.showSuccessBar(
          context,
          message: 'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك',
        );
      }
    } catch (_) {
      if (mounted) {
        DashboardHelper.showErrorBar(
          context,
          error: 'تعذّر إرسال رابط إعادة التعيين، حاول مجددًا',
        );
      }
    } finally {
      if (mounted) setState(() => _sendingReset = false);
    }
  }

  void _signOut() {
    // Close the drawer first, then dispatch logout — the bar's BlocConsumer
    // listens for CheckAuthStatusUnauthenticated and routes to /adminLogin.
    Navigator.of(context).pop();
    context.read<AdminAuthCubit>().signOut();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 320,
          height: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.surfaceDark,
            border: Border(
              left: BorderSide(color: AppColors.neutral900, width: 1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(onClose: () => Navigator.of(context).pop()),
              _IdentitySection(admin: widget.admin!),
              _Divider(),
              _LastSignInRow(label: _lastSignIn),
              _Divider(),

              // Actions
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    _ActionTile(
                      icon: Icons.lock_reset_rounded,
                      label: 'تغيير كلمة المرور',
                      accentColor: AppColors.royalYellow,
                      loading: _sendingReset,
                      onTap: _sendPasswordReset,
                    ),
                    const SizedBox(height: 6),
                    _ActionTile(
                      icon: Icons.logout_rounded,
                      label: 'تسجيل الخروج',
                      accentColor: AppColors.tomatoRed,
                      isDanger: true,
                      onTap: _signOut,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  final VoidCallback onClose;
  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
      child: Row(
        children: [
          Text(
            'الملف الشخصي',
            style: GoogleFonts.scheherazadeNew(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryDark,
            ),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'إغلاق',
            icon: const Icon(Icons.close_rounded, size: 20),
            color: AppColors.neutral500,
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _IdentitySection extends StatelessWidget {
  final Admin admin;
  const _IdentitySection({required this.admin});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
      child: Column(
        children: [
          _Avatar(admin: admin, radius: 38, glow: true),
          const SizedBox(height: 14),
          Text(
            admin.adminName,
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimaryDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            admin.email,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              color: AppColors.neutral500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const _RoleBadge(),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.royalBlue.withAlpha(40),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.royalBlue.withAlpha(80), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.admin_panel_settings_outlined,
            size: 13,
            color: AppColors.skyBlue,
          ),
          const SizedBox(width: 6),
          Text(
            'مشرف رئيسي',
            style: GoogleFonts.scheherazadeNew(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.skyBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _LastSignInRow extends StatelessWidget {
  final String label;
  const _LastSignInRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(
        children: [
          const Icon(
            Icons.access_time_rounded,
            size: 16,
            color: AppColors.neutral500,
          ),
          const SizedBox(width: 8),
          Text(
            'آخر دخول',
            style: GoogleFonts.scheherazadeNew(
              fontSize: 14,
              color: AppColors.neutral500,
            ),
          ),
          const Spacer(),
          Text(
            label,
            style: GoogleFonts.amiri(
              fontSize: 12,
              color: AppColors.textSecondaryDark,
            ),
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      const Divider(height: 1, color: AppColors.neutral900);
}

// ─── Action tile (reset password, logout) ──────────────────────────────────

class _ActionTile extends StatefulWidget {
  final IconData icon;
  final String label;
  final Color accentColor;
  final bool loading;
  final bool isDanger;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onTap,
    this.loading = false,
    this.isDanger = false,
  });

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final shahr = GoogleFonts.scheherazadeNew();
    final labelColor = widget.isDanger
        ? AppColors.tomatoRed
        : AppColors.textPrimaryDark;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Semantics(
        button: true,
        label: widget.label,
        child: GestureDetector(
          onTap: widget.loading ? null : widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: _hover
                  ? (widget.isDanger
                        ? AppColors.tomatoRed.withAlpha(20)
                        : AppColors.neutralOverlayMed)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                // Icon tile
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: widget.accentColor.withAlpha(28),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(widget.icon, size: 18, color: widget.accentColor),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Text(
                    widget.label,
                    style: shahr.copyWith(
                      fontSize: 15,
                      color: labelColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                if (widget.loading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(
                        widget.accentColor.withAlpha(180),
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_left_rounded,
                    size: 18,
                    color: labelColor.withAlpha(120),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Avatar (reusable inside drawer) ──────────────────────────────────────

class _Avatar extends StatelessWidget {
  final Admin admin;
  final double radius;
  final bool glow;

  const _Avatar({required this.admin, required this.radius, this.glow = false});

  @override
  Widget build(BuildContext context) {
    final path = admin.photoURL ?? '';
    final initial = admin.adminName.trim().isNotEmpty
        ? admin.adminName.trim()[0]
        : '؟';

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        color: AppColors.appNavy,
        shape: BoxShape.circle,
        boxShadow: glow
            ? [
                BoxShadow(
                  color: AppColors.royalBlue.withAlpha(80),
                  blurRadius: 18,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: path.isNotEmpty
          ? ClipOval(child: Image.asset(path, fit: BoxFit.cover))
          : Center(
              child: Text(
                initial,
                style: GoogleFonts.scheherazadeNew(
                  fontSize: radius * 0.8,
                  fontWeight: FontWeight.bold,
                  color: AppColors.royalYellow,
                ),
              ),
            ),
    );
  }
}
