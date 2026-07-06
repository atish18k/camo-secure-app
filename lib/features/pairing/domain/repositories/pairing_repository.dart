// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../entities/pairing_entity.dart';

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

abstract interface class PairingRepository {
  Future<void> createPairRequest(PairingEntity pairing);

  Future<PairingEntity?> getPairingById(String pairingId);

  Future<void> acceptPairRequest(String pairingId);

  Future<void> rejectPairRequest(String pairingId);

  Future<void> deletePairing(String pairingId);
}