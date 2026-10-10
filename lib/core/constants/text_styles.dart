import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static const pageTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 24,
    fontWeight: FontWeight.w800,
  );

  static const sectionTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 18,
    fontWeight: FontWeight.w700,
  );

  static const body = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 15,
    height: 1.45,
  );
}
