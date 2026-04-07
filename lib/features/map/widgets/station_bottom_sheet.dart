import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/map_controller.dart';
import '../models/station_model.dart';

class StationBottomSheet extends StatelessWidget {
  const StationBottomSheet({
    super.key,
    required this.station,
    required this.controller,
  });

  final StationModel station;
  final PetrolMapController controller;

  static Future<void> show(
    BuildContext context,
    StationModel station,
    PetrolMapController controller,
  ) {
    HapticFeedback.lightImpact();
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      enableDrag: true,
      builder: (_) =>
          StationBottomSheet(station: station, controller: controller),
    );
  }

  @override
  Widget build(BuildContext context) {
    final crowdColor = _crowdColor(station.crowdLevel);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFFFFFFF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomPad + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              height: 4,
              width: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // ── Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: crowdColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.local_gas_station_rounded,
                    color: crowdColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      station.displayName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F0F1A),
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${station.distanceLabel} away',
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9E9E9E),
                          fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _CrowdBadge(level: station.crowdLevel, color: crowdColor),
            ],
          ),

          const SizedBox(height: 16),

          // ── Extra details (brand, opening hours, fuel types, phone)
          if (_hasDetails)
            _DetailsCard(station: station, crowdColor: crowdColor),

          if (_hasDetails) const SizedBox(height: 14),

          // ── Info cards row
          Row(
            children: [
              Expanded(
                child: _InfoCard(
                  icon: Icons.schedule_rounded,
                  label: 'Est. Wait',
                  value: station.waitTime,
                  iconColor: crowdColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InfoCard(
                  icon: Icons.people_alt_rounded,
                  label: 'Crowd',
                  value: station.crowdLabel,
                  iconColor: crowdColor,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _InfoCard(
                  icon: Icons.near_me_rounded,
                  label: 'Distance',
                  value: station.distanceLabel,
                  iconColor: const Color(0xFF5C6BC0),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // ── Crowd level bar
          _CrowdLevelBar(level: station.crowdLevel),

          const SizedBox(height: 18),

          // ── Action buttons
          Row(
            children: [
              // In-app route (OSRM)
              Expanded(
                child: _ActionButton(
                  icon: Icons.route_rounded,
                  label: 'Route',
                  color: const Color(0xFF5C6BC0),
                  onTap: () {
                    Navigator.of(context).pop();
                    controller.fetchRoute(station);
                  },
                ),
              ),
              const SizedBox(width: 8),

              // External maps (Google Maps / geo: fallback)
              Expanded(
                child: _ActionButton(
                  icon: Icons.map_outlined,
                  label: 'Maps',
                  color: const Color(0xFF0F0F1A),
                  onTap: () => _openExternalMaps(context),
                ),
              ),

              // Phone call (only if number available)
              if (station.hasPhone) ...[
                const SizedBox(width: 8),
                _IconActionButton(
                  icon: Icons.phone_rounded,
                  color: const Color(0xFF4CAF50),
                  tooltip: 'Call station',
                  onTap: () => _callStation(context),
                ),
              ],

              // Share / copy
              const SizedBox(width: 8),
              _IconActionButton(
                icon: Icons.ios_share_rounded,
                color: const Color(0xFF9E9E9E),
                tooltip: 'Copy link',
                onTap: () => _copyInfo(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool get _hasDetails =>
      station.brand != null ||
      station.openingHours != null ||
      station.fuelTypes != null ||
      station.hasPhone;

  Future<void> _openExternalMaps(BuildContext context) async {
    final lat = station.position.latitude;
    final lon = station.position.longitude;
    final label = Uri.encodeComponent(station.displayName);

    final googleNav =
        Uri.parse('google.navigation:q=$lat,$lon&mode=d');
    final googleWeb = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lon&travelmode=driving');
    final geo = Uri.parse('geo:$lat,$lon?q=$lat,$lon($label)');

    try {
      if (await canLaunchUrl(googleNav)) {
        await launchUrl(googleNav, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(googleWeb)) {
        await launchUrl(googleWeb, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(geo, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          _snack('No maps app found. Install Google Maps.'),
        );
      }
    }
  }

  Future<void> _callStation(BuildContext context) async {
    final tel = Uri.parse('tel:${station.phone}');
    try {
      if (await canLaunchUrl(tel)) {
        await launchUrl(tel);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(_snack('Cannot place call on this device.'));
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(_snack('Could not open dialler.'));
      }
    }
  }

  void _copyInfo(BuildContext context) {
    final text =
        '${station.displayName}\nCrowd: ${station.crowdLabel} · Wait: ${station.waitTime}\n'
        'https://www.google.com/maps?q=${station.position.latitude},${station.position.longitude}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
        .showSnackBar(_snack('Station info copied.'));
  }

  SnackBar _snack(String msg) => SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1C1C2E),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      );

  Color _crowdColor(CrowdLevel level) {
    switch (level) {
      case CrowdLevel.low:
        return const Color(0xFF4CAF50);
      case CrowdLevel.medium:
        return const Color(0xFFFF9800);
      case CrowdLevel.high:
        return const Color(0xFFEF5350);
    }
  }
}

// ─── Details card ─────────────────────────────────────────────────

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.station, required this.crowdColor});
  final StationModel station;
  final Color crowdColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          if (station.brand != null)
            _DetailRow(
                icon: Icons.business_rounded,
                label: 'Brand',
                value: station.brand!),
          if (station.openingHours != null)
            _DetailRow(
                icon: Icons.access_time_rounded,
                label: 'Hours',
                value: station.openingHours!),
          if (station.fuelTypes != null)
            _DetailRow(
                icon: Icons.local_gas_station_rounded,
                label: 'Fuel',
                value: station.fuelTypes!),
          if (station.hasPhone)
            _DetailRow(
                icon: Icons.phone_rounded,
                label: 'Phone',
                value: station.phone!,
                valueColor: const Color(0xFF5C6BC0)),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 14, color: const Color(0xFFBBBBBB)),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9E9E9E),
                fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: valueColor ?? const Color(0xFF333333),
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Action buttons ───────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 6),
                Text(label,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    required this.icon,
    required this.color,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withOpacity(0.2), width: 1),
          ),
          child: Icon(icon, color: color, size: 18),
        ),
      ),
    );
  }
}

// ─── Crowd badge ──────────────────────────────────────────────────

class _CrowdBadge extends StatelessWidget {
  const _CrowdBadge({required this.level, required this.color});
  final CrowdLevel level;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.25), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(
            level.name.toUpperCase(),
            style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}

// ─── Info card ────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 11),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 15),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F0F1A))),
          const SizedBox(height: 1),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFFAAAAAA),
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── Crowd level bar ─────────────────────────────────────────────

class _CrowdLevelBar extends StatelessWidget {
  const _CrowdLevelBar({required this.level});
  final CrowdLevel level;

  @override
  Widget build(BuildContext context) {
    final filled = level.index + 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('CROWD LEVEL',
                style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFFAAAAAA),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8)),
            Text(
              '${level.name[0].toUpperCase()}${level.name.substring(1)} — $filled/3',
              style: TextStyle(
                  fontSize: 10,
                  color: _segmentColor(level.index),
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Row(
          children: List.generate(3, (i) {
            final active =
                i < filled ? _segmentColor(i) : const Color(0xFFEEEEEE);
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
                height: 5,
                decoration: BoxDecoration(
                    color: active,
                    borderRadius: BorderRadius.circular(3)),
              ),
            );
          }),
        ),
      ],
    );
  }

  Color _segmentColor(int i) {
    const c = [Color(0xFF4CAF50), Color(0xFFFF9800), Color(0xFFEF5350)];
    return c[i.clamp(0, 2)];
  }
}
