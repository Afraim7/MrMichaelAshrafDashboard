import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/Core/Themes/app_colors.dart';

class AuthTextField extends StatefulWidget {
  final IconData? icon;
  final String? label;
  final String? hint;
  final int maxLines;
  final TextInputType keyboardType;
  final TextEditingController controller;
  final String? Function(String?) validationFunction;
  final bool? isPassword;
  final bool autofocus;
  final Color? fillColor;
  final TextStyle? hintStyle;
  final bool? isEnabled;

  const AuthTextField({
    super.key,
    this.icon,
    this.label,
    this.hint,
    required this.keyboardType,
    required this.controller,
    required this.validationFunction,
    this.maxLines = 1,
    this.isPassword,
    this.autofocus = false,
    this.fillColor,
    this.hintStyle,
    this.isEnabled = true,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool isObscured = true;

  @override
  Widget build(BuildContext context) {
    final bool isPassword = (widget.hint ?? '').toLowerCase().trim().contains(
      'كلمة السر',
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        borderRadius: BorderRadius.circular(18),
        color: Colors.transparent,
        elevation: 0,
        child: Theme(
          data: ThemeData(
            textSelectionTheme: TextSelectionThemeData(
              selectionColor: Colors.blue.shade700.withOpacity(0.25),
            ),
          ),
          child: TextFormField(
            enabled: widget.isEnabled,
            controller: widget.controller,
            validator: widget.validationFunction,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            autocorrect: true,
            autofocus: widget.autofocus,
            maxLines: widget.maxLines,
            scrollPhysics: const BouncingScrollPhysics(),
            keyboardType: widget.keyboardType,
            obscureText: isPassword ? isObscured : false,
            obscuringCharacter: '*',
            style: GoogleFonts.scheherazadeNew(
              fontSize: 24,
              color: AppColors.appWhite,
              fontWeight: FontWeight.w300,
              height: 1.5,
            ),
            cursorColor: AppColors.royalBlue,
            cursorWidth: 2,
            cursorHeight: 30,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(16),

              // ──────────────── Icons ────────────────
              prefixIcon: (widget.icon != null)
                  ? Padding(
                      padding: const EdgeInsetsDirectional.only(
                        end: 14,
                        start: 16,
                      ),
                      child: Icon(
                        widget.icon,
                        size: 24,
                        color: AppColors.appWhite,
                      ),
                    )
                  : null,
              suffixIcon: isPassword
                  ? Padding(
                      padding: const EdgeInsetsDirectional.only(end: 12),
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            isObscured = !isObscured;
                          });
                        },
                        icon: Icon(
                          isObscured ? Icons.visibility_off : Icons.visibility,
                        ),
                        iconSize: 20,
                        color: AppColors.appWhite,
                      ),
                    )
                  : null,

              // ──────────────── Texts ────────────────
              hintText: widget.hint,
              hintStyle:
                  widget.hintStyle ??
                  GoogleFonts.scheherazadeNew(
                    fontSize: 20,
                    color: AppColors.neutral500,
                    fontWeight: FontWeight.w300,
                    height: 1.5,
                  ),
              labelText: widget.label,
              labelStyle: GoogleFonts.scheherazadeNew(
                fontSize: 20,
                color: AppColors.neutral500,
                fontWeight: FontWeight.w300,
                height: 1.5,
              ),
              hintMaxLines: widget.maxLines,
              floatingLabelBehavior: widget.label != null
                  ? FloatingLabelBehavior.auto
                  : FloatingLabelBehavior.never,
              errorStyle: GoogleFonts.scheherazadeNew(
                color: AppColors.tomatoRed,
                fontSize: 20,
                fontWeight: FontWeight.w300,
                height: 1.5,
              ),
              errorMaxLines: 3,

              // ──────────────── Colors & Borders ────────────────
              filled: true,
              fillColor: widget.fillColor ?? AppColors.neutra2000,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide(color: AppColors.appWhite, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(
                  color: AppColors.tomatoRed,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
