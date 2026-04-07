import 'package:get_storage/get_storage.dart';

/// Generic TTL cache backed by GetStorage (persists across app restarts).
/// The box is accessed lazily — never before GetStorage.init('petrol_cache')
/// has finished in main().
class CacheService {
  static const Duration _defaultTtl = Duration(minutes: 15);

  // ── Lazy getter — safe against init() race ─────────────────────
  GetStorage get _box => GetStorage('petrol_cache');

  // ─── Public API ───────────────────────────────────────────────

  /// Returns cached value or null if missing / expired.
  T? get<T>(String key, T Function(dynamic raw) decoder) {
    try {
      final wrapper = _box.read<Map?>(key);
      if (wrapper == null) return null;

      final expiry = DateTime.tryParse(wrapper['expiry'] as String? ?? '');
      if (expiry == null || DateTime.now().isAfter(expiry)) {
        _box.remove(key);
        return null;
      }

      return decoder(wrapper['data']);
    } catch (_) {
      // Corrupt entry — wipe it silently
      try { _box.remove(key); } catch (_) {}
      return null;
    }
  }

  /// Stores value with TTL.
  Future<void> set(
      String key,
      dynamic data, {
        Duration ttl = _defaultTtl,
      }) async {
    try {
      await _box.write(key, {
        'data': data,
        'expiry': DateTime.now().add(ttl).toIso8601String(),
      });
    } catch (_) {
      // Non-fatal — app works fine without caching
    }
  }

  Future<void> remove(String key) async {
    try { await _box.remove(key); } catch (_) {}
  }

  Future<void> clear() async {
    try { await _box.erase(); } catch (_) {}
  }

  // ─── Station-specific helpers ─────────────────────────────────

  static String stationKey(double lat, double lon) {
    final la = lat.toStringAsFixed(3);
    final lo = lon.toStringAsFixed(3);
    return 'stations_${la}_$lo';
  }
}
