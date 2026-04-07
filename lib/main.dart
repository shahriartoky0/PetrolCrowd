import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/config/app_constants.dart';
import 'core/routes/app_navigation.dart';
import 'core/routes/app_routes.dart';
import 'core/themes/theme.dart';
import 'core/themes/theme_manager.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar so map bleeds through
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  await GetStorage.init();
  await GetStorage.init('petrol_cache'); // station cache bucket

  final ThemeManager themeManager = Get.put(ThemeManager());

  runApp(MyApp(themeManager: themeManager));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.themeManager});

  final ThemeManager themeManager;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        key: navigatorKey,
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.getTheme(ThemeMode.light),
        darkTheme: AppTheme.getTheme(ThemeMode.dark),
        themeMode: themeManager.currentThemeMode,
        initialRoute: AppRoutes.map,
        getPages: AppPages.routes,
      ),
    );
  }
}
