import '../../../../services/identity/camo_id_generator.dart';
import '../entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class CreateUserProfileUseCase {
  const CreateUserProfileUseCase(this._repository, this._camoIdGenerator);
  final ProfileRepository _repository;
  final CamoIdGenerator _camoIdGenerator;

  Future<void> call(UserEntity user) async {
    final UserEntity? existing = await _repository.getUser(user.uid);
    if (existing != null) {
      await _repository.saveUser(
        existing.copyWith(
          email: user.email,
          displayName: user.displayName,
          photoUrl: user.photoUrl,
        ),
      );
      return;
    }
    final String requested = user.camoId.trim();
    await _repository.saveUser(
      user.copyWith(
        camoId: requested.isEmpty ? _camoIdGenerator.generate() : requested,
      ),
    );
  }
}
