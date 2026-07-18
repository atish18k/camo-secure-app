import '../../../../core/errors/result.dart';

abstract class AuthRepository {
  Future<Result<void>> signIn({
    required String email,
    required String password,
  });
  Future<Result<void>> createAccount({
    required String email,
    required String password,
  });
  Future<void> sendEmailVerification();
  Future<void> reloadCurrentUser();
  Future<void> deleteCurrentUser();
  Future<Result<void>> signOut();
  bool get isSignedIn;
  bool get isEmailVerified;
  String? get currentUserId;
  String? get currentUserEmail;
}
