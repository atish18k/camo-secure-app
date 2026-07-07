// ---------------------------------------------------------------------------
// Crypto Payload
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

  /// Payload format version.
  final int version;

  /// Encryption algorithm identifier.
  final String algorithm;

  /// Base64 encoded nonce / IV.
  final String nonce;

  /// Base64 encoded encrypted message.
  final String cipherText;

  /// Base64 encoded authentication tag / MAC.
  final String authenticationTag;

  /// UTC timestamp.
  final DateTime createdAt;

  /// Optional camouflage subject.
  final String? subject;

  /// Indicates whether camouflage mode was enabled.
  final bool camouflageEnabled;
}