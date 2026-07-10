// ---------------------------------------------------------------------------
// CAMO Message Policy State
// ---------------------------------------------------------------------------

/// Verified server-side policy state for a protected CAMO message.
///
/// This entity contains policy flags only. It must never contain plaintext,
/// decrypted content, encryption keys, or private keys.
class CamoMessagePolicyState {
  const CamoMessagePolicyState({
    required this.messageId,
    required this.isExpired,
    required this.isBurned,
    required this.isDeleted,
    required this.isRevoked,
    required this.isBlocked,
    required this.policyVersion,
    required this.requiredPolicyVersion,
  });

  /// Unique server-side policy identifier for the message.
  final String messageId;

  /// Whether the message has expired.
  final bool isExpired;

  /// Whether the message was already burned after reading.
  final bool isBurned;

  /// Whether the message was deleted.
  final bool isDeleted;

  /// Whether message access was remotely revoked.
  final bool isRevoked;

  /// Whether access is blocked by user, pair, or organization policy.
  final bool isBlocked;

  /// Policy version attached to this message.
  final int policyVersion;

  /// Minimum policy version required by the current policy engine.
  final int requiredPolicyVersion;
}