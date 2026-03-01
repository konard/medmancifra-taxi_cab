import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/ride_model.dart';
import '../../../core/services/ride_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../auth/bloc/auth_bloc.dart';

class PassengerHistoryPage extends StatelessWidget {
  const PassengerHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const SizedBox();
    }

    final rideService = RideService();

    return Scaffold(
      appBar: AppBar(title: const Text('История поездок')),
      body: StreamBuilder<List<RideModel>>(
        stream: rideService.watchPassengerHistory(authState.user.id),
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
                  Icon(
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

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rides.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) => _RideHistoryCard(ride: rides[i]),
          );
        },
      ),
    );
  }
}

class _RideHistoryCard extends StatelessWidget {
  final RideModel ride;

  const _RideHistoryCard({required this.ride});

  @override
  Widget build(BuildContext context) {
    final isCompleted = ride.status == RideStatus.completed;
    final statusColor = isCompleted ? AppTheme.success : AppTheme.error;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isCompleted ? 'Завершена' : 'Отменена',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(ride.createdAt),
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _addressRow(
            Icons.radio_button_checked,
            AppTheme.gold,
            ride.pickupAddress.shortName,
          ),
          const SizedBox(height: 4),
          _addressRow(
            Icons.location_on,
            AppTheme.goldLight,
            ride.destinationAddress.shortName,
          ),
          if (isCompleted) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  '${ride.price.toStringAsFixed(0)} ₽',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                _tariffChip(ride.tariff),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _addressRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _tariffChip(RideTariff tariff) {
    final names = {
      RideTariff.economy: 'Эконом',
      RideTariff.comfort: 'Комфорт',
      RideTariff.business: 'Бизнес',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppTheme.surfaceOverlay,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        names[tariff] ?? tariff.name,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 11,
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays == 0) return 'Сегодня';
    if (diff.inDays == 1) return 'Вчера';
    return '${dt.day}.${dt.month.toString().padLeft(2, '0')}.${dt.year}';
  }
}
