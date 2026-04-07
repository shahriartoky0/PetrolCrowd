import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Light theme ────────────────────────────────────────────────
  static const Color lightPrimaryColor    = Color(0xFFB2CBF2);
  static const Color lightSecondaryColor  = Color(0xFFABE6ED);
  static const Color lightBackgroundColor = Color(0xFFFFFFFF);
  static const Color lightSurfaceColor    = Color(0xFFEFFAFC);
  static const Color lightNavIconColor    = Color(0xFF685F84);
  static const Color lightBottomBarColor  = Color(0xFFD3F0F5);
  static const Color lightRedColor        = Color(0xFFFF4F4F);
  static const Color lightSuccessColor    = Color(0xFF81C784);
  static const Color lightWarningColor    = Color(0xFFFF8A50);
  static const Color lightInfoColor       = Color(0xFF64B5F6);
  static const Color lightGreyDarkColor   = Color(0xFF999899);
  static const Color lightGreyColor       = Colors.grey;
  static const Color lightTextBlackColor  = Color(0XFF303F47);
  static const Color lightBorderColor     = Color(0x28333F40);
  static const Color lightDividerColor    = Color(0xFFBDBDBD);
  static const Color lightGreyDarkTextColor = Color(0XFF666666);
  static const Color lightGreyTextColor   = Color(0XFF606060);

  // ── Dark theme ─────────────────────────────────────────────────
  static const Color darkPrimaryColor     = Color(0xFF90A4AE);
  static const Color darkBackgroundColor  = Color(0xFF121212);
  static const Color darkSurfaceColor     = Color(0xFF1E1E1E);
  static const Color darkWhiteColor       = Color(0xFFECEFF1);
  static const Color darkTextBlackColor   = Color(0xFFCFD8DC);
  static const Color darkGreyTextColor    = Color(0xFFB0BEC5);
  static const Color darkGreyDarkTextColor = Color(0xFF90A4AE);

  // ── Convenience aliases (resolve at usage site if needed) ──────
  static Color get primaryColor    => lightPrimaryColor;
  static Color get backgroundColor => lightBackgroundColor;
  static Color get surfaceColor    => lightSurfaceColor;
  static Color get borderColor     => lightBorderColor;
  static Color get greyColor       => lightGreyColor;
  static Color get textBlackColor  => lightTextBlackColor;
  static Color get greyTextColor   => lightGreyTextColor;
  static Color get greyDarkTextColor => lightGreyDarkTextColor;

  // ── Map / crowd-level specific ─────────────────────────────────
  static const Color crowdLow    = Color(0xFF43A047); // green
  static const Color crowdMedium = Color(0xFFFF8F00); // amber
  static const Color crowdHigh   = Color(0xFFE53935); // red
  static const Color mapDark     = Color(0xFF1A1A2E); // deep navy
  static const Color userDot     = Color(0xFF5C6BC0); // indigo
}
