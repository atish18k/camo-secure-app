import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../models/pairing_model.dart';

abstract class PairingRemoteDataSource {
  // ---------------------------------------------------------------------------
  // Pairing
  // ---------------------------------------------------------------------------

  Future<void> savePairing(PairingModel pairing);

  Future<PairingModel?> getPairing(String id);
}

class FirebasePairingRemoteDataSource
    implements PairingRemoteDataSource {
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
    await _firestore
        .collection(FirestorePaths.pairings)
        .doc(pairing.id)
        .set(
          pairing.toMap(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<PairingModel?> getPairing(String id) async {
    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore
            .collection(FirestorePaths.pairings)
            .doc(id)
            .get();

    if (!snapshot.exists) {
      return null;
    }

    final Map<String, dynamic>? data = snapshot.data();

    if (data == null) {
      return null;
    }

    return PairingModel.fromMap(data);
  }
}