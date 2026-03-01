import 'package:flutter/material.dart';

import '../../../core/models/ride_model.dart';
import '../../../core/services/ride_service.dart';
import '../../../core/theme/app_theme.dart';

class TariffSelector extends StatelessWidget {
  final RideTariff selectedTariff;
  final RouteInfo route;
  final ValueChanged<RideTariff> onTariffSelected;

  const TariffSelector({
    super.key,
    required this.selectedTariff,
    required this.route,
    required this.onTariffSelected,
  });

  @override
  Widget build(BuildContext context) {
    final rideService = RideService();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Тариф',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${route.distanceKm.toStringAsFixed(1)} км · ~${route.durationMinutes} мин',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: RideTariff.values.map((tariff) {
              final isSelected = tariff == selectedTariff;
              final price = rideService.calculateFare(route, tariff);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _TariffCard(
                    tariff: tariff,
                    price: price,
                    isSelected: isSelected,
                    onTap: () => onTariffSelected(tariff),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _TariffCard extends StatelessWidget {
  final RideTariff tariff;
  final double price;
  final bool isSelected;
  final VoidCallback onTap;

  const _TariffCard({
    required this.tariff,
    required this.price,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.gold.withValues(alpha: 0.15)
              : AppTheme.surfaceOverlay,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppTheme.gold : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _tariffIcon,
              color: isSelected ? AppTheme.gold : AppTheme.textSecondary,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              _tariffName,
              style: TextStyle(
                color:
                    isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${price.toStringAsFixed(0)} ₽',
              style: TextStyle(
                color: isSelected ? AppTheme.gold : AppTheme.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData get _tariffIcon {
    switch (tariff) {
      case RideTariff.economy:
        return Icons.directions_car_outlined;
      case RideTariff.comfort:
        return Icons.directions_car_filled_rounded;
      case RideTariff.business:
        return Icons.airport_shuttle_rounded;
    }
  }

  String get _tariffName {
    switch (tariff) {
      case RideTariff.economy:
        return 'Эконом';
      case RideTariff.comfort:
        return 'Комфорт';
      case RideTariff.business:
        return 'Бизнес';
    }
  }
}
