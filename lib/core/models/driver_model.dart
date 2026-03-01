import 'package:cloud_firestore/cloud_firestore.dart';

class CarModel {
  final String make;
  final String model;
  final String color;
  final String licensePlate;
  final int year;

  const CarModel({
    required this.make,
    required this.model,
    required this.color,
    required this.licensePlate,
    required this.year,
  });

  factory CarModel.fromMap(Map<String, dynamic> map) {
    return CarModel(
      make: map['make'] ?? '',
      model: map['model'] ?? '',
      color: map['color'] ?? '',
      licensePlate: map['licensePlate'] ?? '',
      year: map['year'] ?? 2020,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'make': make,
      'model': model,
      'color': color,
      'licensePlate': licensePlate,
      'year': year,
    };
  }

  String get displayName => '$make $model ($year)';
}

class DriverModel {
  final String id;
  final String name;
  final String phone;
  final String? photoUrl;
  final double rating;
  final int ratingCount;
  final int totalRides;
  final CarModel car;
  final bool isOnline;
  final double? currentLat;
  final double? currentLon;
  final String? currentRideId;
  final DateTime createdAt;

  const DriverModel({
    required this.id,
    required this.name,
    required this.phone,
    this.photoUrl,
    this.rating = 5.0,
    this.ratingCount = 0,
    this.totalRides = 0,
    required this.car,
    this.isOnline = false,
    this.currentLat,
    this.currentLon,
    this.currentRideId,
    required this.createdAt,
  });

  factory DriverModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DriverModel(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      photoUrl: data['photoUrl'],
      rating: (data['rating'] ?? 5.0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      totalRides: data['totalRides'] ?? 0,
      car: CarModel.fromMap(
        data['car'] as Map<String, dynamic>? ?? {},
      ),
      isOnline: data['isOnline'] ?? false,
      currentLat: (data['currentLat'] as num?)?.toDouble(),
      currentLon: (data['currentLon'] as num?)?.toDouble(),
      currentRideId: data['currentRideId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'rating': rating,
      'ratingCount': ratingCount,
      'totalRides': totalRides,
      'car': car.toMap(),
      'isOnline': isOnline,
      'currentLat': currentLat,
      'currentLon': currentLon,
      'currentRideId': currentRideId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  DriverModel copyWith({
    String? name,
    String? phone,
    String? photoUrl,
    double? rating,
    int? ratingCount,
    int? totalRides,
    CarModel? car,
    bool? isOnline,
    double? currentLat,
    double? currentLon,
    String? currentRideId,
  }) {
    return DriverModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      totalRides: totalRides ?? this.totalRides,
      car: car ?? this.car,
      isOnline: isOnline ?? this.isOnline,
      currentLat: currentLat ?? this.currentLat,
      currentLon: currentLon ?? this.currentLon,
      currentRideId: currentRideId ?? this.currentRideId,
      createdAt: createdAt,
    );
  }
}
