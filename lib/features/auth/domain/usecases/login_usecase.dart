import '../../../../core/errors/result.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<Result<void>> call({
    required String email,
    required String password,
  }) {
    return _repository.signIn(email: email, password: password);
  }
}