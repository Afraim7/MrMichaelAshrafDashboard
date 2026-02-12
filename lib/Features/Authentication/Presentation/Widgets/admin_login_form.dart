import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/app_validator.dart';
import 'package:mrmichaelashrafdashboard/shared/components/auth_text_field.dart';
import 'package:mrmichaelashrafdashboard/shared/components/app_sub_button.dart';
import 'package:mrmichaelashrafdashboard/core/enums/sub_button_state.dart';

class AdminLoginForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onAdminLogin;
  final SubButtonState buttonState;

  const AdminLoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.onAdminLogin,
    this.buttonState = SubButtonState.idle,
  });

  @override
  State<AdminLoginForm> createState() => _AdminLoginFormState();
}

class _AdminLoginFormState extends State<AdminLoginForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header - App Logo
          Hero(tag: 'admin-logo', child: DashboardHelper.appLogo),

          const SizedBox(height: 30),

          // Header Text
          Text(
            'Admin Login',
            style: GoogleFonts.poppins(
              color: AppColors.appWhite,
              fontWeight: FontWeight.bold,
              fontSize: 30,
              height: 2,
            ),
          ),

          // Sub-header Text
          Text(
            'أدخل بياناتك للوصول إلى لوحة التحكم',
            style: GoogleFonts.scheherazadeNew(
              color: AppColors.textSecondaryDark,
              fontSize: 18,
              fontWeight: FontWeight.w300,
            ),
          ),

          const SizedBox(height: 40),

          // Email Field
          AuthTextField(
            icon: FontAwesomeIcons.envelope,
            hint: 'البريد الألكتروني',
            keyboardType: TextInputType.emailAddress,
            controller: widget.emailController,
            validationFunction: AppValidator.validateEmail,
          ),

          const SizedBox(height: 10),

          // Password Field
          AuthTextField(
            icon: FontAwesomeIcons.lock,
            hint: 'كلمة السر',
            keyboardType: TextInputType.text,
            controller: widget.passwordController,
            validationFunction: AppValidator.validatePasswordLogin,
            onFieldSubmitted: (_) {
              if (_formKey.currentState!.validate()) {
                widget.onAdminLogin();
              }
            },
          ),

          const SizedBox(height: 40),

          // Submit Button
          AppSubButton(
            title: 'تسجيل الدخول',
            backgroundColor: AppColors.royalBlue,
            state: widget.buttonState,
            onTap: () {
              if (_formKey.currentState!.validate()) {
                widget.onAdminLogin();
              }
            },
          ),
        ],
      ),
    );
  }
}
