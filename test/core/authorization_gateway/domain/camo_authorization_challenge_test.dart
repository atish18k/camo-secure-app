// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_challenge.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  group('CamoAuthorizationChallenge', () {
    test('unexpired challenge is usable', () {
      final DateTime now = DateTime.now();
      final CamoAuthorizationChallenge challenge = CamoAuthorizationChallenge(
        challengeId: 'challenge-001',
        challenge: 'challenge-value',
        issuedAt: now,
        expiresAt: now.add(const Duration(seconds: 30)),
      );
      expect(challenge.isUsable, isTrue);
      expect(challenge.isExpired, isFalse);
    });
    test('expired challenge is unusable', () {
      final DateTime now = DateTime.now();
      final CamoAuthorizationChallenge challenge = CamoAuthorizationChallenge(
        challengeId: 'challenge-002',
        challenge: 'challenge-value',
        issuedAt: now.subtract(const Duration(minutes: 1)),
        expiresAt: now.subtract(const Duration(seconds: 1)),
      );
      expect(challenge.isUsable, isFalse);
    });
  });
}
