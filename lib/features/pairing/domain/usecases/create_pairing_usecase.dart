import '../entities/pairing_entity.dart';
import '../repositories/pairing_repository.dart';

class CreatePairingUseCase {
  final PairingRepository _repository;

  const CreatePairingUseCase(this._repository);

  Future<void> call(PairingEntity pairing) {
    return _repository.savePairing(pairing);
  }
}