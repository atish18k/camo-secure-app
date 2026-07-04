import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/pairing_model.dart';

abstract class PairingRemoteDataSource {
  Future<void> savePairing(PairingModel pairing);

  Future<PairingModel?> getPairing(String id);
}

class FirebasePairingRemoteDataSource
    implements PairingRemoteDataSource {
  final FirebaseFirestore _firestore;

  const FirebasePairingRemoteDataSource(this._firestore);

  @override
  Future<void> savePairing(PairingModel pairing) async {
    await _firestore
        .collection('pairings')
        .doc(pairing.id)
        .set(
          pairing.toMap(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<PairingModel?> getPairing(String id) async {
    final snapshot = await _firestore
        .collection('pairings')
        .doc(id)
        .get();

    if (!snapshot.exists) {
      return null;
    }

    return PairingModel.fromMap(snapshot.data()!);
  }
}