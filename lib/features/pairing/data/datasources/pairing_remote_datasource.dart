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

  Future<PairingModel?> getPairingBetweenUsers({
    required String requesterUid,
    required String receiverUid,
  });

  Stream<List<PairingModel>> watchPendingRequests(String receiverUid);

  Stream<List<PairingModel>> watchReceivedRequests(String receiverUid);

  Stream<List<PairingModel>> watchSentRequests(String requesterUid);

  Stream<List<PairingModel>> watchAcceptedPairings(String userUid);

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
  const FirebasePairingRemoteDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  // ---------------------------------------------------------------------------
  // Create
  // ---------------------------------------------------------------------------

  @override
  Future<void> savePairing(PairingModel pairing) async {
    final DocumentReference<Map<String, dynamic>> pairingRef =
        _firestore.collection(FirestorePaths.pairings).doc(pairing.id);

    await _firestore.runTransaction<void>((transaction) async {
      final DocumentSnapshot<Map<String, dynamic>> snapshot =
          await transaction.get(pairingRef);

      if (snapshot.exists) {
        throw const FormatException('Pairing request already exists.');
      }

      transaction.set(pairingRef, pairing.toMap());
    });
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

  @override
  Future<PairingModel?> getPairingBetweenUsers({
    required String requesterUid,
    required String receiverUid,
  }) async {
    final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
        .collection(FirestorePaths.pairings)
        .where(
          'requesterUid',
          isEqualTo: requesterUid,
        )
        .where(
          'receiverUid',
          isEqualTo: receiverUid,
        )
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    final QueryDocumentSnapshot<Map<String, dynamic>> document =
        snapshot.docs.first;

    return PairingModel.fromMap(
      document.data(),
      id: document.id,
    );
  }

  @override
  Stream<List<PairingModel>> watchPendingRequests(String receiverUid) {
    return _firestore
        .collection(FirestorePaths.pairings)
        .where(
          'receiverUid',
          isEqualTo: receiverUid,
        )
        .where(
          'status',
          isEqualTo: PairingStatus.pending.name,
        )
        .snapshots()
        .map(_mapSnapshotToPairings);
  }

  @override
  Stream<List<PairingModel>> watchReceivedRequests(String receiverUid) {
    return _firestore
        .collection(FirestorePaths.pairings)
        .where(
          'receiverUid',
          isEqualTo: receiverUid,
        )
        .where(
          'status',
          isEqualTo: PairingStatus.pending.name,
        )
        .snapshots()
        .map(_mapSnapshotToPairings);
  }

  @override
  Stream<List<PairingModel>> watchSentRequests(String requesterUid) {
    return _firestore
        .collection(FirestorePaths.pairings)
        .where(
          'requesterUid',
          isEqualTo: requesterUid,
        )
        .snapshots()
        .map(_mapSnapshotToPairings);
  }

  @override
  Stream<List<PairingModel>> watchAcceptedPairings(String userUid) {
    return _firestore
        .collection(FirestorePaths.pairings)
        .where(
          'status',
          isEqualTo: PairingStatus.accepted.name,
        )
        .where(
          Filter.or(
            Filter(
              'requesterUid',
              isEqualTo: userUid,
            ),
            Filter(
              'receiverUid',
              isEqualTo: userUid,
            ),
          ),
        )
        .snapshots()
        .map(_mapSnapshotToPairings);
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

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  List<PairingModel> _mapSnapshotToPairings(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) {
    return snapshot.docs
        .map(
          (QueryDocumentSnapshot<Map<String, dynamic>> document) {
            return PairingModel.fromMap(
              document.data(),
              id: document.id,
            );
          },
        )
        .toList();
  }
}