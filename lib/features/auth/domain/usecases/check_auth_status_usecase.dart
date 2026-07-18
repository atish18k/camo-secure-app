import '../repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  const CheckAuthStatusUseCase(this._repository);
  final AuthRepository _repository;

  bool call() => _repository.isSignedIn && _repository.isEmailVerified;
}
