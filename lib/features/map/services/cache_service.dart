import 'dart:convert';
import 'package:get_storage/get_storage.dart';

/// Generic TTL cache backed by GetStorage (persists across app restarts).
/// Key format: "stations_lat_lon" (rounded to 3dp ≈ 111m precision).
class CacheService {
  static const Duration _defaultTtl = Duration(minutes: 15);

  final GetStorage _box = GetStorage('petrol_cache');

  // ─── Public API ───────────────────────────────────────────────

  /// Returns cached value or null if missing / expired.
  T? get<T>(String key, T Function(dynamic raw) decoder) {
    final wrapper = _box.read<Map?>(key);
    if (wrapper == null) return null;

    final expiry = DateTime.tryParse(wrapper['expiry'] as String? ?? '');
    if (expiry == null || DateTime.now().isAfter(expiry)) {
      _box.remove(key);
      return null;
    }

    try {
      return decoder(wrapper['data']);
    } catch (_) {
      _box.remove(key);
      return null;
    }
  }

  /// Stores value with TTL.
  Future<void> set(
    String key,
    dynamic data, {
    Duration ttl = _defaultTtl,
  }) async {
    await _box.write(key, {
      'data': data,
      'expiry': DateTime.now().add(ttl).toIso8601String(),
    });
  }

  Future<void> remove(String key) => _box.remove(key);

  Future<void> clear() => _box.erase();

  // ─── Station-specific helpers ─────────────────────────────────

  static String stationKey(double lat, double lon) {
    final la = lat.toStringAsFixed(3);
    final lo = lon.toStringAsFixed(3);
    return 'stations_${la}_$lo';
  }
}
