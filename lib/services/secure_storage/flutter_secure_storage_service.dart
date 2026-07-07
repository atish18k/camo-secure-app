// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'secure_storage_service.dart';

// ---------------------------------------------------------------------------
// Flutter Secure Storage Service
// ---------------------------------------------------------------------------

class FlutterSecureStorageService implements SecureStorageService {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const FlutterSecureStorageService(
    this._storage,
  );

  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  final FlutterSecureStorage _storage;

  // ---------------------------------------------------------------------------
  // Write
  // ---------------------------------------------------------------------------

  @override
  Future<void> write({
    required String key,
    required String value,
  }) {
    return _storage.write(
      key: key,
      value: value,
    );
  }

  // ---------------------------------------------------------------------------
  // Read
  // ---------------------------------------------------------------------------

  @override
  Future<String?> read({
    required String key,
  }) {
    return _storage.read(
      key: key,
    );
  }

  // ---------------------------------------------------------------------------
  // Delete
  // ---------------------------------------------------------------------------

  @override
  Future<void> delete({
    required String key,
  }) {
    return _storage.delete(
      key: key,
    );
  }

  // ---------------------------------------------------------------------------
  // Delete All
  // ---------------------------------------------------------------------------

  @override
  Future<void> deleteAll() {
    return _storage.deleteAll();
  }
}