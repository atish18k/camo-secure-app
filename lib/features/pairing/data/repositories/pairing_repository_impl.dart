// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../../domain/entities/pairing_entity.dart';
import '../../domain/repositories/pairing_repository.dart';
import '../datasources/pairing_remote_datasource.dart';
import '../models/pairing_model.dart';

// ---------------------------------------------------------------------------
// Repository Implementation
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
  // Create
  // ---------------------------------------------------------------------------

  @override
  Future<void> createPairRequest(PairingEntity pairing) {
    return remoteDataSource.savePairing(
      PairingModel.fromEntity(pairing),
    );
  }

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  @override
  Future<PairingEntity?> getPairingById(String pairingId) {
    return remoteDataSource.getPairing(pairingId);
  }

  // ---------------------------------------------------------------------------
  // Update
  // ---------------------------------------------------------------------------

  @override
  Future<void> acceptPairRequest(String pairingId) {
    return remoteDataSource.updatePairingStatus(
      pairingId,
      PairingStatus.accepted,
    );
  }

  @override
  Future<void> rejectPairRequest(String pairingId) {
    return remoteDataSource.updatePairingStatus(
      pairingId,
      PairingStatus.rejected,
    );
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  @override
  Future<void> deletePairing(String pairingId) {
    return remoteDataSource.deletePairing(pairingId);
  }
}