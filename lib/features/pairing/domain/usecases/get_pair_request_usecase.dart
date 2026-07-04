import '../entities/pair_request_entity.dart';
import '../repositories/pair_request_repository.dart';

class GetPairRequestUseCase {
  final PairRequestRepository _repository;

  const GetPairRequestUseCase(this._repository);

  Future<PairRequestEntity?> call(String id) {
    return _repository.getRequest(id);
  }
}