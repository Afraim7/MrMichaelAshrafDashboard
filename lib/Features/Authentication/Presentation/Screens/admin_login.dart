import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mrmichaelashrafdashboard/core/config/app_radii.dart';
import 'package:mrmichaelashrafdashboard/core/config/app_strings.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/features/authentication/logic/admin_auth_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/authentication/presentation/widgets/admin_login_form.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.clear();
    _passwordController.clear();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBlack,
      body: BlocConsumer<AdminAuthCubit, AdminAuthState>(
        listener: (context, state) {
          if (state is AdminAuthenticated) {
            if (Navigator.canPop(context)) Navigator.pop(context);
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/dashboard-home',
              (route) => false,
            );
            if (state.isFreshLogin) {
              DashboardHelper.showSuccessBar(
                context,
                message: AppStrings.general.adminLoginSuccess,
              );
            }
          } else if (state is AdminError) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            DashboardHelper.showErrorBar(context, error: state.error);
          } else if (state is AdminLoggingIn) {
            DashboardHelper.showLoadingDialog(context);
          }
        },
        builder: (context, state) {
          return Center(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 400),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark.withAlpha(180),
                      borderRadius: AppRadii.huge,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.surfaceAltDark.withAlpha(80),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: Offset(0, 0),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(15),
                    child: AdminLoginForm(
                      emailController: _emailController,
                      passwordController: _passwordController,
                      onAdminLogin: () {
                        context.read<AdminAuthCubit>().adminLogin(
                          email: _emailController.text,
                          password: _passwordController.text,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
