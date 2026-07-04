import '../entities/pair_request_entity.dart';
import '../repositories/pair_request_repository.dart';

class WatchIncomingPairRequestsUseCase {
  final PairRequestRepository _repository;

  const WatchIncomingPairRequestsUseCase(
    this._repository,
  );

  Stream<List<PairRequestEntity>> call(
    String receiverUid,
  ) {
    return _repository.watchIncomingRequests(
      receiverUid,
    );
  }
}