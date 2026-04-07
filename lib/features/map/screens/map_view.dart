import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import '../controllers/map_controller.dart';
import '../models/station_model.dart';
import '../widgets/custom_loader.dart';
import '../widgets/station_bottom_sheet.dart';
import '../widgets/station_marker.dart';

class MapView extends GetView<PetrolMapController> {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: Column(
        children: [
          // ── Safe-area header ──────────────────────────────────
          _AppHeader(controller: controller),

          // ── Tab bar ───────────────────────────────────────────
          _TabBar(controller: controller),

          // ── Body (map or list) ────────────────────────────────
          Expanded(
            child: Obx(() {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: controller.activeTab.value == AppTab.map
                    ? _MapTab(key: const ValueKey('map'), controller: controller)
                    : _ListTab(key: const ValueKey('list'), controller: controller),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// APP HEADER — respects safe area, no overflow
// ═══════════════════════════════════════════════════════════════

class _AppHeader extends StatelessWidget {
  const _AppHeader({required this.controller});
  final PetrolMapController controller;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;

    return Container(
      color: const Color(0xFF0F0F1A),
      padding: EdgeInsets.fromLTRB(16, top + 12, 16, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFF5C6BC0),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.local_gas_station_rounded,
                color: Colors.white, size: 19),
          ),
          const SizedBox(width: 10),

          // Title block
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'PetrolCrowd',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                    height: 1.1,
                  ),
                ),
                Obx(() {
                  final count = controller.stations.length;
                  final stale = controller.isStale.value;
                  return Text(
                    count == 0
                        ? 'Finding stations…'
                        : '$count stations nearby${stale ? ' · cached' : ''}',
                    style: TextStyle(
                      color: stale
                          ? const Color(0xFFFF9800)
                          : const Color(0x88FFFFFF),
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  );
                }),
              ],
            ),
          ),

          // Stale/refresh indicator
          Obx(() {
            if (controller.isLoading) {
              // return   CustomLoading(size: 45,);
              return   SizedBox.shrink();
            }
            return GestureDetector(
              onTap: controller.refresh,
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  Icons.refresh_rounded,
                  color: controller.isStale.value
                      ? const Color(0xFFFF9800)
                      : Colors.white.withOpacity(0.6),
                  size: 18,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// TAB BAR
// ═══════════════════════════════════════════════════════════════

class _TabBar extends StatelessWidget {
  const _TabBar({required this.controller});
  final PetrolMapController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F0F1A),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Obx(() => Row(
            children: [
              _Tab(
                label: 'Map',
                icon: Icons.map_rounded,
                active: controller.activeTab.value == AppTab.map,
                onTap: () => controller.setTab(AppTab.map),
              ),
              const SizedBox(width: 8),
              _Tab(
                label: 'Nearby',
                icon: Icons.format_list_bulleted_rounded,
                active: controller.activeTab.value == AppTab.list,
                onTap: () => controller.setTab(AppTab.list),
                badge: controller.stations.length,
              ),
            ],
          )),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
    this.badge = 0,
  });

  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color:
              active ? const Color(0xFF5C6BC0) : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: active ? Colors.white : Colors.white.withOpacity(0.5),
                size: 15),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color:
                    active ? Colors.white : Colors.white.withOpacity(0.5),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (badge > 0 && !active) ...[
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF5C6BC0).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// MAP TAB
// ═══════════════════════════════════════════════════════════════

class _MapTab extends StatelessWidget {
  const _MapTab({super.key, required this.controller});
  final PetrolMapController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ── Map ───────────────────────────────────────────────
        _MapLayer(controller: controller),

        // ── Filter chips (top-left over map) ──────────────────
        Positioned(
          top: 12,
          left: 12,
          right: 70,
          child: _FilterRow(controller: controller),
        ),

        // ── My-location FAB ───────────────────────────────────
        Positioned(
          right: 14,
          bottom: 30,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Clear route button (only when route active)
              Obx(() {
                if (controller.routePoints.isEmpty) {
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    _MapFab(
                      icon: Icons.close_rounded,
                      color: const Color(0xFFEF5350),
                      tooltip: 'Clear route',
                      onTap: controller.clearRoute,
                    ),
                    const SizedBox(height: 10),
                  ],
                );
              }),
              _MapFab(
                icon: Icons.my_location_rounded,
                tooltip: 'My Location',
                onTap: controller.centerOnUser,
              ),
            ],
          ),
        ),

        // ── Route loading indicator ────────────────────────────
        Obx(() {
          if (!controller.isLoadingRoute.value) {
            return const SizedBox.shrink();
          }
          return Positioned(
            bottom: 30,
            left: 14,
            child: _RoutingPill(),
          );
        }),

        // ── Error banner ──────────────────────────────────────
        Obx(() {
          if (controller.errorMessage.isEmpty || controller.isLoading) {
            return const SizedBox.shrink();
          }
          return Positioned(
            bottom: 30,
            left: 14,
            right: 70,
            child: _ErrorBanner(
              message: controller.errorMessage.value,
              onRetry: controller.refresh,
            ),
          );
        }),

        // ── Loading spinner ────────────────────────────────────
        Obx(() {
          if (!controller.isLoading) return const SizedBox.shrink();
          return _LoadingOverlay(
            message: controller.isLoadingLocation.value
                ? 'Getting your location…'
                : 'Finding stations nearby…',
          );
        }),
      ],
    );
  }
}

// ─── Map layer with route polyline ────────────────────────────────

class _MapLayer extends StatelessWidget {
  const _MapLayer({required this.controller});
  final PetrolMapController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final userLoc =
          controller.userLocation.value ?? PetrolMapController.fallbackLatLng;

      return FlutterMap(
        mapController: controller.mapController,
        options: MapOptions(
          initialCenter: userLoc,
          initialZoom: 14.0,
          onTap: (_, __) => controller.clearSelection(),
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
          ),
        ),
        children: [
          // OSM tiles
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.petrol_crowd',
            retinaMode: true,
          ),

          // Route polyline
          Obx(() {
            if (controller.routePoints.isEmpty) {
              return const SizedBox.shrink();
            }
            return PolylineLayer(
              polylines: [
                Polyline(
                  points: controller.routePoints,
                  strokeWidth: 4.5,
                  color: const Color(0xFF5C6BC0),
                  borderColor: const Color(0x335C6BC0),
                  borderStrokeWidth: 8,
                ),
              ],
            );
          }),

          // Markers
          Obx(() => MarkerLayer(markers: _buildMarkers(context))),
        ],
      );
    });
  }

  List<Marker> _buildMarkers(BuildContext context) {
    final markers = <Marker>[];

    final userLoc = controller.userLocation.value;
    if (userLoc != null) {
      markers.add(Marker(
        point: userLoc,
        width: 40,
        height: 40,
        child: const UserLocationMarker(),
      ));
    }

    for (final station in controller.filteredStations) {
      final isSelected = controller.selectedStation.value?.id == station.id;
      markers.add(Marker(
        point: station.position,
        width: 40,
        height: 48,
        alignment: Alignment.topCenter,
        child: StationMarker(
          station: station,
          isSelected: isSelected,
          onTap: () {
            controller.selectStation(station);
            StationBottomSheet.show(context, station, controller);
          },
        ),
      ));
    }

    return markers;
  }
}

// ─── Filter chips ─────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.controller});
  final PetrolMapController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.stations.isEmpty) return const SizedBox.shrink();
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        child: Row(
          children: [
            _FilterChip(
              label: 'Low',
              color: const Color(0xFF4CAF50),
              active: controller.filterLevel.value == 'low',
              onTap: () => controller.setFilter('low'),
            ),
            const SizedBox(width: 7),
            _FilterChip(
              label: 'Medium',
              color: const Color(0xFFFF9800),
              active: controller.filterLevel.value == 'medium',
              onTap: () => controller.setFilter('medium'),
            ),
            const SizedBox(width: 7),
            _FilterChip(
              label: 'High',
              color: const Color(0xFFEF5350),
              active: controller.filterLevel.value == 'high',
              onTap: () => controller.setFilter('high'),
            ),
          ],
        ),
      );
    });
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.color,
    required this.active,
    required this.onTap,
  });

  final String label;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
        decoration: BoxDecoration(
          color: active ? color : const Color(0xEE1C1C2E),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? color : Colors.white.withOpacity(0.15),
            width: 1,
          ),
          boxShadow: active
              ? [
                  BoxShadow(
                      color: color.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white.withOpacity(0.75),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// LIST TAB — stations sorted by distance
// ═══════════════════════════════════════════════════════════════

class _ListTab extends StatelessWidget {
  const _ListTab({super.key, required this.controller});
  final PetrolMapController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0F0F1A),
      child: Obx(() {
        if (controller.isLoading) {
          return const CustomLoading(size: 80,);
        }

        final stations = controller.filteredStations;

        if (stations.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_gas_station_outlined,
                    color: Colors.white.withOpacity(0.2), size: 52),
                const SizedBox(height: 16),
                Text(
                  controller.filterLevel.value.isEmpty
                      ? 'No stations found nearby'
                      : 'No ${controller.filterLevel.value} crowd stations',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.4),
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // ── Filter chips row ─────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'All',
                    color: const Color(0xFF5C6BC0),
                    active: controller.filterLevel.value.isEmpty,
                    onTap: () => controller.setFilter(''),
                  ),
                  const SizedBox(width: 7),
                  _FilterChip(
                    label: 'Low',
                    color: const Color(0xFF4CAF50),
                    active: controller.filterLevel.value == 'low',
                    onTap: () => controller.setFilter('low'),
                  ),
                  const SizedBox(width: 7),
                  _FilterChip(
                    label: 'Medium',
                    color: const Color(0xFFFF9800),
                    active: controller.filterLevel.value == 'medium',
                    onTap: () => controller.setFilter('medium'),
                  ),
                  const SizedBox(width: 7),
                  _FilterChip(
                    label: 'High',
                    color: const Color(0xFFEF5350),
                    active: controller.filterLevel.value == 'high',
                    onTap: () => controller.setFilter('high'),
                  ),
                ],
              ),
            ),

            // ── List ─────────────────────────────────────────
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                itemCount: stations.length,
                itemBuilder: (context, index) => _StationListTile(
                  station: stations[index],
                  index: index,
                  controller: controller,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _StationListTile extends StatelessWidget {
  const _StationListTile({
    required this.station,
    required this.index,
    required this.controller,
  });

  final StationModel station;
  final int index;
  final PetrolMapController controller;

  @override
  Widget build(BuildContext context) {
    final color = _crowdColor(station.crowdLevel);

    return GestureDetector(
      onTap: () => StationBottomSheet.show(context, station, controller),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: Colors.white.withOpacity(0.06),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // ── Rank badge
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '${index + 1}',
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ── Name + meta
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    station.displayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _MetaChip(
                          label: station.distanceLabel, icon: Icons.near_me_rounded),
                      const SizedBox(width: 6),
                      _MetaChip(
                          label: station.waitTime,
                          icon: Icons.schedule_rounded),
                      if (station.hasPhone) ...[
                        const SizedBox(width: 6),
                        const _MetaChip(
                            label: 'Phone', icon: Icons.phone_rounded),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // ── Crowd dot + direction button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                            color: color, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        station.crowdLabel,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // In-app route button
                GestureDetector(
                  onTap: () => controller.fetchRoute(station),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF5C6BC0).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.directions_rounded,
                            color: Color(0xFF5C6BC0), size: 12),
                        SizedBox(width: 3),
                        Text(
                          'Route',
                          style: TextStyle(
                            color: Color(0xFF5C6BC0),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

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

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.35), size: 11),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SHARED OVERLAY WIDGETS
// ═══════════════════════════════════════════════════════════════

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 80,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFF1C1C2E),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                  color: Color(0x55000000),
                  blurRadius: 20,
                  offset: Offset(0, 4)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CustomLoading(size: 30,),
              const SizedBox(width: 10),
              Text(message,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoutingPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C2E),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
            color: const Color(0xFF5C6BC0).withOpacity(0.4), width: 1),
        boxShadow: const [
          BoxShadow(
              color: Color(0x44000000),
              blurRadius: 12,
              offset: Offset(0, 3)),
        ],
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomLoading(size: 30,),
          SizedBox(width: 9),
          Text('Calculating route…',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C2E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFFEF5350).withOpacity(0.35), width: 1),
        boxShadow: const [
          BoxShadow(
              color: Color(0x44000000),
              blurRadius: 14,
              offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: Color(0xFFEF5350), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w400)),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF5C6BC0),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text('Retry',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapFab extends StatelessWidget {
  const _MapFab({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color = Colors.white,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color color;

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
            color: color == Colors.white ? Colors.white : color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4)),
            ],
          ),
          child: Icon(
            icon,
            color: color == Colors.white
                ? const Color(0xFF0F0F1A)
                : Colors.white,
            size: 21,
          ),
        ),
      ),
    );
  }
}
