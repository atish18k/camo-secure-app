import '../entities/pairing_entity.dart';

abstract interface class PairingRepository {
  Future<void> savePairing(PairingEntity pairing);

  Future<PairingEntity?> getPairing(String id);
}