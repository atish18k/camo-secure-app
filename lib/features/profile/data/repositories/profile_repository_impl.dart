// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/user_profile_model.dart';

// ---------------------------------------------------------------------------
// Repository
// ---------------------------------------------------------------------------

class ProfileRepositoryImpl implements ProfileRepository {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const ProfileRepositoryImpl(this._remoteDataSource);

  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

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
}