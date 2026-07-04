import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<void> saveUser(UserProfileModel user);

  Future<UserProfileModel?> getUser(String uid);

  Future<UserProfileModel?> getUserByCamoId(String camoId);
}

class FirebaseProfileRemoteDataSource
    implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore;

  const FirebaseProfileRemoteDataSource(this._firestore);

  @override
  Future<void> saveUser(UserProfileModel user) async {
    await _firestore
        .collection(FirestorePaths.users)
        .doc(user.uid)
        .set(
          user.toMap(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<UserProfileModel?> getUser(String uid) async {
    final snapshot = await _firestore
        .collection(FirestorePaths.users)
        .doc(uid)
        .get();

    if (!snapshot.exists) {
      return null;
    }

    return UserProfileModel.fromMap(snapshot.data()!);
  }

  @override
  Future<UserProfileModel?> getUserByCamoId(String camoId) async {
    final query = await _firestore
        .collection(FirestorePaths.users)
        .where('camoId', isEqualTo: camoId)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      return null;
    }

    return UserProfileModel.fromMap(query.docs.first.data());
  }
}