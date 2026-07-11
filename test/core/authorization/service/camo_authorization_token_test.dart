// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/authorization/domain/entities/camo_authorization_token.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  group('CamoAuthorizationToken', () {
    test('valid unexpired token is usable', () {
      final DateTime now = DateTime.now();
      final CamoAuthorizationToken token = CamoAuthorizationToken(
        tokenId: 'token-001',
        authorizationId: 'authorization-001',
        operationId: 'operation-001',
        userId: 'user-001',
        deviceId: 'device-001',
        issuedAt: now,
        expiresAt: now.add(const Duration(seconds: 30)),
        singleUse: true,
        signature: 'signed-token',
      );
      expect(token.isUsable, isTrue);
      expect(token.isExpired, isFalse);
    });
    test('unsigned token is unusable', () {
      final DateTime now = DateTime.now();
      final CamoAuthorizationToken token = CamoAuthorizationToken(
        tokenId: 'token-002',
        authorizationId: 'authorization-002',
        operationId: 'operation-002',
        userId: 'user-001',
        deviceId: 'device-001',
        issuedAt: now,
        expiresAt: now.add(const Duration(seconds: 30)),
        singleUse: true,
        signature: '',
      );
      expect(token.isUsable, isFalse);
    });
  });
}
