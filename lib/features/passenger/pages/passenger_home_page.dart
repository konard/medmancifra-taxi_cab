import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/models/ride_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/passenger_bloc.dart';
import '../widgets/address_panel.dart';
import '../widgets/driver_arriving_card.dart';
import '../widgets/driver_found_card.dart';
import '../widgets/rating_sheet.dart';
import '../widgets/searching_animation.dart';
import '../widgets/tariff_selector.dart';
import 'passenger_history_page.dart';
import 'passenger_profile_page.dart';

class PassengerHomePage extends StatefulWidget {
  const PassengerHomePage({super.key});

  @override
  State<PassengerHomePage> createState() => _PassengerHomePageState();
}

class _PassengerHomePageState extends State<PassengerHomePage> {
  final _mapController = MapController();
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<PassengerBloc>().add(PassengerInit(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PassengerBloc, PassengerState>(
      listenWhen: (prev, curr) =>
          prev.currentRide?.status != curr.currentRide?.status,
      listener: (context, state) {
        if (state.currentRide?.status == RideStatus.completed) {
          _showRatingSheet(context, state.currentRide!.id);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(
            index: _selectedTab,
            children: [
              _buildMapView(context, state),
              const PassengerHistoryPage(),
              const PassengerProfilePage(),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(context, state),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, PassengerState state) {
    final responseCount = 0; // TODO: connect to PassengerService
    return BottomNavigationBar(
      currentIndex: _selectedTab,
      onTap: (i) => setState(() => _selectedTab = i),
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: 'Главная',
        ),
        BottomNavigationBarItem(
          icon: Badge(
            isLabelVisible: responseCount > 0,
            label: Text('$responseCount'),
            child: const Icon(Icons.reply_all_rounded),
          ),
          label: 'Отклики',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Профиль',
        ),
      ],
    );
  }

  Widget _buildMapView(BuildContext context, PassengerState state) {
    return Stack(
      children: [
        // ── Map ──────────────────────────────────────────────────────────
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _getMapCenter(state),
            initialZoom: 14,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.taxi_project',
            ),
            if (state.route != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: state.route!.polylinePoints
                        .map((p) => LatLng(p[0], p[1]))
                        .toList(),
                    strokeWidth: 4,
                    color: AppTheme.gold,
                  ),
                ],
              ),
            MarkerLayer(
              markers: [
                if (state.pickup != null)
                  Marker(
                    point: LatLng(
                      state.pickup!.lat,
                      state.pickup!.lon,
                    ),
                    child: _pickupMarker(),
                  ),
                if (state.destination != null)
                  Marker(
                    point: LatLng(
                      state.destination!.lat,
                      state.destination!.lon,
                    ),
                    child: _destinationMarker(),
                  ),
                if (state.assignedDriver?.currentLat != null)
                  Marker(
                    point: LatLng(
                      state.assignedDriver!.currentLat!,
                      state.assignedDriver!.currentLon!,
                    ),
                    child: _driverMarker(),
                  ),
              ],
            ),
          ],
        ),

        // ── Overlay: panels based on ride status ─────────────────────────
        Positioned.fill(
          child: _buildOverlay(context, state),
        ),
      ],
    );
  }

  Widget _buildOverlay(BuildContext context, PassengerState state) {
    if (state.currentRide == null || !state.isRideActive) {
      // Booking flow
      return Column(
        children: [
          // Route panel at top
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
            ),
            child: AddressPanel(
              pickup: state.pickup,
              destination: state.destination,
            ),
          ),
          const Spacer(),
          // Tariff + Order at bottom
          if (state.pickup != null && state.destination != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (state.route != null)
                    TariffSelector(
                      selectedTariff: state.tariff,
                      route: state.route!,
                      onTariffSelected: (t) {
                        context
                            .read<PassengerBloc>()
                            .add(PassengerSelectTariff(t));
                      },
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: state.isLoading
                        ? null
                        : () => context
                            .read<PassengerBloc>()
                            .add(PassengerRequestRide()),
                    child: state.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          )
                        : const Text('Заказать поездку'),
                  ),
                ],
              ),
            ),
        ],
      );
    }

    switch (state.currentRide!.status) {
      case RideStatus.searching:
        return SearchingAnimation(
          pickup: state.pickup!,
          destination: state.destination!,
          onCancel: () => _showCancelDialog(context),
        );

      case RideStatus.driverAssigned:
        if (state.assignedDriver == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return Align(
          alignment: Alignment.bottomCenter,
          child: DriverFoundCard(
            driver: state.assignedDriver!,
            ride: state.currentRide!,
            onCancel: () => _showCancelDialog(context),
          ),
        );

      case RideStatus.driverArriving:
        if (state.assignedDriver == null) {
          return const SizedBox();
        }
        return Align(
          alignment: Alignment.bottomCenter,
          child: DriverArrivingCard(
            driver: state.assignedDriver!,
            ride: state.currentRide!,
            onCancel: () => _showCancelDialog(context),
          ),
        );

      case RideStatus.inProgress:
        return Align(
          alignment: Alignment.bottomCenter,
          child: _buildInProgressCard(context, state),
        );

      case RideStatus.completed:
      case RideStatus.cancelled:
        return const SizedBox();
    }
  }

  Widget _buildInProgressCard(BuildContext context, PassengerState state) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_car_rounded,
                  color: AppTheme.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Поездка началась',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Едем к ${state.destination?.shortName ?? 'цели'}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (state.route != null) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _infoChip(
                  Icons.straighten,
                  '${state.route!.distanceKm.toStringAsFixed(1)} км',
                ),
                _infoChip(
                  Icons.schedule,
                  '~${state.route!.durationMinutes} мин',
                ),
                _infoChip(
                  Icons.payments_rounded,
                  '${state.currentRide!.price.toStringAsFixed(0)} ₽',
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceOverlay,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  LatLng _getMapCenter(PassengerState state) {
    if (state.pickup != null) {
      return LatLng(state.pickup!.lat, state.pickup!.lon);
    }
    return const LatLng(55.7558, 37.6173); // Moscow default
  }

  Widget _pickupMarker() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: const BoxDecoration(
        color: AppTheme.gold,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: AppTheme.gold, blurRadius: 8, spreadRadius: 1),
        ],
      ),
      child: const Icon(Icons.circle, color: Colors.white, size: 8),
    );
  }

  Widget _destinationMarker() {
    return const Icon(
      Icons.location_on,
      color: AppTheme.gold,
      size: 36,
      shadows: [
        Shadow(color: Colors.black54, blurRadius: 8),
      ],
    );
  }

  Widget _driverMarker() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.gold, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 6,
          ),
        ],
      ),
      child: const Icon(
        Icons.local_taxi_rounded,
        color: AppTheme.gold,
        size: 16,
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Отменить поездку?',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Выберите причину отмены:',
              style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ...[
              'Изменились планы',
              'Долгое ожидание',
              'Нашёл другой транспорт',
              'Другое',
            ].map(
              (reason) => ListTile(
                title: Text(
                  reason,
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
                leading: const Icon(
                  Icons.radio_button_unchecked,
                  color: AppTheme.textSecondary,
                ),
                onTap: () {
                  Navigator.pop(context);
                  context
                      .read<PassengerBloc>()
                      .add(PassengerCancelRide(reason));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRatingSheet(BuildContext context, String rideId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceCard,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => RatingSheet(
        title: 'Оцените водителя',
        onRated: (rating) {
          Navigator.pop(ctx);
          context.read<PassengerBloc>().add(PassengerRateDriver(rating));
          Future.delayed(
            const Duration(seconds: 1),
            () => context.read<PassengerBloc>().add(PassengerReset()),
          );
        },
      ),
    );
  }
}
