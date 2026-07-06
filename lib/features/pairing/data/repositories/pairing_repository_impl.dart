import '../../domain/entities/pairing_entity.dart';
import '../../domain/repositories/pairing_repository.dart';
import '../datasources/pairing_remote_datasource.dart';
import '../models/pairing_model.dart';

class PairingRepositoryImpl implements PairingRepository {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const PairingRepositoryImpl(this._remoteDataSource);

  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  final PairingRemoteDataSource _remoteDataSource;

  // ---------------------------------------------------------------------------
  // Repository Methods
  // ---------------------------------------------------------------------------

  @override
  Future<void> savePairing(PairingEntity pairing) async {
    final PairingModel model = PairingModel.fromEntity(pairing);

    await _remoteDataSource.savePairing(model);
  }

  @override
  Future<PairingEntity?> getPairing(String id) {
    return _remoteDataSource.getPairing(id);
  }
}