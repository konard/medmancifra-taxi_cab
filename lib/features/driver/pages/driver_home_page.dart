import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../core/models/ride_model.dart';
import '../../../core/services/ride_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../bloc/driver_bloc.dart';
import '../widgets/active_ride_card.dart';
import '../widgets/available_orders_list.dart';
import '../widgets/online_toggle.dart';
import 'driver_history_page.dart';
import 'driver_profile_page.dart';

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<DriverBloc>().add(DriverInit(authState.user.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DriverBloc, DriverState>(
      listenWhen: (prev, curr) =>
          prev.currentRide?.status != curr.currentRide?.status,
      listener: (context, state) {
        if (state.currentRide?.status == RideStatus.completed) {
          _showRatingSheet(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: IndexedStack(
            index: _selectedTab,
            children: [
              _buildMainView(context, state),
              const DriverHistoryPage(),
              const DriverProfilePage(),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(context, state),
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, DriverState state) {
    final newOrdersCount = state.availableRides.length;
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
            isLabelVisible: newOrdersCount > 0,
            label: Text('$newOrdersCount'),
            child: const Icon(Icons.list_alt_rounded),
          ),
          label: 'Заказы',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_rounded),
          label: 'Профиль',
        ),
      ],
    );
  }

  Widget _buildMainView(BuildContext context, DriverState state) {
    return Stack(
      children: [
        // Map
        FlutterMap(
          options: const MapOptions(
            initialCenter: LatLng(55.7558, 37.6173),
            initialZoom: 14,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.taxi_project',
            ),
            if (state.currentRide?.routeInfo != null)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: state.currentRide!.routeInfo!.polylinePoints
                        .map((p) => LatLng(p[0], p[1]))
                        .toList(),
                    strokeWidth: 4,
                    color: AppTheme.gold,
                  ),
                ],
              ),
          ],
        ),

        // Online toggle at top
        Positioned(
          top: MediaQuery.of(context).padding.top + 16,
          left: 16,
          right: 16,
          child: OnlineToggle(
            isOnline: state.isOnline,
            onToggle: (val) =>
                context.read<DriverBloc>().add(DriverSetOnline(val)),
          ),
        ),

        // Main content at bottom
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: _buildBottomContent(context, state),
        ),
      ],
    );
  }

  Widget _buildBottomContent(BuildContext context, DriverState state) {
    if (state.hasActiveRide && state.currentRide != null) {
      return ActiveRideCard(
        ride: state.currentRide!,
        onStart: () => context.read<DriverBloc>().add(DriverStartRide()),
        onComplete: () =>
            context.read<DriverBloc>().add(DriverCompleteRide()),
        onCancel: () => _showCancelDialog(context),
      );
    }

    if (!state.isOnline) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.power_settings_new_rounded,
              color: AppTheme.textDisabled,
              size: 40,
            ),
            const SizedBox(height: 12),
            const Text(
              'Вы офлайн',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Включите режим онлайн, чтобы получать заказы',
              style: TextStyle(
                color: AppTheme.textDisabled,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return AvailableOrdersList(
      rides: state.availableRides,
      onAccept: (ride) =>
          context.read<DriverBloc>().add(DriverAcceptRide(ride.id)),
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
            const SizedBox(height: 16),
            ...[
              'Пассажир не вышел',
              'Неверный адрес',
              'Непредвиденные обстоятельства',
              'Другое',
            ].map(
              (reason) => ListTile(
                title: Text(
                  reason,
                  style: const TextStyle(color: AppTheme.textPrimary),
                ),
                onTap: () {
                  Navigator.pop(context);
                  context
                      .read<DriverBloc>()
                      .add(DriverCancelRide(reason));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRatingSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceCard,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: AppTheme.success, size: 56),
            const SizedBox(height: 16),
            const Text(
              'Поездка завершена!',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Оцените пассажира',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.read<DriverBloc>().add(DriverRatePassenger(5.0));
              },
              child: const Text('Оценить 5 звёзд'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Пропустить'),
            ),
          ],
        ),
      ),
    );
  }
}
