import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthRemoteDataSource {
  Future<UserCredential> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  User? get currentUser;
}

class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthRemoteDataSource(this._firebaseAuth);

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
  Future<void> signOut() {
    return _firebaseAuth.signOut();
  }

  @override
  User? get currentUser => _firebaseAuth.currentUser;
}