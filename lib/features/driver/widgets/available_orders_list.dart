import 'package:flutter/material.dart';

import '../../../core/models/ride_model.dart';
import '../../../core/theme/app_theme.dart';

class AvailableOrdersList extends StatelessWidget {
  final List<RideModel> rides;
  final ValueChanged<RideModel> onAccept;

  const AvailableOrdersList({
    super.key,
    required this.rides,
    required this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    if (rides.isEmpty) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.search_rounded,
              color: AppTheme.textDisabled,
              size: 40,
            ),
            const SizedBox(height: 12),
            const Text(
              'Ищем заказы...',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Новые заказы появятся здесь автоматически',
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

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Row(
              children: [
                Text(
                  'Доступные заказы',
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${rides.length}',
                    style: const TextStyle(
                      color: AppTheme.gold,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              shrinkWrap: true,
              itemCount: rides.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) => _OrderCard(
                ride: rides[i],
                onAccept: () => onAccept(rides[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final RideModel ride;
  final VoidCallback onAccept;

  const _OrderCard({required this.ride, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Price badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.gold, AppTheme.goldLight],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.gold.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Text(
                  '${ride.price.toStringAsFixed(0)} ₽',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _tariffBadge(ride.tariff),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(ride.createdAt),
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              // Accept button
              ElevatedButton(
                onPressed: onAccept,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(80, 40),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('Принять'),
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
        ],
      ),
    );
  }

  Widget _tariffBadge(RideTariff tariff) {
    final names = {
      RideTariff.economy: 'Эконом',
      RideTariff.comfort: 'Комфорт',
      RideTariff.business: 'Бизнес',
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppTheme.surfaceOverlay,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        names[tariff] ?? tariff.name,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
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

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'только что';
    if (diff.inMinutes < 60) return '${diff.inMinutes} мин назад';
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
