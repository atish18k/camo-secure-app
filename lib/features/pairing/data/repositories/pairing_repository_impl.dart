// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../../domain/entities/pairing_entity.dart';
import '../../domain/repositories/pairing_repository.dart';
import '../datasources/pairing_remote_datasource.dart';
import '../models/pairing_model.dart';

// ---------------------------------------------------------------------------
// Class
// ---------------------------------------------------------------------------

class PairingRepositoryImpl implements PairingRepository {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const PairingRepositoryImpl({
    required this.remoteDataSource,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final PairingRemoteDataSource remoteDataSource;

  // ---------------------------------------------------------------------------
  // Create Pair Request
  // ---------------------------------------------------------------------------

  @override
  Future<void> createPairRequest(PairingEntity pairing) {
    return remoteDataSource.savePairing(
      PairingModel.fromEntity(pairing),
    );
  }

  // ---------------------------------------------------------------------------
  // Get Pairing
  // ---------------------------------------------------------------------------

  @override
  Future<PairingEntity?> getPairingById(String pairingId) {
    return remoteDataSource.getPairing(pairingId);
  }

  // ---------------------------------------------------------------------------
  // Accept Pair Request
  // ---------------------------------------------------------------------------

  @override
  Future<void> acceptPairRequest(String pairingId) {
    return remoteDataSource.updatePairingStatus(
      pairingId,
      PairingStatus.accepted,
    );
  }

  // ---------------------------------------------------------------------------
  // Reject Pair Request
  // ---------------------------------------------------------------------------

  @override
  Future<void> rejectPairRequest(String pairingId) {
    return remoteDataSource.updatePairingStatus(
      pairingId,
      PairingStatus.rejected,
    );
  }

  // ---------------------------------------------------------------------------
  // Delete Pairing
  // ---------------------------------------------------------------------------

  @override
  Future<void> deletePairing(String pairingId) {
    return remoteDataSource.deletePairing(pairingId);
  }
}