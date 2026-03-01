import 'package:cloud_firestore/cloud_firestore.dart';

enum UserRole { passenger, driver }

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? photoUrl;
  final UserRole role;
  final double rating;
  final int ratingCount;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.photoUrl,
    required this.role,
    this.rating = 5.0,
    this.ratingCount = 0,
    required this.createdAt,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      photoUrl: data['photoUrl'],
      role: data['role'] == 'driver' ? UserRole.driver : UserRole.passenger,
      rating: (data['rating'] ?? 5.0).toDouble(),
      ratingCount: data['ratingCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'phone': phone,
      'photoUrl': photoUrl,
      'role': role == UserRole.driver ? 'driver' : 'passenger',
      'rating': rating,
      'ratingCount': ratingCount,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? photoUrl,
    UserRole? role,
    double? rating,
    int? ratingCount,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      rating: rating ?? this.rating,
      ratingCount: ratingCount ?? this.ratingCount,
      createdAt: createdAt,
    );
  }
}
