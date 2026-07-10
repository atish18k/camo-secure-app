// ---------------------------------------------------------------------------
// File: firestore_paths.dart
// Module: Core Constants
// Purpose:
//   Centralized Firestore collection/document path constants.
// ---------------------------------------------------------------------------

abstract final class FirestorePaths {
  const FirestorePaths._();

  // ---------------------------------------------------------------------------
  // Identity and Profile Collections
  // ---------------------------------------------------------------------------

  static const String users = 'users';

  static const String devices = 'devices';

  static const String sessions = 'sessions';

  // ---------------------------------------------------------------------------
  // Pairing Collections
  // ---------------------------------------------------------------------------

  static const String pairings = 'pairings';

  static const String pairRequests = 'pair_requests';

  // ---------------------------------------------------------------------------
  // Policy Collections
  // ---------------------------------------------------------------------------

  /// Stores policy flags and lifecycle state only.
  ///
  /// Plaintext, decrypted content, private keys, shared secrets, and derived
  /// encryption keys must never be stored in this collection.
  static const String messagePolicies = 'message_policies';

  // ---------------------------------------------------------------------------
  // History and Transport Collections
  // ---------------------------------------------------------------------------

  static const String conversations = 'conversations';

  static const String messages = 'messages';

  // ---------------------------------------------------------------------------
  // Enterprise Collections
  // ---------------------------------------------------------------------------

  static const String auditLogs = 'audit_logs';

  // ---------------------------------------------------------------------------
  // Reserved Collections
  // ---------------------------------------------------------------------------

  /// Reserved for a future, separately approved key-management specification.
  ///
  /// This collection must never store plaintext private keys, shared secrets,
  /// or unwrapped derived encryption keys.
  static const String encryptionKeys = 'encryption_keys';
}