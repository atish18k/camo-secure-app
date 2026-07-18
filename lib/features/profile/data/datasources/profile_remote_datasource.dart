import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../models/user_profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<void> saveUser(UserProfileModel user);
  Future<UserProfileModel?> getUser(String uid);
  Future<UserProfileModel?> getUserByCamoId(String camoId);
}

class FirebaseProfileRemoteDataSource implements ProfileRemoteDataSource {
  const FirebaseProfileRemoteDataSource(this._firestore);
  final FirebaseFirestore _firestore;

  @override
  Future<void> saveUser(UserProfileModel user) async {
    user.validate();
    await _firestore
        .collection(FirestorePaths.users)
        .doc(user.uid.trim())
        .set(user.toMap(), SetOptions(merge: true));
  }

  @override
  Future<UserProfileModel?> getUser(String uid) async {
    final requestedUid = _requiredIdentity('uid', uid);
    final snapshot = await _firestore
        .collection(FirestorePaths.users)
        .doc(requestedUid)
        .get();
    if (!snapshot.exists) return null;
    final data = snapshot.data();
    if (data == null) {
      throw const FormatException('Existing profile has no data.');
    }
    final model = UserProfileModel.fromMap(data);
    if (model.uid != requestedUid) {
      throw const FormatException('Profile UID does not match its document.');
    }
    return model;
  }

  @override
  Future<UserProfileModel?> getUserByCamoId(String camoId) async {
    final requestedCamoId = _requiredIdentity('CAMO ID', camoId);
    final query = await _firestore
        .collection(FirestorePaths.users)
        .where('camoId', isEqualTo: requestedCamoId)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    final model = UserProfileModel.fromMap(query.docs.first.data());
    if (model.camoId != requestedCamoId) {
      throw const FormatException('Profile CAMO ID does not match the query.');
    }
    return model;
  }

  static String _requiredIdentity(String label, String value) {
    final normalized = value.trim();
    if (normalized.isEmpty) {
      throw FormatException('Missing profile $label.');
    }
    return normalized;
  }
}
