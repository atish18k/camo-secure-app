import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';
import '../models/user_profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;

  const ProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> saveUser(UserEntity user) async {
    final model = UserProfileModel.fromEntity(user);

    await _remoteDataSource.saveUser(model);
  }

  @override
  Future<UserEntity?> getUser(String uid) {
    return _remoteDataSource.getUser(uid);
  }
}