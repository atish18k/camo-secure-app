// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../entities/pairing_entity.dart';
import '../repositories/pairing_repository.dart';

// ---------------------------------------------------------------------------
// Watch Accepted Pairings Use Case
// ---------------------------------------------------------------------------

class WatchAcceptedPairingsUseCase {
  const WatchAcceptedPairingsUseCase(this._repository);

  final PairingRepository _repository;

  Stream<List<PairingEntity>> call(String userUid) {
    return _repository.watchAcceptedPairings(userUid);
  }
}