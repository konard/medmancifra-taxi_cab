import 'package:cloud_firestore/cloud_firestore.dart';
import 'address_model.dart';

enum RideStatus {
  searching,
  driverAssigned,
  driverArriving,
  inProgress,
  completed,
  cancelled,
}

enum RideTariff { economy, comfort, business }

class RouteInfo {
  final double distanceKm;
  final int durationMinutes;
  final List<List<double>> polylinePoints;

  const RouteInfo({
    required this.distanceKm,
    required this.durationMinutes,
    required this.polylinePoints,
  });
}

class RideModel {
  final String id;
  final String passengerId;
  final String? driverId;
  final AddressModel pickupAddress;
  final AddressModel destinationAddress;
  final RideStatus status;
  final RideTariff tariff;
  final double price;
  final DateTime createdAt;
  final DateTime? completedAt;
  final RouteInfo? routeInfo;
  final String? cancelReason;
  final double? passengerRating;
  final double? driverRating;

  const RideModel({
    required this.id,
    required this.passengerId,
    this.driverId,
    required this.pickupAddress,
    required this.destinationAddress,
    required this.status,
    required this.tariff,
    required this.price,
    required this.createdAt,
    this.completedAt,
    this.routeInfo,
    this.cancelReason,
    this.passengerRating,
    this.driverRating,
  });

  factory RideModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RideModel(
      id: doc.id,
      passengerId: data['passengerId'] ?? '',
      driverId: data['driverId'],
      pickupAddress: AddressModel.fromMap(
        data['pickupAddress'] as Map<String, dynamic>,
      ),
      destinationAddress: AddressModel.fromMap(
        data['destinationAddress'] as Map<String, dynamic>,
      ),
      status: RideStatus.values.firstWhere(
        (s) => s.name == data['status'],
        orElse: () => RideStatus.searching,
      ),
      tariff: RideTariff.values.firstWhere(
        (t) => t.name == data['tariff'],
        orElse: () => RideTariff.economy,
      ),
      price: (data['price'] ?? 0).toDouble(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      cancelReason: data['cancelReason'],
      passengerRating: (data['passengerRating'] as num?)?.toDouble(),
      driverRating: (data['driverRating'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'passengerId': passengerId,
      'driverId': driverId,
      'pickupAddress': pickupAddress.toMap(),
      'destinationAddress': destinationAddress.toMap(),
      'status': status.name,
      'tariff': tariff.name,
      'price': price,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'cancelReason': cancelReason,
      'passengerRating': passengerRating,
      'driverRating': driverRating,
    };
  }

  RideModel copyWith({
    String? driverId,
    RideStatus? status,
    double? price,
    DateTime? completedAt,
    RouteInfo? routeInfo,
    String? cancelReason,
    double? passengerRating,
    double? driverRating,
  }) {
    return RideModel(
      id: id,
      passengerId: passengerId,
      driverId: driverId ?? this.driverId,
      pickupAddress: pickupAddress,
      destinationAddress: destinationAddress,
      status: status ?? this.status,
      tariff: tariff,
      price: price ?? this.price,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
      routeInfo: routeInfo ?? this.routeInfo,
      cancelReason: cancelReason ?? this.cancelReason,
      passengerRating: passengerRating ?? this.passengerRating,
      driverRating: driverRating ?? this.driverRating,
    );
  }
}
