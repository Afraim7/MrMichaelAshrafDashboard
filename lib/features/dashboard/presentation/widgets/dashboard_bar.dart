import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/features/dashboard/logic/dashboard_center_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/authentication/data/models/admin.dart';
import 'package:mrmichaelashrafdashboard/features/authentication/logic/admin_auth_cubit.dart';

class DashboardBar extends StatelessWidget {
  const DashboardBar({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final bool isMobile = width < 600;
    final barChild = isMobile
        ? _buildMobileBar(context)
        : _buildDesktopBar(context);

    return Align(
      alignment: isMobile ? Alignment.topCenter : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.all(15),
        padding: const EdgeInsets.all(10),
        height: isMobile ? 60 : double.infinity,
        width: isMobile ? double.infinity : 70,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark.withAlpha(230),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(51),
              blurRadius: 16,
              spreadRadius: 0,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: barChild,
      ),
    );
  }

  // ---------------------- MOBILE BAR ----------------------
  Widget _buildMobileBar(BuildContext context) {
    return BlocBuilder<DashboardCenterCubit, int>(
      builder: (context, currentIndex) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _logoBox(context),
            Padding(
              padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
              child: Opacity(
                opacity: 0.7,
                child: VerticalDivider(
                  color: AppColors.skyBlue,
                  thickness: 0.7,
                  endIndent: 5,
                  indent: 5,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                children: [
                  _barIcon(
                    context,
                    Icons.menu_book_rounded,
                    1,
                    currentIndex,
                    tooltip: 'الكورسات',
                  ),
                  const SizedBox(width: 10),
                  _barIcon(
                    context,
                    Icons.file_copy_rounded,
                    2,
                    currentIndex,
                    tooltip: 'الامتحانات',
                  ),
                  const SizedBox(width: 10),
                  _barIcon(
                    context,
                    FontAwesomeIcons.penFancy,
                    3,
                    currentIndex,
                    tooltip: 'هايلايتس',
                  ),
                  const SizedBox(width: 10),
                  _barIcon(
                    context,
                    Icons.payments_rounded,
                    4,
                    currentIndex,
                    tooltip: 'المدفوعات',
                  ),
                  const SizedBox(width: 10),
                  _barIcon(
                    context,
                    Icons.group_outlined,
                    5,
                    currentIndex,
                    tooltip: 'الطلاب',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: _adminAvatar(context),
            ),
          ],
        );
      },
    );
  }

  // ---------------------- DESKTOP BAR ----------------------
  Widget _buildDesktopBar(BuildContext context) {
    return BlocBuilder<DashboardCenterCubit, int>(
      builder: (context, currentIndex) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 5),
            _logoBox(context),
            Padding(
              padding: EdgeInsetsGeometry.symmetric(vertical: 20),
              child: Opacity(
                opacity: 0.7,
                child: Divider(
                  color: AppColors.skyBlue,
                  thickness: 0.7,
                  endIndent: 7,
                  indent: 7,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                children: [
                  // Order: courses → exams → highlights → payments → users.
                  // Indices match the IndexedStack in dashboard_home_center
                  // and the navigateToX methods in DashboardCenterCubit.
                  _barIcon(
                    context,
                    Icons.menu_book_rounded,
                    1,
                    currentIndex,
                    tooltip: 'الكورسات',
                  ),
                  const SizedBox(height: 20),
                  _barIcon(
                    context,
                    Icons.file_copy_rounded,
                    2,
                    currentIndex,
                    tooltip: 'الامتحانات',
                  ),
                  const SizedBox(height: 20),
                  _barIcon(
                    context,
                    FontAwesomeIcons.penFancy,
                    3,
                    currentIndex,
                    tooltip: 'هايلايتس',
                  ),
                  const SizedBox(height: 20),
                  _barIcon(
                    context,
                    Icons.payments_rounded,
                    4,
                    currentIndex,
                    tooltip: 'المدفوعات',
                  ),
                  const SizedBox(height: 20),
                  _barIcon(
                    context,
                    Icons.group_outlined,
                    5,
                    currentIndex,
                    tooltip: 'الطلاب',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: _adminAvatar(context),
            ),
          ],
        );
      },
    );
  }

  // ---------------------- SHARED ----------------------
  Widget _logoBox(BuildContext context) {
    return Tooltip(
      message: 'الصفحة الرئيسية',
      child: Semantics(
        button: true,
        label: 'الصفحة الرئيسية',
        child: GestureDetector(
          onTap: () =>
              context.read<DashboardCenterCubit>().updateScreenIndex(0),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.royalBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.home, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _barIcon(
    BuildContext context,
    IconData icon,
    int index,
    int currentIndex, {
    required String tooltip,
  }) {
    final isActive = currentIndex == index;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        selected: isActive,
        label: tooltip,
        child: GestureDetector(
          onTap: () =>
              context.read<DashboardCenterCubit>().updateScreenIndex(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.royalBlue.withAlpha(51)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: isActive
                  ? Border.all(color: AppColors.royalBlue, width: 2)
                  : null,
            ),
            child: Icon(
              icon,
              color: isActive
                  ? AppColors.surfaceLight
                  : AppColors.surfaceLight.withAlpha(128),
            ),
          ),
        ),
      ),
    );
  }

  Widget _adminAvatar(BuildContext context) {
    final state = context.watch<AdminAuthCubit>().state;
    return Tooltip(
      message: 'الملف الشخصي',
      child: Semantics(
        button: true,
        label: 'فتح الملف الشخصي للمسؤول',
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => Scaffold.of(context).openEndDrawer(),
            child: _BarAdminAvatar(
              // The auth stream settles on CheckAuthStatusAuthenticated once
              // signed in; SignInSuccess is only the transient button-press
              // state. Resolve from both so the avatar isn't perpetually null.
              admin: switch (state) {
                SignInSuccess(:final admin) => admin,
                CheckAuthStatusAuthenticated(:final admin) => admin,
                _ => null,
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _BarAdminAvatar extends StatelessWidget {
  final Admin? admin;
  const _BarAdminAvatar({required this.admin});

  @override
  Widget build(BuildContext context) {
    // Null-safe: the avatar may build before the admin doc resolves.
    final path = admin?.photoURL ?? '';
    final name = admin?.adminName.trim() ?? '';
    final initial = name.isNotEmpty ? name[0] : '؟';

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.appNavy,
        border: Border.all(
          color: AppColors.royalBlue.withAlpha(150),
          width: 1.5,
        ),
      ),
      child: path.isNotEmpty
          ? ClipOval(child: Image.asset(path, fit: BoxFit.cover))
          : Center(
              child: Text(
                initial,
                style: GoogleFonts.scheherazadeNew(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.royalYellow,
                ),
              ),
            ),
    );
  }
}
