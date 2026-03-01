import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/models/user_model.dart';
import '../core/services/auth_service.dart';
import '../core/services/driver_service.dart';
import '../core/services/ride_service.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/bloc/auth_bloc.dart';
import '../features/auth/pages/role_selection_page.dart';
import '../features/driver/bloc/driver_bloc.dart';
import '../features/driver/pages/driver_home_page.dart';
import '../features/passenger/bloc/passenger_bloc.dart';
import '../features/passenger/pages/passenger_home_page.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthService()),
        RepositoryProvider(create: (_) => RideService()),
        RepositoryProvider(create: (_) => DriverService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (ctx) => AuthBloc(ctx.read<AuthService>())
              ..add(AuthStarted()),
          ),
          BlocProvider(
            create: (ctx) => PassengerBloc(
              ctx.read<RideService>(),
              ctx.read<DriverService>(),
            ),
          ),
          BlocProvider(
            create: (ctx) => DriverBloc(
              ctx.read<RideService>(),
              ctx.read<DriverService>(),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'TaxiCab',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          debugShowCheckedModeBanner: false,
          home: const _AppRouter(),
        ),
      ),
    );
  }
}

class _AppRouter extends StatelessWidget {
  const _AppRouter();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_taxi_rounded,
                    size: 64,
                    color: AppTheme.gold,
                  ),
                  SizedBox(height: 16),
                  CircularProgressIndicator(color: AppTheme.gold),
                ],
              ),
            ),
          );
        }

        if (state is AuthAuthenticated) {
          if (state.user.role == UserRole.passenger) {
            return const PassengerHomePage();
          } else {
            return const DriverHomePage();
          }
        }

        return const RoleSelectionPage();
      },
    );
  }
}
