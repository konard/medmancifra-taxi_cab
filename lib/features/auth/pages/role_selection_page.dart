import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/user_model.dart';
import '../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';

class RoleSelectionPage extends StatefulWidget {
  const RoleSelectionPage({super.key});

  @override
  State<RoleSelectionPage> createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  final _nameController = TextEditingController();
  UserRole? _selectedRole;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_selectedRole == null) return;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Введите ваше имя')),
      );
      return;
    }
    context.read<AuthBloc>().add(AuthSelectRole(_selectedRole!, name));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        setState(() => _isSubmitting = state is AuthLoading);
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                // Logo / title
                Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.gold, AppTheme.goldLight],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.gold.withValues(alpha: 0.3),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.local_taxi_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TaxiCab',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Text(
                          'Premium Ride Service',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 48),

                const Text(
                  'Добро пожаловать',
                  style: TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Выберите ваш тип аккаунта для начала работы',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 36),

                // Name field
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Ваше имя',
                    prefixIcon: Icon(Icons.person_outline_rounded),
                    hintText: 'Иван Петров',
                  ),
                ),
                const SizedBox(height: 24),

                // Role cards
                const Text(
                  'КТО ВЫ',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        role: UserRole.passenger,
                        isSelected: _selectedRole == UserRole.passenger,
                        onTap: () =>
                            setState(() => _selectedRole = UserRole.passenger),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoleCard(
                        role: UserRole.driver,
                        isSelected: _selectedRole == UserRole.driver,
                        onTap: () =>
                            setState(() => _selectedRole = UserRole.driver),
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                ElevatedButton(
                  onPressed: (_selectedRole != null && !_isSubmitting)
                      ? _submit
                      : null,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Продолжить'),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Продолжая, вы соглашаетесь с условиями использования',
                    style: TextStyle(
                      color: AppTheme.textDisabled,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final UserRole role;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isPassenger = role == UserRole.passenger;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.gold.withValues(alpha: 0.12)
              : AppTheme.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.gold : Colors.white10,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isPassenger
                  ? Icons.person_rounded
                  : Icons.drive_eta_rounded,
              size: 40,
              color: isSelected ? AppTheme.gold : AppTheme.textSecondary,
            ),
            const SizedBox(height: 12),
            Text(
              isPassenger ? 'Пассажир' : 'Водитель',
              style: TextStyle(
                color: isSelected
                    ? AppTheme.textPrimary
                    : AppTheme.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isPassenger ? 'Заказываю поездки' : 'Выполняю поездки',
              style: const TextStyle(
                color: AppTheme.textDisabled,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
