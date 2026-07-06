// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../entities/pairing_entity.dart';
import '../repositories/pairing_repository.dart';

// ---------------------------------------------------------------------------
// Get Pairing Between Users Use Case
// ---------------------------------------------------------------------------

class GetPairingBetweenUsersUseCase {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const GetPairingBetweenUsersUseCase(this._repository);

  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  final PairingRepository _repository;

  // ---------------------------------------------------------------------------
  // Call
  // ---------------------------------------------------------------------------

  Future<PairingEntity?> call({
    required String requesterUid,
    required String receiverUid,
  }) {
    return _repository.getPairingBetweenUsers(
      requesterUid: requesterUid,
      receiverUid: receiverUid,
    );
  }
}