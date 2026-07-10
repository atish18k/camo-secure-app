// ---------------------------------------------------------------------------
// File: failure.dart
// Module: Core Errors
// Purpose:
//   Defines failure types used across CAMO repositories, services,
//   and business logic.
// ---------------------------------------------------------------------------

abstract class Failure {
  const Failure({
    required this.message,
    this.code,
    this.cause,
  });

  final String message;
  final String? code;
  final Object? cause;

  @override
  String toString() {
    return 'Failure(message: $message, code: $code, cause: $cause)';
  }
}

class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Something went wrong.',
    super.code,
    super.cause,
  });
}

class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Network error occurred.',
    super.code,
    super.cause,
  });
}

class FirebaseFailure extends Failure {
  const FirebaseFailure({
    super.message = 'Firebase operation failed.',
    super.code,
    super.cause,
  });
}

class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Authentication failed.',
    super.code,
    super.cause,
  });
}

class DeviceRegistrationFailure extends Failure {
  const DeviceRegistrationFailure({
    super.message = 'Secure device registration failed.',
    super.code = 'device-registration-failed',
    super.cause,
  });
}

class ValidationFailure extends Failure {
  const ValidationFailure({
    super.message = 'Validation failed.',
    super.code,
    super.cause,
  });
}

class CryptoFailure extends Failure {
  const CryptoFailure({
    super.message = 'Cryptographic operation failed.',
    super.code,
    super.cause,
  });
}

class PairingFailure extends Failure {
  const PairingFailure({
    super.message = 'Pairing operation failed.',
    super.code,
    super.cause,
  });
}

class AiFailure extends Failure {
  const AiFailure({
    super.message = 'AI camouflage operation failed.',
    super.code,
    super.cause,
  });
}

class StorageFailure extends Failure {
  const StorageFailure({
    super.message = 'Storage operation failed.',
    super.code,
    super.cause,
  });
}
