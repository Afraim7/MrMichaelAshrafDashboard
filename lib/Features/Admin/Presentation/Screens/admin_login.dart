import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mrmichaelashrafdashboard/Core/Config/app_radii.dart';
import 'package:mrmichaelashrafdashboard/Core/Config/app_strings.dart';
import 'package:mrmichaelashrafdashboard/Core/Themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/Core/Utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/Features/Admin/Logic/Cubits/AdminAuth/admin_auth_cubit.dart';
import 'package:mrmichaelashrafdashboard/Features/Admin/Presentation/Widgets/admin_login_form.dart';

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
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/controlPanel',
              (route) => false,
            );
            if (state.isFreshLogin) {
              AppHelper.showSuccessBar(
                context,
                message: AppStrings.general.adminLoginSuccess,
              );
            }
          } else if (state is AdminError) {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
            AppHelper.showErrorBar(context, error: state.error);
          } else if (state is AdminLoggingIn) {
            AppHelper.showLoadingDialog(context);
          }
        },
        builder: (context, state) {
          return Center(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 400),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark.withOpacity(0.7),
                        borderRadius: AppRadii.huge,
                        //border: Border.all(width: 0.7, color: AppColors.skyBlue),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.surfaceAltDark.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 0,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.all(20),
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
            ),
          );
        },
      ),
    );
  }
}
