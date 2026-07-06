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
  // Pairing
  // ---------------------------------------------------------------------------

  Future<void> savePairing(PairingModel pairing);

  Future<PairingModel?> getPairing(String id);

  Future<void> updatePairingStatus(
    String id,
    PairingStatus status,
  );

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
  // Pairing
  // ---------------------------------------------------------------------------

  @override
  Future<void> savePairing(PairingModel pairing) async {
    await _firestore.collection(FirestorePaths.pairings).doc(pairing.id).set(
          pairing.toMap(),
          SetOptions(merge: true),
        );
  }

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

  @override
  Future<void> updatePairingStatus(
    String id,
    PairingStatus status,
  ) async {
    await _firestore.collection(FirestorePaths.pairings).doc(id).update({
      'status': status.name,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
      'acceptedAt':
          status == PairingStatus.accepted ? Timestamp.fromDate(DateTime.now()) : null,
    });
  }

  @override
  Future<void> deletePairing(String id) async {
    await _firestore.collection(FirestorePaths.pairings).doc(id).delete();
  }
}