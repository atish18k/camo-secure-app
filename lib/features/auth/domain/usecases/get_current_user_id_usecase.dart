import '../repositories/auth_repository.dart';

class GetCurrentUserIdUseCase {
  final AuthRepository _repository;

  const GetCurrentUserIdUseCase(this._repository);

  String? call() {
    return _repository.currentUserId;
  }
}