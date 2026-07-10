// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'camo_policy_operation.dart';

// ---------------------------------------------------------------------------
// CAMO Policy Context
// ---------------------------------------------------------------------------

/// Immutable input evaluated by the CAMO Policy Engine.
///
/// Only minimum necessary policy data is included.
/// Plaintext, private keys, and decrypted content must never be added here.
class CamoPolicyContext {
  const CamoPolicyContext({
    required this.operation,
    required this.currentUserId,
    required this.deviceId,
    required this.pairingId,
    required this.isAuthenticated,
    required this.isDeviceValid,
    required this.isLicenseValid,
    required this.isPairAccepted,
    this.messageId,
    this.isExpired = false,
    this.isBurned = false,
    this.isDeleted = false,
    this.isRevoked = false,
    this.isBlocked = false,
    this.policyVersion = 1,
    this.requiredPolicyVersion = 1,
  });

  final CamoPolicyOperation operation;
  final String currentUserId;
  final String deviceId;
  final String pairingId;
  final String? messageId;

  final bool isAuthenticated;
  final bool isDeviceValid;
  final bool isLicenseValid;
  final bool isPairAccepted;

  final bool isExpired;
  final bool isBurned;
  final bool isDeleted;
  final bool isRevoked;
  final bool isBlocked;

  final int policyVersion;
  final int requiredPolicyVersion;
}