import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/models/driver_model.dart';
import '../../../core/models/ride_model.dart';
import '../../../core/services/driver_service.dart';
import '../../../core/services/ride_service.dart';

// Events
abstract class DriverEvent {}

class DriverInit extends DriverEvent {
  final String driverId;
  DriverInit(this.driverId);
}

class DriverSetOnline extends DriverEvent {
  final bool isOnline;
  DriverSetOnline(this.isOnline);
}

class DriverAcceptRide extends DriverEvent {
  final String rideId;
  DriverAcceptRide(this.rideId);
}

class DriverStartRide extends DriverEvent {}

class DriverCompleteRide extends DriverEvent {}

class DriverCancelRide extends DriverEvent {
  final String reason;
  DriverCancelRide(this.reason);
}

class DriverAvailableRidesUpdated extends DriverEvent {
  final List<RideModel> rides;
  DriverAvailableRidesUpdated(this.rides);
}

class DriverCurrentRideUpdated extends DriverEvent {
  final RideModel? ride;
  DriverCurrentRideUpdated(this.ride);
}

class DriverLocationUpdated extends DriverEvent {
  final double lat;
  final double lon;
  DriverLocationUpdated(this.lat, this.lon);
}

class DriverRatePassenger extends DriverEvent {
  final double rating;
  DriverRatePassenger(this.rating);
}

// State
class DriverState {
  final String? driverId;
  final DriverModel? driver;
  final bool isOnline;
  final List<RideModel> availableRides;
  final RideModel? currentRide;
  final bool isLoading;
  final String? error;

  const DriverState({
    this.driverId,
    this.driver,
    this.isOnline = false,
    this.availableRides = const [],
    this.currentRide,
    this.isLoading = false,
    this.error,
  });

  bool get hasActiveRide =>
      currentRide != null &&
      currentRide!.status != RideStatus.completed &&
      currentRide!.status != RideStatus.cancelled;

  DriverState copyWith({
    String? driverId,
    DriverModel? driver,
    bool? isOnline,
    List<RideModel>? availableRides,
    RideModel? currentRide,
    bool? isLoading,
    String? error,
    bool clearRide = false,
  }) {
    return DriverState(
      driverId: driverId ?? this.driverId,
      driver: driver ?? this.driver,
      isOnline: isOnline ?? this.isOnline,
      availableRides: availableRides ?? this.availableRides,
      currentRide: clearRide ? null : (currentRide ?? this.currentRide),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// BLoC
class DriverBloc extends Bloc<DriverEvent, DriverState> {
  final RideService _rideService;
  final DriverService _driverService;
  StreamSubscription? _availableRidesSub;
  StreamSubscription? _currentRideSub;

  DriverBloc(this._rideService, this._driverService)
      : super(const DriverState()) {
    on<DriverInit>(_onInit);
    on<DriverSetOnline>(_onSetOnline);
    on<DriverAcceptRide>(_onAcceptRide);
    on<DriverStartRide>(_onStartRide);
    on<DriverCompleteRide>(_onCompleteRide);
    on<DriverCancelRide>(_onCancelRide);
    on<DriverAvailableRidesUpdated>(_onAvailableRidesUpdated);
    on<DriverCurrentRideUpdated>(_onCurrentRideUpdated);
    on<DriverLocationUpdated>(_onLocationUpdated);
    on<DriverRatePassenger>(_onRatePassenger);
  }

  Future<void> _onInit(DriverInit event, Emitter<DriverState> emit) async {
    emit(state.copyWith(driverId: event.driverId));

    // Watch available rides sorted by price DESC
    _availableRidesSub?.cancel();
    _availableRidesSub =
        _rideService.watchAvailableRides().listen((rides) {
      add(DriverAvailableRidesUpdated(rides));
    });
  }

  Future<void> _onSetOnline(
    DriverSetOnline event,
    Emitter<DriverState> emit,
  ) async {
    if (state.driverId == null) return;
    try {
      await _driverService.setOnlineStatus(state.driverId!, event.isOnline);
      emit(state.copyWith(isOnline: event.isOnline));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onAcceptRide(
    DriverAcceptRide event,
    Emitter<DriverState> emit,
  ) async {
    if (state.driverId == null) return;
    emit(state.copyWith(isLoading: true));

    try {
      await _rideService.acceptRide(event.rideId, state.driverId!);
      await _driverService.setCurrentRide(state.driverId!, event.rideId);

      emit(state.copyWith(isLoading: false));
      _watchCurrentRide(event.rideId);
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  void _watchCurrentRide(String rideId) {
    _currentRideSub?.cancel();
    _currentRideSub = _rideService.watchRide(rideId).listen((ride) {
      add(DriverCurrentRideUpdated(ride));
    });
  }

  Future<void> _onStartRide(
    DriverStartRide event,
    Emitter<DriverState> emit,
  ) async {
    if (state.currentRide == null) return;
    try {
      await _rideService.updateRideStatus(
        state.currentRide!.id,
        RideStatus.inProgress,
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onCompleteRide(
    DriverCompleteRide event,
    Emitter<DriverState> emit,
  ) async {
    if (state.currentRide == null || state.driverId == null) return;
    try {
      await _rideService.updateRideStatus(
        state.currentRide!.id,
        RideStatus.completed,
      );
      await _driverService.setCurrentRide(state.driverId!, null);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onCancelRide(
    DriverCancelRide event,
    Emitter<DriverState> emit,
  ) async {
    if (state.currentRide == null || state.driverId == null) return;
    try {
      await _rideService.cancelRide(state.currentRide!.id, event.reason);
      await _driverService.setCurrentRide(state.driverId!, null);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onAvailableRidesUpdated(
    DriverAvailableRidesUpdated event,
    Emitter<DriverState> emit,
  ) async {
    // Sort by price DESC
    final sorted = List<RideModel>.from(event.rides)
      ..sort((a, b) => b.price.compareTo(a.price));
    emit(state.copyWith(availableRides: sorted));
  }

  Future<void> _onCurrentRideUpdated(
    DriverCurrentRideUpdated event,
    Emitter<DriverState> emit,
  ) async {
    emit(state.copyWith(currentRide: event.ride));

    if (event.ride?.status == RideStatus.completed ||
        event.ride?.status == RideStatus.cancelled) {
      _currentRideSub?.cancel();
    }
  }

  Future<void> _onLocationUpdated(
    DriverLocationUpdated event,
    Emitter<DriverState> emit,
  ) async {
    if (state.driverId == null) return;
    await _driverService.updateLocation(
      state.driverId!,
      event.lat,
      event.lon,
    );
  }

  Future<void> _onRatePassenger(
    DriverRatePassenger event,
    Emitter<DriverState> emit,
  ) async {
    if (state.currentRide == null) return;
    try {
      await _rideService.rateRide(
        rideId: state.currentRide!.id,
        isPassenger: false,
        rating: event.rating,
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _availableRidesSub?.cancel();
    _currentRideSub?.cancel();
    return super.close();
  }
}
