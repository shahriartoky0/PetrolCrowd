import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import '../models/station_model.dart';
import 'cache_service.dart';

class OverpassService {
  static const List<String> _mirrors = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
    'https://maps.mail.ru/osm/tools/overpass/api/interpreter',
  ];

  static const int _maxRetries = 2;
  static const Duration _requestTimeout = Duration(seconds: 30);

  final Distance _distance = const Distance();
  final Random _random = Random();
  final CacheService _cache = CacheService();

  Future<List<StationModel>> fetchPetrolStations({
    required double lat,
    required double lon,
    int radiusMeters = 5000,
    bool forceRefresh = false,
  }) async {
    final cacheKey = CacheService.stationKey(lat, lon);

    // ── Try cache first ────────────────────────────────────────
    if (!forceRefresh) {
      final cached = _cache.get<List<StationModel>>(
        cacheKey,
        (raw) => (raw as List)
            .map((e) => StationModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
      if (cached != null && cached.isNotEmpty) return cached;
    }

    // ── Fetch from Overpass ───────────────────────────────────
    // Request full tags including phone, opening_hours, fuel types
    final query = '''
[out:json][timeout:25];
(
  node["amenity"="fuel"](around:$radiusMeters,$lat,$lon);
  way["amenity"="fuel"](around:$radiusMeters,$lat,$lon);
  relation["amenity"="fuel"](around:$radiusMeters,$lat,$lon);
);
out center tags;
''';

    Exception? lastException;

    for (final url in _mirrors) {
      for (int attempt = 1; attempt <= _maxRetries; attempt++) {
        try {
          final response = await http
              .post(
                Uri.parse(url),
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: {'data': query},
              )
              .timeout(_requestTimeout);

          if (response.statusCode == 200) {
            final stations = _parseResponse(response.body, lat, lon);

            // Cache the result
            await _cache.set(
              cacheKey,
              stations.map((s) => s.toJson()).toList(),
              ttl: const Duration(minutes: 15),
            );

            return stations;
          }

          if (response.statusCode == 429) {
            await Future.delayed(Duration(seconds: attempt * 2));
            continue;
          }
          if (response.statusCode >= 500) break;

          throw Exception('HTTP ${response.statusCode}');
        } catch (e) {
          lastException = e is Exception ? e : Exception(e.toString());
          if (attempt < _maxRetries) {
            await Future.delayed(Duration(seconds: attempt));
          }
        }
      }
    }

    // ── Network failed — return stale cache if available ───────
    final stale = _cache.get<List<StationModel>>(
      cacheKey,
      (raw) => (raw as List)
          .map((e) => StationModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
    if (stale != null && stale.isNotEmpty) return stale;

    throw lastException ?? Exception('All Overpass mirrors failed.');
  }

  List<StationModel> _parseResponse(String body, double lat, double lon) {
    final json = jsonDecode(body) as Map<String, dynamic>;
    final elements = (json['elements'] as List<dynamic>?) ?? [];
    final List<StationModel> stations = [];

    for (final element in elements) {
      final map = element as Map<String, dynamic>;
      double? stLat;
      double? stLon;

      if (map['type'] == 'node') {
        stLat = (map['lat'] as num?)?.toDouble();
        stLon = (map['lon'] as num?)?.toDouble();
      } else if (map['center'] != null) {
        final center = map['center'] as Map<String, dynamic>;
        stLat = (center['lat'] as num?)?.toDouble();
        stLon = (center['lon'] as num?)?.toDouble();
      }

      if (stLat == null || stLon == null) continue;

      final distM = _distance(LatLng(lat, lon), LatLng(stLat, stLon));
      stations.add(
        StationModel.fromOverpassElement(
          element: map,
          lat: stLat,
          lon: stLon,
          crowdLevel: _randomCrowdLevel(),
          distanceKm: distM / 1000,
        ),
      );
    }

    stations.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return stations;
  }

  CrowdLevel _randomCrowdLevel() => CrowdLevel.values[_random.nextInt(3)];
}
