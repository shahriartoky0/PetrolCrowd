import 'package:latlong2/latlong.dart';

enum CrowdLevel { low, medium, high }

class StationModel {
  final String id;
  final String name;
  final String? brand;
  final String? phone;
  final String? openingHours;
  final String? operator;
  final String? fuelTypes; // e.g. "diesel;octane_95"
  final LatLng position;
  final CrowdLevel crowdLevel;
  final double distanceKm;

  const StationModel({
    required this.id,
    required this.name,
    this.brand,
    this.phone,
    this.openingHours,
    this.operator,
    this.fuelTypes,
    required this.position,
    required this.crowdLevel,
    required this.distanceKm,
  });

  // ─── Computed labels ─────────────────────────────────────────

  String get waitTime {
    switch (crowdLevel) {
      case CrowdLevel.low:
        return '~2 min';
      case CrowdLevel.medium:
        return '~8 min';
      case CrowdLevel.high:
        return '~20 min';
    }
  }

  String get crowdLabel {
    switch (crowdLevel) {
      case CrowdLevel.low:
        return 'Low';
      case CrowdLevel.medium:
        return 'Medium';
      case CrowdLevel.high:
        return 'High';
    }
  }

  String get distanceLabel {
    if (distanceKm < 1.0) return '${(distanceKm * 1000).round()} m';
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  /// Display name: prefer brand if name is generic
  String get displayName {
    if (name != 'Petrol Station' && name.isNotEmpty) return name;
    return brand ?? name;
  }

  bool get hasPhone => phone != null && phone!.isNotEmpty;

  // ─── Serialisation for cache ─────────────────────────────────

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'brand': brand,
        'phone': phone,
        'openingHours': openingHours,
        'operator': operator,
        'fuelTypes': fuelTypes,
        'lat': position.latitude,
        'lon': position.longitude,
        'crowdLevel': crowdLevel.index,
        'distanceKm': distanceKm,
      };

  factory StationModel.fromJson(Map<String, dynamic> json) => StationModel(
        id: json['id'] as String,
        name: json['name'] as String,
        brand: json['brand'] as String?,
        phone: json['phone'] as String?,
        openingHours: json['openingHours'] as String?,
        operator: json['operator'] as String?,
        fuelTypes: json['fuelTypes'] as String?,
        position: LatLng(
          (json['lat'] as num).toDouble(),
          (json['lon'] as num).toDouble(),
        ),
        crowdLevel: CrowdLevel.values[json['crowdLevel'] as int],
        distanceKm: (json['distanceKm'] as num).toDouble(),
      );

  // ─── Factory from Overpass element ───────────────────────────

  factory StationModel.fromOverpassElement({
    required Map<String, dynamic> element,
    required double lat,
    required double lon,
    required CrowdLevel crowdLevel,
    required double distanceKm,
  }) {
    final tags = (element['tags'] as Map<String, dynamic>?) ?? {};

    final name = tags['name'] as String? ??
        tags['brand'] as String? ??
        tags['operator'] as String? ??
        'Petrol Station';

    // Normalise phone: strip spaces, handle country code
    String? phone = tags['phone'] as String? ??
        tags['contact:phone'] as String? ??
        tags['telephone'] as String?;
    if (phone != null) {
      phone = phone.trim().replaceAll(RegExp(r'\s+'), '');
    }

    // Fuel types from OSM tags
    final fuelTagKeys = tags.keys.where((k) => k.startsWith('fuel:')).toList();
    final fuelList = fuelTagKeys
        .where((k) => tags[k] == 'yes')
        .map((k) => k.replaceFirst('fuel:', ''))
        .toList();
    final fuelTypes = fuelList.isNotEmpty ? fuelList.join(' · ') : null;

    return StationModel(
      id: element['id'].toString(),
      name: name,
      brand: tags['brand'] as String?,
      phone: phone,
      openingHours: tags['opening_hours'] as String?,
      operator: tags['operator'] as String?,
      fuelTypes: fuelTypes,
      position: LatLng(lat, lon),
      crowdLevel: crowdLevel,
      distanceKm: distanceKm,
    );
  }
}
