import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeManager extends GetxController {
  static const String _key = 'themeMode';
  final _box = GetStorage();

  final Rx<ThemeMode> _themeMode = ThemeMode.light.obs;
  ThemeMode get currentThemeMode => _themeMode.value;

  @override
  void onInit() {
    super.onInit();
    final stored = _box.read<String>(_key);
    if (stored == 'dark') _themeMode.value = ThemeMode.dark;
  }

  void toggleTheme() {
    _themeMode.value = _themeMode.value == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;
    _box.write(_key, _themeMode.value == ThemeMode.dark ? 'dark' : 'light');
    Get.changeThemeMode(_themeMode.value);
  }
}
