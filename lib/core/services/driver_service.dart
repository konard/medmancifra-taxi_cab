import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/driver_model.dart';

class DriverService {
  final FirebaseFirestore _firestore;

  DriverService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<DriverModel?> getDriver(String driverId) async {
    try {
      final doc = await _firestore.collection('drivers').doc(driverId).get();
      if (doc.exists) return DriverModel.fromFirestore(doc);
      return null;
    } catch (_) {
      return null;
    }
  }

  Stream<DriverModel?> watchDriver(String driverId) {
    return _firestore
        .collection('drivers')
        .doc(driverId)
        .snapshots()
        .map((doc) => doc.exists ? DriverModel.fromFirestore(doc) : null);
  }

  Future<void> createOrUpdateDriver(DriverModel driver) async {
    await _firestore
        .collection('drivers')
        .doc(driver.id)
        .set(driver.toFirestore(), SetOptions(merge: true));
  }

  Future<void> setOnlineStatus(String driverId, bool isOnline) async {
    await _firestore.collection('drivers').doc(driverId).update({
      'isOnline': isOnline,
    });
  }

  Future<void> updateLocation(
    String driverId,
    double lat,
    double lon,
  ) async {
    await _firestore.collection('drivers').doc(driverId).update({
      'currentLat': lat,
      'currentLon': lon,
    });
  }

  Future<void> setCurrentRide(String driverId, String? rideId) async {
    await _firestore.collection('drivers').doc(driverId).update({
      'currentRideId': rideId,
    });
  }

  Stream<int> watchNewOrdersCount(String driverId) {
    // Watch rides that are in searching status (not yet assigned)
    return _firestore
        .collection('rides')
        .where('status', isEqualTo: 'searching')
        .snapshots()
        .map((snap) => snap.docs.length);
  }
}
