import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/entities/camo_device_support_acceptance.dart';
import '../../domain/repositories/camo_device_support_acceptance_repository.dart';

final class FirestoreCamoDeviceSupportAcceptanceRepository
    implements CamoDeviceSupportAcceptanceRepository {
  const FirestoreCamoDeviceSupportAcceptanceRepository(
    this._firestore,
    this._auth,
  );
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  @override
  Future<void> saveCurrentUserAcceptance(
    CamoDeviceSupportAcceptance acceptance,
  ) async {
    acceptance.validate();
    final User? user = _auth.currentUser;
    if (user == null || user.uid.trim().isEmpty) {
      throw StateError(
        'Authenticated user is required for device support acceptance.',
      );
    }
    final DocumentReference<Map<String, dynamic>> reference = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('security')
        .doc('deviceSupportAcceptance');
    final DocumentSnapshot<Map<String, dynamic>> existing = await reference
        .get();
    if (existing.exists) {
      final Map<String, dynamic>? data = existing.data();
      if (data?['policyVersion'] == acceptance.policyVersion &&
          data?['supportLevel'] == acceptance.supportLevel.name) {
        return;
      }
      throw StateError(
        'Existing device support acceptance cannot be replaced.',
      );
    }
    await reference.set(<String, dynamic>{
      'schemaVersion': 1,
      'policyVersion': acceptance.policyVersion,
      'supportLevel': acceptance.supportLevel.name,
      'platform': acceptance.platformLabel.trim(),
      'hardwareBackingConfirmed': acceptance.hardwareBackingConfirmed,
      'limitedRiskAccepted': acceptance.limitedRiskAccepted,
      'acceptedAt': FieldValue.serverTimestamp(),
    });
  }
}
