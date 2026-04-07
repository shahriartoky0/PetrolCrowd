import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class AppTextTheme {
  AppTextTheme._();

  static TextTheme lightTextTheme = const TextTheme(
    labelMedium: TextStyle(
      color: AppColors.lightTextBlackColor,
      fontSize: 17,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: TextStyle(
      color: AppColors.lightTextBlackColor,
      fontSize: 22,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: TextStyle(
      color: AppColors.lightPrimaryColor,
      fontSize: 19,
      fontWeight: FontWeight.w700,
    ),
    bodyMedium: TextStyle(
      color: AppColors.lightGreyTextColor,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    bodySmall: TextStyle(
      color: AppColors.lightGreyDarkTextColor,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
  );

  static TextTheme darkTextTheme = const TextTheme(
    labelMedium: TextStyle(
      color: AppColors.darkWhiteColor,
      fontSize: 17,
      fontWeight: FontWeight.w600,
    ),
    titleLarge: TextStyle(
      color: AppColors.darkGreyTextColor,
      fontSize: 22,
      fontWeight: FontWeight.w700,
    ),
    headlineMedium: TextStyle(
      color: AppColors.darkPrimaryColor,
      fontSize: 19,
      fontWeight: FontWeight.w700,
    ),
    bodyMedium: TextStyle(
      color: AppColors.darkTextBlackColor,
      fontSize: 16,
      fontWeight: FontWeight.w500,
    ),
    bodySmall: TextStyle(
      color: AppColors.darkGreyDarkTextColor,
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
  );
}
