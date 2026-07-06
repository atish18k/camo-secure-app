import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/result.dart';

abstract class AuthRepository {
  Future<Result<void>> signIn({
    required String email,
    required String password,
  });

  Future<Result<void>> signOut();

  bool get isSignedIn;

  User? get currentUser;

  String? get currentUserId;
}