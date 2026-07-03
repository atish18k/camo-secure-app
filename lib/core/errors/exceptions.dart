// ---------------------------------------------------------------------------
// File: exceptions.dart
// Module: Core Errors
// Purpose:
//   Defines exceptions thrown by data sources and services.
// ---------------------------------------------------------------------------

abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException({
    required this.message,
    this.code,
  });

  @override
  String toString() {
    return '$runtimeType(message: $message, code: $code)';
  }
}

class NetworkException extends AppException {
  const NetworkException({
    super.message = 'Network error occurred.',
    super.code,
  });
}

class FirebaseException extends AppException {
  const FirebaseException({
    super.message = 'Firebase operation failed.',
    super.code,
  });
}

class AuthException extends AppException {
  const AuthException({
    super.message = 'Authentication failed.',
    super.code,
  });
}

class ValidationException extends AppException {
  const ValidationException({
    super.message = 'Validation failed.',
    super.code,
  });
}

class CryptoException extends AppException {
  const CryptoException({
    super.message = 'Cryptographic operation failed.',
    super.code,
  });
}

class PairingException extends AppException {
  const PairingException({
    super.message = 'Pairing operation failed.',
    super.code,
  });
}

class StorageException extends AppException {
  const StorageException({
    super.message = 'Storage operation failed.',
    super.code,
  });
}

class AiException extends AppException {
  const AiException({
    super.message = 'AI camouflage operation failed.',
    super.code,
  });
}