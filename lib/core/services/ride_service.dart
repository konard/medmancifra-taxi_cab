import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/address_model.dart';
import '../models/quick_address_model.dart';
import '../models/ride_model.dart';

class RideService {
  final FirebaseFirestore _firestore;
  final List<AddressModel> _searchHistory = [];

  static const _historyKey = 'address_search_history';
  static const _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';
  static const _osrmBaseUrl = 'https://router.project-osrm.org';

  RideService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ─── Address Search ───────────────────────────────────────────────────────

  /// Search addresses using Nominatim (OSM) with autocomplete support.
  Future<List<AddressModel>> searchAddress(String query, {String? countryCode}) async {
    if (query.trim().length < 3) return [];

    try {
      final params = {
        'q': query,
        'format': 'json',
        'addressdetails': '1',
        'limit': '8',
        'accept-language': 'ru,en',
        if (countryCode != null) 'countrycodes': countryCode,
      };

      final uri = Uri.parse('$_nominatimBaseUrl/search').replace(
        queryParameters: params,
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'TaxiCabApp/1.0',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((item) => AddressModel.fromNominatim(item as Map<String, dynamic>))
            .toList();
      }
    } catch (_) {
      // Network error or timeout – return empty list so UI can show cached suggestions
    }
    return [];
  }

  /// Reverse geocode a coordinate to an address.
  Future<AddressModel?> reverseGeocode(double lat, double lon) async {
    try {
      final uri = Uri.parse('$_nominatimBaseUrl/reverse').replace(
        queryParameters: {
          'lat': lat.toString(),
          'lon': lon.toString(),
          'format': 'json',
          'addressdetails': '1',
          'accept-language': 'ru,en',
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'TaxiCabApp/1.0',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data.containsKey('display_name')) {
          return AddressModel.fromNominatim(data);
        }
      }
    } catch (_) {}
    return null;
  }

  // ─── Routing ──────────────────────────────────────────────────────────────

  Future<RouteInfo?> fetchRoute(AddressModel from, AddressModel to) async {
    try {
      final url =
          '$_osrmBaseUrl/route/v1/driving/${from.lon},${from.lat};${to.lon},${to.lat}'
          '?overview=full&geometries=geojson&annotations=false';

      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        if (data['code'] == 'Ok') {
          final routes = data['routes'] as List<dynamic>;
          if (routes.isNotEmpty) {
            final route = routes[0] as Map<String, dynamic>;
            final distanceM = (route['distance'] as num).toDouble();
            final durationS = (route['duration'] as num).toDouble();

            final geometry = route['geometry'] as Map<String, dynamic>;
            final coords = geometry['coordinates'] as List<dynamic>;

            final points = coords
                .map((c) => [
                      (c as List<dynamic>)[1].toDouble(),
                      c[0].toDouble(),
                    ])
                .toList();

            return RouteInfo(
              distanceKm: distanceM / 1000,
              durationMinutes: (durationS / 60).round(),
              polylinePoints: points.cast<List<double>>(),
            );
          }
        }
      }
    } catch (_) {}
    return null;
  }

  // ─── Geolocation ──────────────────────────────────────────────────────────

  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
  }

  Stream<Position> watchLocation() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );
  }

  // ─── Search History ───────────────────────────────────────────────────────

  List<AddressModel> get history => List.unmodifiable(_searchHistory);

  Future<void> loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getStringList(_historyKey) ?? [];
      _searchHistory.clear();
      for (final item in data) {
        try {
          _searchHistory.add(
            AddressModel.fromMap(json.decode(item) as Map<String, dynamic>),
          );
        } catch (_) {}
      }
    } catch (_) {}
  }

  Future<void> addToHistory(AddressModel address) async {
    _searchHistory.removeWhere((a) => a == address);
    _searchHistory.insert(0, address);
    if (_searchHistory.length > 10) {
      _searchHistory.removeRange(10, _searchHistory.length);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _historyKey,
        _searchHistory.map((a) => json.encode(a.toMap())).toList(),
      );
    } catch (_) {}
  }

  // ─── Quick Addresses (Firebase) ───────────────────────────────────────────

  Stream<List<QuickAddressModel>> watchQuickAddresses(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('quickAddresses')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((doc) => QuickAddressModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> addQuickAddress({
    required String userId,
    required String label,
    required QuickAddressCategory category,
    required AddressModel address,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('quickAddresses')
        .add(
          QuickAddressModel(
            id: '',
            userId: userId,
            label: label,
            category: category,
            address: address,
            createdAt: DateTime.now(),
          ).toFirestore(),
        );
  }

  Future<void> deleteQuickAddress(String userId, String addressId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('quickAddresses')
        .doc(addressId)
        .delete();
  }

  // ─── Fare Calculation ─────────────────────────────────────────────────────

  double calculateFare(RouteInfo route, RideTariff tariff) {
    const baseRates = {
      RideTariff.economy: 50.0,
      RideTariff.comfort: 80.0,
      RideTariff.business: 120.0,
    };
    const perKmRates = {
      RideTariff.economy: 25.0,
      RideTariff.comfort: 40.0,
      RideTariff.business: 60.0,
    };
    const perMinRates = {
      RideTariff.economy: 3.0,
      RideTariff.comfort: 5.0,
      RideTariff.business: 8.0,
    };

    final base = baseRates[tariff] ?? 50;
    final perKm = perKmRates[tariff] ?? 25;
    final perMin = perMinRates[tariff] ?? 3;

    return base +
        (route.distanceKm * perKm) +
        (route.durationMinutes * perMin);
  }

  // ─── Rides Collection ─────────────────────────────────────────────────────

  Future<RideModel> createRide({
    required String passengerId,
    required AddressModel pickup,
    required AddressModel destination,
    required RideTariff tariff,
    required double price,
  }) async {
    final doc = await _firestore.collection('rides').add({
      'passengerId': passengerId,
      'driverId': null,
      'pickupAddress': pickup.toMap(),
      'destinationAddress': destination.toMap(),
      'status': RideStatus.searching.name,
      'tariff': tariff.name,
      'price': price,
      'createdAt': FieldValue.serverTimestamp(),
      'completedAt': null,
    });

    await addToHistory(pickup);
    await addToHistory(destination);

    return RideModel(
      id: doc.id,
      passengerId: passengerId,
      pickupAddress: pickup,
      destinationAddress: destination,
      status: RideStatus.searching,
      tariff: tariff,
      price: price,
      createdAt: DateTime.now(),
    );
  }

  Stream<RideModel?> watchRide(String rideId) {
    return _firestore
        .collection('rides')
        .doc(rideId)
        .snapshots()
        .map((snap) => snap.exists ? RideModel.fromFirestore(snap) : null);
  }

  Future<void> updateRideStatus(String rideId, RideStatus status) async {
    final Map<String, dynamic> update = {'status': status.name};
    if (status == RideStatus.completed) {
      update['completedAt'] = FieldValue.serverTimestamp();
    }
    await _firestore.collection('rides').doc(rideId).update(update);
  }

  Future<void> cancelRide(String rideId, String reason) async {
    await _firestore.collection('rides').doc(rideId).update({
      'status': RideStatus.cancelled.name,
      'cancelReason': reason,
    });
  }

  Stream<List<RideModel>> watchAvailableRides() {
    return _firestore
        .collection('rides')
        .where('status', isEqualTo: RideStatus.searching.name)
        .orderBy('price', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => RideModel.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<RideModel>> watchPassengerHistory(String passengerId) {
    return _firestore
        .collection('rides')
        .where('passengerId', isEqualTo: passengerId)
        .where('status', whereIn: [
          RideStatus.completed.name,
          RideStatus.cancelled.name,
        ])
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => RideModel.fromFirestore(doc)).toList(),
        );
  }

  Stream<List<RideModel>> watchDriverHistory(String driverId) {
    return _firestore
        .collection('rides')
        .where('driverId', isEqualTo: driverId)
        .where('status', whereIn: [
          RideStatus.completed.name,
          RideStatus.cancelled.name,
        ])
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => RideModel.fromFirestore(doc)).toList(),
        );
  }

  Future<void> acceptRide(String rideId, String driverId) async {
    await _firestore.collection('rides').doc(rideId).update({
      'driverId': driverId,
      'status': RideStatus.driverAssigned.name,
    });
  }

  Future<void> rateRide({
    required String rideId,
    required bool isPassenger,
    required double rating,
  }) async {
    await _firestore.collection('rides').doc(rideId).update({
      isPassenger ? 'passengerRating' : 'driverRating': rating,
    });
  }
}
