// ---------------------------------------------------------------------------
// Legacy Crypto Payload
// ---------------------------------------------------------------------------
//
// NOTE:
// This entity represents the legacy CAMO payload model used by the CM1
// formatter.
//
// New compact binary payloads use:
// features/payload/domain/entities/camo_payload_packet.dart
//
// Keep this file for backward compatibility until legacy decode migration
// is fully removed in a future stable version.
// ---------------------------------------------------------------------------

class CamoCryptoPayload {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const CamoCryptoPayload({
    required this.version,
    required this.algorithm,
    required this.nonce,
    required this.cipherText,
    required this.authenticationTag,
    required this.createdAt,
    this.subject,
    this.camouflageEnabled = false,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  /// Legacy payload format version.
  final int version;

  /// Legacy encryption algorithm identifier.
  final String algorithm;

  /// Base64Url encoded nonce / IV.
  final String nonce;

  /// Base64Url encoded encrypted message.
  final String cipherText;

  /// Base64Url encoded authentication tag / MAC.
  final String authenticationTag;

  /// UTC timestamp for the legacy payload.
  final DateTime createdAt;

  /// Optional legacy camouflage subject.
  final String? subject;

  /// Indicates whether legacy camouflage mode was enabled.
  final bool camouflageEnabled;
}