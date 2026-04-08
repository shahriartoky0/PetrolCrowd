import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';

import '../models/station_model.dart';
import '../services/overpass_service.dart';
import '../services/route_service.dart';

enum AppTab { map, list }

class PetrolMapController extends GetxController {
  // ─── Observable State ─────────────────────────────────────────
  final RxBool isLoadingLocation = false.obs;
  final RxBool isLoadingStations = false.obs;
  final RxBool isLoadingRoute = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<LatLng?> userLocation = Rx<LatLng?>(null);
  final RxList<StationModel> stations = <StationModel>[].obs;
  final Rx<StationModel?> selectedStation = Rx<StationModel?>(null);
  final RxString filterLevel = ''.obs;
  final Rx<AppTab> activeTab = AppTab.map.obs;
  final RxList<LatLng> routePoints = <LatLng>[].obs;
  final RxBool isStale = false.obs; // true = showing cached data

  // ─── flutter_map controller ───────────────────────────────────
  final mapController = MapController();

  // ─── Services ─────────────────────────────────────────────────
  final OverpassService _overpassService = OverpassService();
  final RouteService _routeService = RouteService();

  static const LatLng fallbackLatLng = LatLng(23.8103, 90.4125);

  // ─── Computed ────────────────────────────────────────────────
  List<StationModel> get filteredStations {
    final src = stations.toList();
    if (filterLevel.value.isEmpty) return src;
    return src.where((s) => s.crowdLevel.name == filterLevel.value).toList();
  }

  bool get isLoading => isLoadingLocation.value || isLoadingStations.value;

  int get lowCount =>
      stations.where((s) => s.crowdLevel == CrowdLevel.low).length;

  // ─── Lifecycle ────────────────────────────────────────────────

  // @override
  // void onInit() {
  //   super.onInit();
  //   _initLocation();
  // }
  @override
  void onReady() {
    super.onReady();
    _initLocation();
  }

  @override
  void onClose() {
    mapController.dispose();
    super.onClose();
  }

  // ─── Public API ───────────────────────────────────────────────

  void selectStation(StationModel station) {
    selectedStation.value = station;
    // If on map tab, fly camera to station
    if (activeTab.value == AppTab.map) {
      mapController.move(station.position, 15.5);
    }
  }

  void clearSelection() {
    selectedStation.value = null;
    routePoints.clear();
  }

  void setFilter(String level) {
    filterLevel.value = filterLevel.value == level ? '' : level;
  }

  void setTab(AppTab tab) => activeTab.value = tab;

  @override
  Future<void> refresh() async {
    stations.clear();
    selectedStation.value = null;
    routePoints.clear();
    errorMessage.value = '';
    isStale.value = false;
    await _initLocation(forceRefresh: true);
  }

  void centerOnUser() {
    final loc = userLocation.value;
    if (loc != null) mapController.move(loc, 14.5);
  }

  /// Fetches in-app driving route from user to [station] using OSRM.
  Future<void> fetchRoute(StationModel station) async {
    final userLoc = userLocation.value;
    if (userLoc == null) return;

    isLoadingRoute.value = true;
    routePoints.clear();
    selectedStation.value = station;

    try {
      final points = await _routeService.fetchRoute(
        from: userLoc,
        to: station.position,
      );
      routePoints.assignAll(points);

      // Switch to map tab and zoom to fit the route
      activeTab.value = AppTab.map;
      _fitRouteBounds(userLoc, station.position);
    } catch (e) {
      debugPrint('Route error: $e');
      errorMessage.value = 'Could not fetch route. Check connection.';
    } finally {
      isLoadingRoute.value = false;
    }
  }

  void clearRoute() => routePoints.clear();

  // ─── Private ─────────────────────────────────────────────────

  Future<void> _initLocation({bool forceRefresh = false}) async {
    isLoadingLocation.value = true;
    errorMessage.value = '';

    try {
      final position = await _determinePosition();
      userLocation.value = LatLng(position.latitude, position.longitude);
    } catch (e) {
      errorMessage.value = _friendlyError(e.toString());
      userLocation.value = fallbackLatLng;
    } finally {
      isLoadingLocation.value = false;
    }
    final loc = userLocation.value ?? fallbackLatLng;
    await _fetchStations(loc, forceRefresh: forceRefresh);
  }

  Future<Position> _determinePosition() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw Exception('Location services disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw Exception('Location permission denied.');
    }

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
    } catch (e) {
      throw Exception('Failed to get location');
    }
  }

  Future<void> _fetchStations(
    LatLng location, {
    bool forceRefresh = false,
  }) async {
    isLoadingStations.value = true;
    errorMessage.value = '';
    try {
      final result = await _overpassService.fetchPetrolStations(
        lat: location.latitude,
        lon: location.longitude,
        forceRefresh: forceRefresh,
      );
      stations.assignAll(result);
      if (result.isEmpty) {
        errorMessage.value = 'No stations found nearby.';
      }
    } catch (e) {
      debugPrint('Station fetch error: $e');
      // If we got results from stale cache, stations won't be empty
      if (stations.isEmpty) {
        errorMessage.value = 'Could not load stations. Tap retry to try again.';
      } else {
        isStale.value = true;
        errorMessage.value = 'Showing cached data — tap retry to refresh.';
      }
    } finally {
      isLoadingStations.value = false;
    }
  }

  void _fitRouteBounds(LatLng a, LatLng b) {
    final minLat = a.latitude < b.latitude ? a.latitude : b.latitude;
    final maxLat = a.latitude > b.latitude ? a.latitude : b.latitude;
    final minLon = a.longitude < b.longitude ? a.longitude : b.longitude;
    final maxLon = a.longitude > b.longitude ? a.longitude : b.longitude;

    final center = LatLng((minLat + maxLat) / 2, (minLon + maxLon) / 2);
    mapController.move(center, 13.0);
  }

  String _friendlyError(String raw) {
    if (raw.contains('denied')) return 'Location permission denied.';
    if (raw.contains('disabled')) return 'Please enable GPS.';
    return 'Could not get location.';
  }
}
