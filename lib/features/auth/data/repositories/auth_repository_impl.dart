import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  const AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<void>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _remoteDataSource.signIn(email: email.trim(), password: password);

      return const Success(null);
    } on FirebaseAuthException catch (e) {
      return Error(
        AuthFailure(
          message: e.message ?? 'Authentication failed.',
          code: e.code,
          cause: e,
        ),
      );
    } catch (e) {
      return Error(
        UnknownFailure(message: 'Unexpected authentication error.', cause: e),
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Success(null);
    } catch (e) {
      return Error(AuthFailure(message: 'Logout failed.', cause: e));
    }
  }

  @override
  bool get isSignedIn => _remoteDataSource.currentUser != null;

  @override
  User? get currentUser => _remoteDataSource.currentUser;

  @override
  String? get currentUserId => _remoteDataSource.currentUser?.uid;
}