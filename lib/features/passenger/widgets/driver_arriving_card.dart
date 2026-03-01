import 'package:flutter/material.dart';

import '../../../core/models/driver_model.dart';
import '../../../core/models/ride_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/user_avatar.dart';

class DriverArrivingCard extends StatelessWidget {
  final DriverModel driver;
  final RideModel ride;
  final VoidCallback onCancel;

  const DriverArrivingCard({
    super.key,
    required this.driver,
    required this.ride,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.gold.withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, -8),
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
              // Animated arrival indicator
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.gold, AppTheme.goldLight],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.gold.withValues(alpha: 0.4),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_taxi_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Водитель приближается',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      driver.name,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              UserAvatar(
                photoUrl: driver.photoUrl,
                name: driver.name,
                radius: 24,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Car plate
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceOverlay,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.directions_car_rounded,
                  color: AppTheme.gold,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  '${driver.car.displayName} · ${driver.car.licensePlate}',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          OutlinedButton.icon(
            onPressed: onCancel,
            icon: const Icon(Icons.close, size: 16),
            label: const Text('Отменить'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.error,
              side: const BorderSide(color: AppTheme.error),
              minimumSize: const Size.fromHeight(44),
            ),
          ),
        ],
      ),
    );
  }
}
