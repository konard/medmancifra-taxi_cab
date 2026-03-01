import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) return UserModel.fromFirestore(doc);
      return null;
    } catch (_) {
      return null;
    }
  }

  Stream<UserModel?> watchUserProfile(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  Future<UserModel> signInAnonymouslyWithRole(UserRole role, String name) async {
    final cred = await _auth.signInAnonymously();
    final uid = cred.user!.uid;

    final user = UserModel(
      id: uid,
      name: name,
      phone: '',
      role: role,
      createdAt: DateTime.now(),
    );

    await _firestore.collection('users').doc(uid).set(user.toFirestore());
    return user;
  }

  Future<void> updateProfile(String uid, {String? name, String? photoUrl}) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    if (updates.isNotEmpty) {
      await _firestore.collection('users').doc(uid).update(updates);
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
