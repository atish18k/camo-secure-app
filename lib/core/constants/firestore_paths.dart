// ---------------------------------------------------------------------------
// File: firestore_paths.dart
// Module: Core Constants
// Purpose:
//   Centralized Firestore collection/document path constants.
//
// Sprint:
//   Sprint-007 (v0.7.0)
// ---------------------------------------------------------------------------

abstract final class FirestorePaths {
  const FirestorePaths._();

  // ---------------------------------------------------------------------------
  // Collections
  // ---------------------------------------------------------------------------

  static const String users = 'users';

  static const String pairings = 'pairings';

  static const String pairRequests = 'pair_requests';

  // ---------------------------------------------------------------------------
  // Future Collections
  // ---------------------------------------------------------------------------

  static const String conversations = 'conversations';

  static const String messages = 'messages';

  static const String devices = 'devices';

  static const String sessions = 'sessions';

  static const String encryptionKeys = 'encryption_keys';

  static const String auditLogs = 'audit_logs';
}