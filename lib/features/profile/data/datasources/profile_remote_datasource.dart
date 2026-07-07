// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../models/user_profile_model.dart';

// ---------------------------------------------------------------------------
// Interface
// ---------------------------------------------------------------------------

abstract class ProfileRemoteDataSource {
  // ---------------------------------------------------------------------------
  // User Profile
  // ---------------------------------------------------------------------------

  Future<void> saveUser(UserProfileModel user);

  Future<UserProfileModel?> getUser(String uid);

  Future<UserProfileModel?> getUserByCamoId(String camoId);
}

// ---------------------------------------------------------------------------
// Class
// ---------------------------------------------------------------------------

class FirebaseProfileRemoteDataSource implements ProfileRemoteDataSource {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const FirebaseProfileRemoteDataSource(this._firestore);

  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  final FirebaseFirestore _firestore;

  // ---------------------------------------------------------------------------
  // User Profile
  // ---------------------------------------------------------------------------

  @override
  Future<void> saveUser(UserProfileModel user) async {
    await _firestore.collection(FirestorePaths.users).doc(user.uid).set(
          user.toMap(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<UserProfileModel?> getUser(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection(FirestorePaths.users).doc(uid).get();

    if (!snapshot.exists) {
      return null;
    }

    final Map<String, dynamic>? data = snapshot.data();

    if (data == null) {
      return null;
    }

    return UserProfileModel.fromMap(data);
  }

  @override
  Future<UserProfileModel?> getUserByCamoId(
    String camoId,
  ) async {
    final QuerySnapshot<Map<String, dynamic>> query = await _firestore
        .collection(FirestorePaths.users)
        .where(
          'camoId',
          isEqualTo: camoId,
        )
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return null;
    }

    return UserProfileModel.fromMap(
      query.docs.first.data(),
    );
  }
}