import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource);
  final AuthRemoteDataSource _remoteDataSource;

  @override
  Future<Result<void>> signIn({
    required String email,
    required String password,
  }) async {
    return _runAuth(
      () => _remoteDataSource.signIn(email: email.trim(), password: password),
    );
  }

  @override
  Future<Result<void>> createAccount({
    required String email,
    required String password,
  }) async {
    return _runAuth(
      () => _remoteDataSource.createAccount(
        email: email.trim(),
        password: password,
      ),
    );
  }

  Future<Result<void>> _runAuth(Future<Object?> Function() action) async {
    try {
      await action();
      return const Success<void>(null);
    } on FirebaseAuthException catch (error) {
      return Error<void>(
        AuthFailure(
          message: error.message ?? 'Authentication failed.',
          code: error.code,
          cause: error,
        ),
      );
    } catch (error) {
      return Error<void>(
        UnknownFailure(
          message: 'Unexpected authentication error.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<void> sendEmailVerification() =>
      _remoteDataSource.sendEmailVerification();

  @override
  Future<void> reloadCurrentUser() => _remoteDataSource.reloadCurrentUser();

  @override
  Future<void> deleteCurrentUser() => _remoteDataSource.deleteCurrentUser();

  @override
  Future<Result<void>> signOut() async {
    try {
      await _remoteDataSource.signOut();
      return const Success<void>(null);
    } catch (error) {
      return Error<void>(AuthFailure(message: 'Logout failed.', cause: error));
    }
  }

  @override
  bool get isSignedIn => _remoteDataSource.currentUser != null;

  @override
  bool get isEmailVerified =>
      _remoteDataSource.currentUser?.emailVerified ?? false;

  @override
  String? get currentUserId => _remoteDataSource.currentUser?.uid;

  @override
  String? get currentUserEmail => _remoteDataSource.currentUser?.email;
}
