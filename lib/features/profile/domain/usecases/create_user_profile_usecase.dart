import '../../../../services/identity/camo_id_generator.dart';
import '../entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class CreateUserProfileUseCase {
  final ProfileRepository _repository;
  final CamoIdGenerator _camoIdGenerator;

  const CreateUserProfileUseCase(
    this._repository,
    this._camoIdGenerator,
  );

  Future<void> call(UserEntity user) async {
    final camoId = user.camoId.trim().isNotEmpty
        ? user.camoId.trim()
        : _camoIdGenerator.generate();

    await _repository.saveUser(
      user.copyWith(camoId: camoId),
    );
  }
}