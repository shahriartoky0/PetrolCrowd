import 'package:flutter/material.dart';
import 'app_text_theme.dart';
import '../config/app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData getTheme(ThemeMode mode) =>
      mode == ThemeMode.dark ? _dark : _light;

  static final ThemeData _light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.lightPrimaryColor,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.lightBackgroundColor,
    textTheme: AppTextTheme.lightTextTheme,
    fontFamily: 'arial-mt-bold',
  );

  static final ThemeData _dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.darkPrimaryColor,
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: AppColors.darkBackgroundColor,
    textTheme: AppTextTheme.darkTextTheme,
    fontFamily: 'arial-mt-bold',
  );
}
