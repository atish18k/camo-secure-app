// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../entities/camo_message_policy_state.dart';

// ---------------------------------------------------------------------------
// CAMO Message Policy Service
// ---------------------------------------------------------------------------

/// Provides verified server-side policy state for protected CAMO messages.
///
/// Implementations must read only policy flags and identifiers from trusted
/// server-side storage.
///
/// This service must never read, receive, store, or expose plaintext,
/// decrypted content, encryption keys, or private keys.
abstract class CamoMessagePolicyService {
  /// Returns verified policy state for the supplied message.
  ///
  /// Throws a [StateError] when the message policy record does not exist or
  /// cannot be verified.
  Future<CamoMessagePolicyState> getMessagePolicy(
    String messageId,
  );
}