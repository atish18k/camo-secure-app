import '../entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class GetUserProfileUseCase {
  final ProfileRepository _repository;

  const GetUserProfileUseCase(this._repository);

  Future<UserEntity?> call(String uid) {
    return _repository.getUser(uid);
  }
}