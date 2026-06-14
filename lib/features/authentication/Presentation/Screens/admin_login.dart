import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mrmichaelashrafdashboard/core/enums/button_state.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_typography.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/app_validator.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/features/authentication/logic/admin_auth_cubit.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/app_sub_button.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/auth_text_field.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => AdminAuthCubit(), child: const _Body());
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      context.read<AdminAuthCubit>().signIn(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBlack,
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: BlocConsumer<AdminAuthCubit, AdminAuthState>(
                    listener: (context, state) {
                      // Sign-in surfaces its own dedicated error state —
                      // CheckAuthStatusError comes from the background auth
                      // stream and shouldn't toast on the login screen.
                      if (state is SignInError) {
                        DashboardHelper.showErrorBar(
                          context,
                          error: state.message,
                        );
                      }
                      // Route on whichever signal arrives first:
                      // SignInSuccess (button press) or CheckAuthStatusAuthenticated
                      // (auth stream catching up). Either means "logged in."
                      if (state is SignInSuccess ||
                          state is CheckAuthStatusAuthenticated) {
                        Navigator.of(context).pushNamedAndRemoveUntil(
                          '/dashboard-home',
                          (_) => false,
                        );
                      }
                    },
                    builder: (context, state) {
                      return Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Center(child: _AdminBadge()),
                            const SizedBox(height: 70),
                            Text(
                              'تسجيل دخول المشرف',
                              style: AppTypography.headlineMedium(
                                AppColors.appWhite,
                              ).copyWith(fontSize: 22),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'أدخل بياناتك للوصول للوحة التحكم',
                              style: AppTypography.bodyMedium(
                                AppColors.neutral500,
                              ).copyWith(fontSize: 20),
                              textAlign: TextAlign.right,
                            ),
                            const SizedBox(height: 20),
                            AuthTextField(
                              icon: Icons.email,
                              label: 'البريد الإلكتروني',
                              hint: 'أدخل بريدك الإلكتروني',
                              keyboardType: TextInputType.emailAddress,
                              controller: _email,
                              validationFunction: AppValidator.validateEmail,
                            ),
                            AuthTextField(
                              icon: Icons.lock,
                              label: 'كلمة السر',
                              hint: 'أدخل كلمة السر',
                              keyboardType: TextInputType.visiblePassword,
                              controller: _password,
                              validationFunction:
                                  AppValidator.validatePasswordLogin,

                              onFieldSubmitted: (_) => _submit(),
                            ),
                            const SizedBox(height: 32),
                            AppSubButton(
                              title: 'دخول',
                              titleSize: 20,
                              backgroundColor: AppColors.royalBlue,
                              state: state is SignInLoading
                                  ? ButtonState.loading
                                  : ButtonState.idle,
                              onTap: _submit,
                              borderRadius: 20,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AdminBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.midBlue.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.midBlue.withAlpha(70)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 10),

          Icon(
            Icons.admin_panel_settings_outlined,
            size: 14,
            color: AppColors.midBlue.withAlpha(100),
          ),
          const SizedBox(width: 10),
          Text(
            'لوحة التحكم',
            style: AppTypography.labelSmall(
              AppColors.appWhite,
            ).copyWith(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}
