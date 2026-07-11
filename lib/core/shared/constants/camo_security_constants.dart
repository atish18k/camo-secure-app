// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
abstract final class CamoSecurityConstants {
  static const String platformName = 'CAMO';
  static const String securityConstitutionVersion = '1.0.0';
  static const String cryptographicProtocolVersion = 'CAMO-V2';
  static const Duration defaultAuthorizationTtl = Duration(seconds: 30);
  static const Duration maximumAuthorizationTtl = Duration(minutes: 1);
  static const Duration defaultChallengeTtl = Duration(seconds: 30);
  static const int aes256KeyLengthBytes = 32;
  static const int aesGcmNonceLengthBytes = 12;
  static const int aesGcmMacLengthBytes = 16;
}
