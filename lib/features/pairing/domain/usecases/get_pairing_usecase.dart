import '../entities/pairing_entity.dart';
import '../repositories/pairing_repository.dart';

class GetPairingUseCase {
  final PairingRepository _repository;

  const GetPairingUseCase(this._repository);

  Future<PairingEntity?> call(String id) {
    return _repository.getPairing(id);
  }
}