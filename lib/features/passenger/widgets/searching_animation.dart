import 'package:flutter/material.dart';

import '../../../core/models/address_model.dart';
import '../../../core/theme/app_theme.dart';

class SearchingAnimation extends StatefulWidget {
  final AddressModel pickup;
  final AddressModel destination;
  final VoidCallback onCancel;

  const SearchingAnimation({
    super.key,
    required this.pickup,
    required this.destination,
    required this.onCancel,
  });

  @override
  State<SearchingAnimation> createState() => _SearchingAnimationState();
}

class _SearchingAnimationState extends State<SearchingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(),
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(24),
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
              // Animated icon
              ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppTheme.gold,
                        AppTheme.goldLight,
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.gold.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Ищем водителя',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Подбираем лучшего водителя рядом с вами...',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // Route summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceOverlay,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _routeRow(
                      Icons.radio_button_checked,
                      AppTheme.gold,
                      widget.pickup.shortName,
                    ),
                    const SizedBox(height: 6),
                    _routeRow(
                      Icons.location_on,
                      AppTheme.goldLight,
                      widget.destination.shortName,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: widget.onCancel,
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Отменить'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _routeRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
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
}
