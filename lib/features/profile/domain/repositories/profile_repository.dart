import '../entities/user_crypto_entity.dart';
import '../entities/user_entity.dart';

abstract interface class ProfileRepository {
  Future<void> saveUser(UserEntity user);

  Future<UserEntity?> getUser(String uid);

  Future<UserEntity?> getUserByCamoId(String camoId);

  // ---------------------------------------------------------------------------
  // Crypto
  // ---------------------------------------------------------------------------

  Future<void> saveUserCrypto({
    required String uid,
    required UserCryptoEntity crypto,
  });

  Future<UserCryptoEntity?> getUserCrypto(
    String uid,
  );
}