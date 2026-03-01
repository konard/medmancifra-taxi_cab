import 'package:cloud_firestore/cloud_firestore.dart';
import 'address_model.dart';

enum QuickAddressCategory { home, work, favorite }

class QuickAddressModel {
  final String id;
  final String userId;
  final String label;
  final QuickAddressCategory category;
  final AddressModel address;
  final DateTime createdAt;

  const QuickAddressModel({
    required this.id,
    required this.userId,
    required this.label,
    required this.category,
    required this.address,
    required this.createdAt,
  });

  factory QuickAddressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuickAddressModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      label: data['label'] ?? '',
      category: QuickAddressCategory.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => QuickAddressCategory.favorite,
      ),
      address: AddressModel.fromMap(
        data['address'] as Map<String, dynamic>? ?? {},
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'label': label,
      'category': category.name,
      'address': address.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
