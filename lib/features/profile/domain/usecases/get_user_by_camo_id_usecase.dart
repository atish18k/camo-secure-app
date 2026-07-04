import '../entities/user_entity.dart';
import '../repositories/profile_repository.dart';

class GetUserByCamoIdUseCase {
  final ProfileRepository _repository;

  const GetUserByCamoIdUseCase(this._repository);

  Future<UserEntity?> call(String camoId) {
    return _repository.getUserByCamoId(camoId);
  }
}