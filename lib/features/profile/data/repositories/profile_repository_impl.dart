// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/user_profile_model.dart';

// ---------------------------------------------------------------------------
// Profile Repository Implementation
// ---------------------------------------------------------------------------

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._remoteDataSource);

  final ProfileRemoteDataSource _remoteDataSource;

  // ---------------------------------------------------------------------------
  // Save User
  // ---------------------------------------------------------------------------

  @override
  Future<void> saveUser(UserEntity user) async {
    final UserProfileModel model = UserProfileModel.fromEntity(user);

    await _remoteDataSource.saveUser(model);
  }

  // ---------------------------------------------------------------------------
  // Get User
  // ---------------------------------------------------------------------------

  @override
  Future<UserEntity?> getUser(String uid) {
    return _remoteDataSource.getUser(uid);
  }

  // ---------------------------------------------------------------------------
  // Get User by CAMO ID
  // ---------------------------------------------------------------------------

  @override
  Future<UserEntity?> getUserByCamoId(String camoId) {
    return _remoteDataSource.getUserByCamoId(camoId);
  }
}
