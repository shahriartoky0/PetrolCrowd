import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeManager extends GetxController {
  static const String _key = 'themeMode';

  // Box is accessed lazily — safe after GetStorage.init() in main()
  GetStorage get _box => GetStorage();

  final Rx<ThemeMode> _themeMode = ThemeMode.light.obs;
  ThemeMode get currentThemeMode => _themeMode.value;

  @override
  void onInit() {
    super.onInit();
    // Read persisted theme safely
    try {
      final stored = _box.read<String>(_key);
      if (stored == 'dark') _themeMode.value = ThemeMode.dark;
    } catch (_) {
      // Default to light if storage not ready
    }
  }

  void toggleTheme() {
    _themeMode.value =
    _themeMode.value == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    try {
      _box.write(_key, _themeMode.value == ThemeMode.dark ? 'dark' : 'light');
    } catch (_) {}
    Get.changeThemeMode(_themeMode.value);
  }
}
