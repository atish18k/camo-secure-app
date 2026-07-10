// ---------------------------------------------------------------------------
// CAMO Policy Runtime State
// ---------------------------------------------------------------------------

/// Verified runtime state supplied to the Policy Engine.
///
/// Values in this object must originate from trusted repositories,
/// device-security services, or server-side policy validation.
///
/// Plaintext, encryption keys, private keys, and decrypted content must never
/// be added to this object.
class CamoPolicyRuntimeState {
  const CamoPolicyRuntimeState({
    required this.deviceId,
    required this.isDeviceValid,
    required this.isLicenseValid,
    this.messageId,
    this.isExpired = false,
    this.isBurned = false,
    this.isDeleted = false,
    this.isRevoked = false,
    this.isBlocked = false,
    this.policyVersion = 1,
    this.requiredPolicyVersion = 1,
  });

  /// Identifier of the currently bound device.
  final String deviceId;

  /// Whether the current device binding is valid.
  final bool isDeviceValid;

  /// Whether the current CAMO license is valid.
  final bool isLicenseValid;

  /// Server-side message-policy identifier required for decode operations.
  final String? messageId;

  /// Whether the message has expired.
  final bool isExpired;

  /// Whether the message was already burned.
  final bool isBurned;

  /// Whether the message was deleted.
  final bool isDeleted;

  /// Whether access to the message was remotely revoked.
  final bool isRevoked;

  /// Whether the relevant user, pair, or message is blocked.
  final bool isBlocked;

  /// Policy version attached to the message or operation.
  final int policyVersion;

  /// Minimum policy version required by the current client/server policy.
  final int requiredPolicyVersion;
}