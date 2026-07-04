import '../entities/pair_request_entity.dart';
import '../repositories/pair_request_repository.dart';

class SendPairRequestUseCase {
  final PairRequestRepository _repository;

  const SendPairRequestUseCase(this._repository);

  Future<void> call(PairRequestEntity request) {
    return _repository.sendRequest(request);
  }
}