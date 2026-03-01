import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/address_model.dart';
import '../../../core/services/ride_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../shared/widgets/address_search_field.dart';
import '../bloc/passenger_bloc.dart';

class AddressPanel extends StatelessWidget {
  final AddressModel? pickup;
  final AddressModel? destination;
  final List<AddressModel> history;

  const AddressPanel({
    super.key,
    this.pickup,
    this.destination,
    this.history = const [],
  });

  @override
  Widget build(BuildContext context) {
    final rideService = RideService();
    final historyAddresses = rideService.history;

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
        mainAxisSize: MainAxisSize.min,
        children: [
          // Pickup
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: AppTheme.gold,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Container(
                    width: 1.5,
                    height: 24,
                    color: AppTheme.textDisabled,
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppTheme.gold,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  children: [
                    AddressSearchField(
                      hint: 'Откуда',
                      value: pickup,
                      prefixIcon: null,
                      prefixIconColor: AppTheme.gold,
                      recentHistory: historyAddresses,
                      onSelected: (addr) {
                        context
                            .read<PassengerBloc>()
                            .add(PassengerSetPickup(addr));
                      },
                    ),
                    const SizedBox(height: 8),
                    AddressSearchField(
                      hint: 'Куда',
                      value: destination,
                      prefixIcon: null,
                      prefixIconColor: AppTheme.gold,
                      recentHistory: historyAddresses,
                      onSelected: (addr) {
                        context
                            .read<PassengerBloc>()
                            .add(PassengerSetDestination(addr));
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
