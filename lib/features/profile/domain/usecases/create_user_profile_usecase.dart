// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../../../../services/identity/camo_id_generator.dart';
import '../entities/user_entity.dart';
import '../repositories/profile_repository.dart';

// ---------------------------------------------------------------------------
// Class
// ---------------------------------------------------------------------------

class CreateUserProfileUseCase {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const CreateUserProfileUseCase(
    this._repository,
    this._camoIdGenerator,
  );

  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  final ProfileRepository _repository;
  final CamoIdGenerator _camoIdGenerator;

  // ---------------------------------------------------------------------------
  // Public Methods
  // ---------------------------------------------------------------------------

  Future<void> call(UserEntity user) async {
    final String camoId = _resolveCamoId(user);

    await _repository.saveUser(
      user.copyWith(
        camoId: camoId,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Private Methods
  // ---------------------------------------------------------------------------

  String _resolveCamoId(UserEntity user) {
    final String existingCamoId = user.camoId.trim();

    if (existingCamoId.isNotEmpty) {
      return existingCamoId;
    }

    return _camoIdGenerator.generate();
  }
}