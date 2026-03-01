import 'package:flutter/material.dart';

import '../../../core/models/ride_model.dart';
import '../../../core/theme/app_theme.dart';

class ActiveRideCard extends StatelessWidget {
  final RideModel ride;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  const ActiveRideCard({
    super.key,
    required this.ride,
    required this.onStart,
    required this.onComplete,
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

          // Status header
          Row(
            children: [
              _statusBadge(ride.status),
              const Spacer(),
              Text(
                '${ride.price.toStringAsFixed(0)} ₽',
                style: const TextStyle(
                  color: AppTheme.gold,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Route
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceOverlay,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                _routeRow(
                  Icons.radio_button_checked,
                  AppTheme.gold,
                  'Откуда',
                  ride.pickupAddress.shortName,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 7, top: 4, bottom: 4),
                  child: SizedBox(
                    height: 12,
                    child: VerticalDivider(width: 1, color: AppTheme.textDisabled),
                  ),
                ),
                _routeRow(
                  Icons.location_on,
                  AppTheme.goldLight,
                  'Куда',
                  ride.destinationAddress.shortName,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Action buttons
          if (ride.status == RideStatus.driverAssigned ||
              ride.status == RideStatus.driverArriving)
            ElevatedButton.icon(
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Начать поездку'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: AppTheme.success,
              ),
            )
          else if (ride.status == RideStatus.inProgress)
            ElevatedButton.icon(
              onPressed: onComplete,
              icon: const Icon(Icons.check_circle_rounded),
              label: const Text('Завершить поездку'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                backgroundColor: AppTheme.gold,
              ),
            ),
          const SizedBox(height: 8),
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

  Widget _statusBadge(RideStatus status) {
    final (label, color) = switch (status) {
      RideStatus.driverAssigned => ('Назначен', AppTheme.info),
      RideStatus.driverArriving => ('Подъезжает', AppTheme.warning),
      RideStatus.inProgress => ('В пути', AppTheme.success),
      _ => ('Ожидание', AppTheme.textSecondary),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _routeRow(
    IconData icon,
    Color iconColor,
    String label,
    String address,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                address,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
