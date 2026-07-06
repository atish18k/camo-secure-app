// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../../domain/entities/pairing_entity.dart';
import '../models/pairing_model.dart';

// ---------------------------------------------------------------------------
// Remote Data Source
// ---------------------------------------------------------------------------

abstract class PairingRemoteDataSource {
  // ---------------------------------------------------------------------------
  // Create
  // ---------------------------------------------------------------------------

  Future<void> savePairing(PairingModel pairing);

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  Future<PairingModel?> getPairing(String id);

  // ---------------------------------------------------------------------------
  // Update
  // ---------------------------------------------------------------------------

  Future<void> updatePairingStatus(
    String id,
    PairingStatus status,
  );

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  Future<void> deletePairing(String id);
}

// ---------------------------------------------------------------------------
// Firebase Remote Data Source
// ---------------------------------------------------------------------------

class FirebasePairingRemoteDataSource implements PairingRemoteDataSource {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const FirebasePairingRemoteDataSource(this._firestore);

  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  final FirebaseFirestore _firestore;

  // ---------------------------------------------------------------------------
  // Create
  // ---------------------------------------------------------------------------

  @override
  Future<void> savePairing(PairingModel pairing) async {
    await _firestore.collection(FirestorePaths.pairings).doc(pairing.id).set(
          pairing.toMap(),
          SetOptions(merge: true),
        );
  }

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  @override
  Future<PairingModel?> getPairing(String id) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore.collection(FirestorePaths.pairings).doc(id).get();

    if (!snapshot.exists) {
      return null;
    }

    final Map<String, dynamic>? data = snapshot.data();

    if (data == null) {
      return null;
    }

    return PairingModel.fromMap(
      data,
      id: snapshot.id,
    );
  }

  // ---------------------------------------------------------------------------
  // Update
  // ---------------------------------------------------------------------------

  @override
  Future<void> updatePairingStatus(
    String id,
    PairingStatus status,
  ) async {
    final DateTime now = DateTime.now();

    await _firestore.collection(FirestorePaths.pairings).doc(id).update({
      'status': status.name,
      'updatedAt': Timestamp.fromDate(now),
      if (status == PairingStatus.accepted)
        'acceptedAt': Timestamp.fromDate(now),
    });
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  @override
  Future<void> deletePairing(String id) async {
    await _firestore.collection(FirestorePaths.pairings).doc(id).delete();
  }
}