// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../entities/pairing_entity.dart';

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

abstract interface class PairingRepository {
  // ---------------------------------------------------------------------------
  // Create
  // ---------------------------------------------------------------------------

  Future<void> createPairRequest(
    PairingEntity pairing,
  );

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  Future<PairingEntity?> getPairingById(
    String pairingId,
  );

  Future<PairingEntity?> getPairingBetweenUsers({
    required String requesterUid,
    required String receiverUid,
  });

  Stream<List<PairingEntity>> watchPendingRequests(
    String receiverUid,
  );

  Stream<List<PairingEntity>> watchSentRequests(
    String requesterUid,
  );

  Stream<List<PairingEntity>> watchAcceptedPairings(
    String userUid,
  );

  // ---------------------------------------------------------------------------
  // Update
  // ---------------------------------------------------------------------------

  Future<void> acceptPairRequest(
    String pairingId,
  );

  Future<void> rejectPairRequest(
    String pairingId,
  );

  Future<void> cancelPairRequest(
    String pairingId,
  );

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  Future<void> deletePairing(
    String pairingId,
  );
}