import 'package:get/get.dart';
import '../../features/map/bindings/map_binding.dart';
import '../../features/map/screens/map_view.dart';
import 'app_routes.dart';

export 'app_routes.dart';

class AppPages {
  AppPages._();

  static final List<GetPage> routes = <GetPage>[
    GetPage(
      name: AppRoutes.map,
      page: () => const MapView(),
      binding: MapBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}
