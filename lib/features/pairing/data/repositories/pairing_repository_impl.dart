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
  Future<void> createPairRequest(
    PairingEntity pairing,
  ) {
    return remoteDataSource.savePairing(
      PairingModel.fromEntity(pairing),
    );
  }

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  @override
  Future<PairingEntity?> getPairingById(
    String pairingId,
  ) {
    return remoteDataSource.getPairing(pairingId);
  }

  @override
  Future<PairingEntity?> getPairingBetweenUsers({
    required String requesterUid,
    required String receiverUid,
  }) async {
    final PairingEntity? forwardPairing =
        await remoteDataSource.getPairingBetweenUsers(
      requesterUid: requesterUid,
      receiverUid: receiverUid,
    );

    if (forwardPairing != null) {
      return forwardPairing;
    }

    return remoteDataSource.getPairingBetweenUsers(
      requesterUid: receiverUid,
      receiverUid: requesterUid,
    );
  }

  @override
  Stream<List<PairingEntity>> watchPendingRequests(
    String receiverUid,
  ) {
    return remoteDataSource.watchPendingRequests(receiverUid);
  }

  @override
  Stream<List<PairingEntity>> watchSentRequests(
    String requesterUid,
  ) {
    return remoteDataSource.watchSentRequests(requesterUid);
  }

  @override
  Stream<List<PairingEntity>> watchAcceptedPairings(
    String userUid,
  ) {
    return remoteDataSource.watchAcceptedPairings(userUid);
  }

  // ---------------------------------------------------------------------------
  // Update
  // ---------------------------------------------------------------------------

  @override
  Future<void> acceptPairRequest(
    String pairingId,
  ) {
    return remoteDataSource.updatePairingStatus(
      pairingId,
      PairingStatus.accepted,
    );
  }

  @override
  Future<void> rejectPairRequest(
    String pairingId,
  ) {
    return remoteDataSource.updatePairingStatus(
      pairingId,
      PairingStatus.rejected,
    );
  }

  @override
  Future<void> cancelPairRequest(
    String pairingId,
  ) {
    return remoteDataSource.updatePairingStatus(
      pairingId,
      PairingStatus.cancelled,
    );
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  @override
  Future<void> deletePairing(
    String pairingId,
  ) {
    return remoteDataSource.deletePairing(pairingId);
  }
}