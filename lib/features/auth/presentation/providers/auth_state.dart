import '../../../../core/errors/failure.dart';

enum AuthStatus {
  initial,
  loading,
  awaitingEmailVerification,
  authenticated,
  unauthenticated,
  failure,
}

class AuthState {
  const AuthState({required this.status, this.failure});
  const AuthState.initial() : status = AuthStatus.initial, failure = null;
  const AuthState.loading() : status = AuthStatus.loading, failure = null;
  const AuthState.awaitingEmailVerification()
    : status = AuthStatus.awaitingEmailVerification,
      failure = null;
  const AuthState.authenticated()
    : status = AuthStatus.authenticated,
      failure = null;
  const AuthState.unauthenticated()
    : status = AuthStatus.unauthenticated,
      failure = null;
  const AuthState.failure(this.failure) : status = AuthStatus.failure;

  final AuthStatus status;
  final Failure? failure;
}
