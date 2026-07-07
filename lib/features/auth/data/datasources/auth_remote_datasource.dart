// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:firebase_auth/firebase_auth.dart';

// ---------------------------------------------------------------------------
// Remote Data Source
// ---------------------------------------------------------------------------

abstract class AuthRemoteDataSource {
  Future<UserCredential> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  User? get currentUser;
}

// ---------------------------------------------------------------------------
// Firebase Implementation
// ---------------------------------------------------------------------------

class FirebaseAuthRemoteDataSource implements AuthRemoteDataSource {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const FirebaseAuthRemoteDataSource(this._firebaseAuth);

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final FirebaseAuth _firebaseAuth;

  // ---------------------------------------------------------------------------
  // Authentication
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Getters
  // ---------------------------------------------------------------------------

  @override
  User? get currentUser => _firebaseAuth.currentUser;
}