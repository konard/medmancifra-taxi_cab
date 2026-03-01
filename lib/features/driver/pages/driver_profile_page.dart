import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../shared/widgets/star_rating.dart';
import '../../shared/widgets/user_avatar.dart';
import '../bloc/driver_bloc.dart';

class DriverProfilePage extends StatelessWidget {
  const DriverProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return const SizedBox();

    final user = authState.user;
    final driverState = context.watch<DriverBloc>().state;

    return Scaffold(
      appBar: AppBar(title: const Text('Профиль водителя')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.accent, AppTheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  UserAvatar(
                    photoUrl: user.photoUrl,
                    name: user.name,
                    radius: 44,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.name,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StarRating(rating: user.rating, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${user.rating.toStringAsFixed(1)} · ${user.ratingCount} оценок',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Online toggle
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.power_settings_new_rounded,
                    color: AppTheme.gold,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Принимать заказы',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: driverState.isOnline,
                    onChanged: (val) =>
                        context.read<DriverBloc>().add(DriverSetOnline(val)),
                    activeColor: AppTheme.success,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Settings sections
            _SettingsSection(
              title: 'Настройки',
              items: [
                _SettingsItem(
                  icon: Icons.person_outline_rounded,
                  label: 'Редактировать профиль',
                  onTap: () {},
                ),
                _SettingsItem(
                  icon: Icons.directions_car_outlined,
                  label: 'Данные автомобиля',
                  onTap: () {},
                ),
                _SettingsItem(
                  icon: Icons.notifications_outlined,
                  label: 'Уведомления',
                  onTap: () {},
                ),
                _SettingsItem(
                  icon: Icons.dark_mode_outlined,
                  label: 'Тема',
                  trailing: const Text(
                    'Тёмная',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),

            OutlinedButton.icon(
              onPressed: () => context.read<AuthBloc>().add(AuthLogout()),
              icon: const Icon(Icons.logout_rounded, color: AppTheme.error),
              label: const Text(
                'Выйти',
                style: TextStyle(color: AppTheme.error),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.error),
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<_SettingsItem> items;

  const _SettingsSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            children: items.asMap().entries.map((entry) {
              final isLast = entry.key == items.length - 1;
              return Column(
                children: [
                  entry.value,
                  if (!isLast)
                    const Divider(height: 1, indent: 52, color: Colors.white10),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.surfaceOverlay,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: AppTheme.gold),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
      trailing: trailing ??
          const Icon(
            Icons.chevron_right_rounded,
            color: AppTheme.textDisabled,
            size: 20,
          ),
    );
  }
}
