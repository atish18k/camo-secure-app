import '../entities/user_entity.dart';

abstract interface class ProfileRepository {
  Future<void> saveUser(UserEntity user);

  Future<UserEntity?> getUser(String uid);

  Future<UserEntity?> getUserByCamoId(String camoId);
}