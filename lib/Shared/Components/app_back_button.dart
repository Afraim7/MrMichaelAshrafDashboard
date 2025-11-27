import 'package:flutter/material.dart';
import 'package:mrmichaelashrafdashboard/Core/Themes/app_colors.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  const AppBackButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 7),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 45,
          width: 45,
          child: Material(
            color: AppColors.appBlack.withOpacity(0.5),
            child: InkWell(
              onTap: onTap ?? () => Navigator.of(context).pop(),
              splashColor: AppColors.appBlack.withOpacity(0.3),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.appWhite,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
