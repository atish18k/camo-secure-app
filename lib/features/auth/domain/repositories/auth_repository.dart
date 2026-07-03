import '../../../../core/errors/result.dart';

abstract class AuthRepository {
  Future<Result<void>> signIn({
    required String email,
    required String password,
  });

  Future<Result<void>> signOut();

  bool get isSignedIn;
}
