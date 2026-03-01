import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

class OnlineToggle extends StatelessWidget {
  final bool isOnline;
  final ValueChanged<bool> onToggle;

  const OnlineToggle({
    super.key,
    required this.isOnline,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOnline
              ? AppTheme.success.withValues(alpha: 0.4)
              : Colors.white10,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isOnline ? AppTheme.success : AppTheme.textDisabled,
              shape: BoxShape.circle,
              boxShadow: isOnline
                  ? [
                      BoxShadow(
                        color: AppTheme.success.withValues(alpha: 0.5),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isOnline ? 'Онлайн — принимаем заказы' : 'Офлайн',
              style: TextStyle(
                color:
                    isOnline ? AppTheme.textPrimary : AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch.adaptive(
            value: isOnline,
            onChanged: onToggle,
            activeColor: AppTheme.success,
            inactiveThumbColor: AppTheme.textDisabled,
          ),
        ],
      ),
    );
  }
}
