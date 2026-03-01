import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/address_model.dart';
import '../../../core/models/driver_model.dart';
import '../../../core/models/ride_model.dart';
import '../../../core/services/driver_service.dart';
import '../../../core/services/ride_service.dart';

// Events
abstract class PassengerEvent {}

class PassengerInit extends PassengerEvent {
  final String userId;
  PassengerInit(this.userId);
}

class PassengerSetPickup extends PassengerEvent {
  final AddressModel address;
  PassengerSetPickup(this.address);
}

class PassengerSetDestination extends PassengerEvent {
  final AddressModel address;
  PassengerSetDestination(this.address);
}

class PassengerSelectTariff extends PassengerEvent {
  final RideTariff tariff;
  PassengerSelectTariff(this.tariff);
}

class PassengerRequestRide extends PassengerEvent {}

class PassengerCancelRide extends PassengerEvent {
  final String reason;
  PassengerCancelRide(this.reason);
}

class PassengerRideUpdated extends PassengerEvent {
  final RideModel? ride;
  PassengerRideUpdated(this.ride);
}

class PassengerDriverUpdated extends PassengerEvent {
  final DriverModel? driver;
  PassengerDriverUpdated(this.driver);
}

class PassengerRouteCalculated extends PassengerEvent {
  final RouteInfo route;
  PassengerRouteCalculated(this.route);
}

class PassengerRateDriver extends PassengerEvent {
  final double rating;
  PassengerRateDriver(this.rating);
}

class PassengerReset extends PassengerEvent {}

// State
class PassengerState {
  final String? userId;
  final AddressModel? pickup;
  final AddressModel? destination;
  final RideTariff tariff;
  final RouteInfo? route;
  final RideModel? currentRide;
  final DriverModel? assignedDriver;
  final bool isLoading;
  final String? error;

  const PassengerState({
    this.userId,
    this.pickup,
    this.destination,
    this.tariff = RideTariff.comfort,
    this.route,
    this.currentRide,
    this.assignedDriver,
    this.isLoading = false,
    this.error,
  });

  bool get hasRoute => pickup != null && destination != null;
  bool get isRideActive => currentRide != null &&
      currentRide!.status != RideStatus.completed &&
      currentRide!.status != RideStatus.cancelled;

  double get estimatedPrice {
    if (route == null) return 0;
    return _rideService.calculateFare(route!, tariff);
  }

  PassengerState copyWith({
    String? userId,
    AddressModel? pickup,
    AddressModel? destination,
    RideTariff? tariff,
    RouteInfo? route,
    RideModel? currentRide,
    DriverModel? assignedDriver,
    bool? isLoading,
    String? error,
    bool clearRide = false,
    bool clearDriver = false,
    bool clearRoute = false,
    bool clearPickup = false,
    bool clearDestination = false,
  }) {
    return PassengerState(
      userId: userId ?? this.userId,
      pickup: clearPickup ? null : (pickup ?? this.pickup),
      destination: clearDestination ? null : (destination ?? this.destination),
      tariff: tariff ?? this.tariff,
      route: clearRoute ? null : (route ?? this.route),
      currentRide: clearRide ? null : (currentRide ?? this.currentRide),
      assignedDriver: clearDriver ? null : (assignedDriver ?? this.assignedDriver),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// BLoC
class PassengerBloc extends Bloc<PassengerEvent, PassengerState> {
  final RideService _rideService;
  final DriverService _driverService;
  StreamSubscription? _rideSub;
  StreamSubscription? _driverSub;

  PassengerBloc(this._rideService, this._driverService)
      : super(const PassengerState()) {
    on<PassengerInit>(_onInit);
    on<PassengerSetPickup>(_onSetPickup);
    on<PassengerSetDestination>(_onSetDestination);
    on<PassengerSelectTariff>(_onSelectTariff);
    on<PassengerRequestRide>(_onRequestRide);
    on<PassengerCancelRide>(_onCancelRide);
    on<PassengerRideUpdated>(_onRideUpdated);
    on<PassengerDriverUpdated>(_onDriverUpdated);
    on<PassengerRouteCalculated>(_onRouteCalculated);
    on<PassengerRateDriver>(_onRateDriver);
    on<PassengerReset>(_onReset);
  }

  Future<void> _onInit(PassengerInit event, Emitter<PassengerState> emit) async {
    emit(state.copyWith(userId: event.userId));
    await _rideService.loadHistory();
  }

  Future<void> _onSetPickup(
    PassengerSetPickup event,
    Emitter<PassengerState> emit,
  ) async {
    emit(state.copyWith(pickup: event.address, clearRoute: true));
    _tryCalculateRoute();
  }

  Future<void> _onSetDestination(
    PassengerSetDestination event,
    Emitter<PassengerState> emit,
  ) async {
    emit(state.copyWith(destination: event.address, clearRoute: true));
    _tryCalculateRoute();
  }

  void _tryCalculateRoute() {
    if (state.pickup != null && state.destination != null) {
      _rideService.fetchRoute(state.pickup!, state.destination!).then((route) {
        if (route != null) add(PassengerRouteCalculated(route));
      });
    }
  }

  Future<void> _onRouteCalculated(
    PassengerRouteCalculated event,
    Emitter<PassengerState> emit,
  ) async {
    emit(state.copyWith(route: event.route));
  }

  Future<void> _onSelectTariff(
    PassengerSelectTariff event,
    Emitter<PassengerState> emit,
  ) async {
    emit(state.copyWith(tariff: event.tariff));
  }

  Future<void> _onRequestRide(
    PassengerRequestRide event,
    Emitter<PassengerState> emit,
  ) async {
    if (state.pickup == null || state.destination == null || state.userId == null) {
      return;
    }

    emit(state.copyWith(isLoading: true));

    try {
      final price = state.route != null
          ? _rideService.calculateFare(state.route!, state.tariff)
          : 200.0;

      final ride = await _rideService.createRide(
        passengerId: state.userId!,
        pickup: state.pickup!,
        destination: state.destination!,
        tariff: state.tariff,
        price: price,
      );

      emit(state.copyWith(currentRide: ride, isLoading: false));
      _watchRide(ride.id);
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _watchRide(String rideId) {
    _rideSub?.cancel();
    _rideSub = _rideService.watchRide(rideId).listen((ride) {
      add(PassengerRideUpdated(ride));
    });
  }

  Future<void> _onRideUpdated(
    PassengerRideUpdated event,
    Emitter<PassengerState> emit,
  ) async {
    final ride = event.ride;
    emit(state.copyWith(currentRide: ride));

    if (ride?.driverId != null && state.assignedDriver == null) {
      _watchDriver(ride!.driverId!);
    }

    if (ride?.status == RideStatus.completed ||
        ride?.status == RideStatus.cancelled) {
      _rideSub?.cancel();
      _driverSub?.cancel();
    }
  }

  void _watchDriver(String driverId) {
    _driverSub?.cancel();
    _driverSub = _driverService.watchDriver(driverId).listen((driver) {
      add(PassengerDriverUpdated(driver));
    });
  }

  Future<void> _onDriverUpdated(
    PassengerDriverUpdated event,
    Emitter<PassengerState> emit,
  ) async {
    emit(state.copyWith(assignedDriver: event.driver));
  }

  Future<void> _onCancelRide(
    PassengerCancelRide event,
    Emitter<PassengerState> emit,
  ) async {
    if (state.currentRide == null) return;
    try {
      await _rideService.cancelRide(state.currentRide!.id, event.reason);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onRateDriver(
    PassengerRateDriver event,
    Emitter<PassengerState> emit,
  ) async {
    if (state.currentRide == null) return;
    try {
      await _rideService.rateRide(
        rideId: state.currentRide!.id,
        isPassenger: true,
        rating: event.rating,
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onReset(PassengerReset event, Emitter<PassengerState> emit) async {
    _rideSub?.cancel();
    _driverSub?.cancel();
    emit(PassengerState(userId: state.userId));
  }

  @override
  Future<void> close() {
    _rideSub?.cancel();
    _driverSub?.cancel();
    return super.close();
  }
}
