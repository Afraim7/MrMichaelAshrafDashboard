import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mrmichaelashrafdashboard/Core/Themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/Core/Utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/Features/Authentication/Logic/admin_auth_cubit.dart';
import 'package:mrmichaelashrafdashboard/Features/Admin%20Dashboard/Logic/dashboard_center_cubit.dart';

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
                  _barIcon(context, Icons.menu_book_rounded, 1, currentIndex),
                  const SizedBox(width: 10),
                  _barIcon(context, FontAwesomeIcons.penFancy, 2, currentIndex),
                  const SizedBox(width: 10),
                  _barIcon(context, Icons.file_copy_rounded, 3, currentIndex),
                  const SizedBox(width: 10),
                  _barIcon(context, Icons.group_outlined, 4, currentIndex),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: _logoutIcon(context),
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
                  _barIcon(context, Icons.menu_book_rounded, 1, currentIndex),
                  const SizedBox(height: 20),
                  _barIcon(context, FontAwesomeIcons.penFancy, 2, currentIndex),
                  const SizedBox(height: 20),
                  _barIcon(context, Icons.file_copy_rounded, 3, currentIndex),
                  const SizedBox(height: 20),
                  _barIcon(context, Icons.group_outlined, 4, currentIndex),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: _logoutIcon(context),
            ),
          ],
        );
      },
    );
  }

  // ---------------------- SHARED ----------------------
  Widget _logoBox(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<DashboardCenterCubit>().updateScreenIndex(0),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.royalBlue,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.home, color: Colors.white),
      ),
    );
  }

  Widget _barIcon(
    BuildContext context,
    IconData icon,
    int index,
    int currentIndex,
  ) {
    final isActive = currentIndex == index;
    return GestureDetector(
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
    );
  }

  Widget _logoutIcon(BuildContext context) {
    return BlocConsumer<AdminAuthCubit, AdminAuthState>(
      listener: (context, state) {
        if (state is AdminError) {
          DashboardHelper.showErrorBar(context, error: state.error);
        } else if (state is AdminUnauthenticated) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/adminLogin', (route) => false);
        }
      },
      builder: (context, state) {
        final isLoading = state is AdminLoggingOut;
        return GestureDetector(
          onTap: isLoading
              ? null
              : () => context.read<AdminAuthCubit>().adminLogout(),
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: DashboardHelper.appCircularInd,
                )
              : const Icon(
                  Icons.logout_rounded,
                  color: AppColors.tomatoRed,
                  size: 25,
                ),
        );
      },
    );
  }
}
