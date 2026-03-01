import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/ride_model.dart';
import '../../../core/services/ride_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/bloc/auth_bloc.dart';

class DriverHistoryPage extends StatelessWidget {
  const DriverHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return const SizedBox();

    final rideService = RideService();

    return Scaffold(
      appBar: AppBar(title: const Text('Мои поездки')),
      body: StreamBuilder<List<RideModel>>(
        stream: rideService.watchDriverHistory(authState.user.id),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final rides = snap.data ?? [];
          if (rides.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.history_rounded,
                    size: 64,
                    color: AppTheme.textDisabled,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Поездок ещё нет',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            );
          }

          // Stats summary
          final completed = rides.where((r) => r.status == RideStatus.completed);
          final totalEarnings = completed.fold(0.0, (sum, r) => sum + r.price);

          return Column(
            children: [
              // Earnings summary
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.accent, AppTheme.secondary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Всего заработано',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${totalEarnings.toStringAsFixed(0)} ₽',
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          'Поездок',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${completed.length}',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Ride list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: rides.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _DriverRideCard(ride: rides[i]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DriverRideCard extends StatelessWidget {
  final RideModel ride;

  const _DriverRideCard({required this.ride});

  @override
  Widget build(BuildContext context) {
    final isCompleted = ride.status == RideStatus.completed;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _statusChip(ride.status),
                    const Spacer(),
                    Text(
                      _formatDate(ride.createdAt),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  ride.pickupAddress.shortName,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '→ ${ride.destinationAddress.shortName}',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (isCompleted) ...[
            const SizedBox(width: 16),
            Text(
              '${ride.price.toStringAsFixed(0)} ₽',
              style: const TextStyle(
                color: AppTheme.gold,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusChip(RideStatus status) {
    final isCompleted = status == RideStatus.completed;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: (isCompleted ? AppTheme.success : AppTheme.error).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isCompleted ? 'Завершена' : 'Отменена',
        style: TextStyle(
          color: isCompleted ? AppTheme.success : AppTheme.error,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }
}
