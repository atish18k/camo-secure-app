import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRemoteDataSource {
  Future<UserCredential> signIn({
    required String email,
    required String password,
  });
  Future<UserCredential> createAccount({
    required String email,
    required String password,
  });
  Future<void> sendEmailVerification();
  Future<void> reloadCurrentUser();
  Future<void> deleteCurrentUser();
  Future<void> signOut();
  User? get currentUser;
}

class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  const FirebaseAuthRemoteDataSource(this._firebaseAuth);
  final FirebaseAuth _firebaseAuth;

  @override
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<UserCredential> createAccount({
    required String email,
    required String password,
  }) {
    return _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> sendEmailVerification() async {
    final User? user = currentUser;
    if (user == null) throw StateError('Authenticated user is required.');
    await user.sendEmailVerification();
  }

  @override
  Future<void> reloadCurrentUser() async {
    final User? user = currentUser;
    if (user == null) throw StateError('Authenticated user is required.');
    await user.reload();
  }

  @override
  Future<void> deleteCurrentUser() async {
    final User? user = currentUser;
    if (user != null) await user.delete();
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  @override
  User? get currentUser => _firebaseAuth.currentUser;
}
