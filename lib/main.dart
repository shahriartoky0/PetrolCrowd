import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/config/app_constants.dart';
import 'core/routes/app_navigation.dart';
import 'core/routes/app_routes.dart';
import 'core/themes/theme.dart';
import 'core/themes/theme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Init default GetStorage box
  await GetStorage.init();

  // Init station-cache box — wrapped so a storage failure never
  // blocks startup (app degrades to network-only mode gracefully)
  try {
    await GetStorage.init('petrol_cache');
  } catch (_) {
    // Non-fatal — caching will be skipped silently
  }

  // Register theme manager before runApp
  Get.put(ThemeManager());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // GetX automatically reacts to theme changes without wrapping
    // the entire MaterialApp in Obx — which caused blank-frame flashes.
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.getTheme(ThemeMode.light),
      darkTheme: AppTheme.getTheme(ThemeMode.dark),
      themeMode: ThemeMode.light,
      initialRoute: AppRoutes.map,
      getPages: AppPages.routes,
    );
  }
}
