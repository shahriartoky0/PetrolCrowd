import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Uses the public OSRM demo server (free, no API key).
/// For production, self-host OSRM or use a paid alternative.
class RouteService {
  static const String _baseUrl = 'https://router.project-osrm.org/route/v1/driving';
  static const Duration _timeout = Duration(seconds: 15);

  /// Returns ordered list of [LatLng] points forming the driving route,
  /// or throws on failure.
  Future<List<LatLng>> fetchRoute({
    required LatLng from,
    required LatLng to,
  }) async {
    final url =
        '$_baseUrl/${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
        '?overview=full&geometries=geojson&steps=false';

    final response = await http
        .get(Uri.parse(url))
        .timeout(_timeout);

    if (response.statusCode != 200) {
      throw Exception('OSRM error: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final routes = json['routes'] as List?;
    if (routes == null || routes.isEmpty) {
      throw Exception('No route found.');
    }

    final geometry = routes[0]['geometry'] as Map<String, dynamic>;
    final coordinates = geometry['coordinates'] as List;

    return coordinates
        .map((c) => LatLng(
              (c[1] as num).toDouble(),
              (c[0] as num).toDouble(),
            ))
        .toList();
  }
}
