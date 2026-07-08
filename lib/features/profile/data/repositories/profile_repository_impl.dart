// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../../domain/entities/user_crypto_entity.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/user_crypto_model.dart';
import '../models/user_profile_model.dart';

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  // ---------------------------------------------------------------------------
  // User Profile
  // ---------------------------------------------------------------------------

  @override
  Future<void> saveUser(UserEntity user) async {
    final UserProfileModel model = UserProfileModel.fromEntity(user);
    await _remoteDataSource.saveUser(model);
  }

  @override
  Future<UserEntity?> getUser(String uid) {
    return _remoteDataSource.getUser(uid);
  }

  @override
  Future<UserEntity?> getUserByCamoId(String camoId) {
    return _remoteDataSource.getUserByCamoId(camoId);
  }

  // ---------------------------------------------------------------------------
  // User Crypto
  // ---------------------------------------------------------------------------

  @override
  Future<void> saveUserCrypto({
    required String uid,
    required UserCryptoEntity crypto,
  }) async {
    final UserCryptoModel model = UserCryptoModel.fromEntity(crypto);

    await _remoteDataSource.saveUserCrypto(
      uid: uid,
      crypto: model,
    );
  }

  @override
  Future<UserCryptoEntity?> getUserCrypto(String uid) {
    return _remoteDataSource.getUserCrypto(uid);
  }
}