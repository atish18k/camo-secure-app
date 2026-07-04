import '../entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class CreateUserProfileUseCase {
  final ProfileRepository _repository;

  const CreateUserProfileUseCase(this._repository);

  Future<void> call(UserEntity user) {
    return _repository.saveUser(user);
  }
}