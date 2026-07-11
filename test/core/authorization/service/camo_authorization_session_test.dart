// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/authorization/domain/entities/camo_authorization_session.dart';
import 'package:camo/core/authorization/domain/entities/camo_authorization_token.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  test('active unconsumed authorization session is usable', () {
    final DateTime now = DateTime.now();
    final CamoAuthorizationSession session = CamoAuthorizationSession(
      sessionId: 'session-001',
      token: CamoAuthorizationToken(
        tokenId: 'token-001',
        authorizationId: 'authorization-001',
        operationId: 'operation-001',
        userId: 'user-001',
        deviceId: 'device-001',
        issuedAt: now,
        expiresAt: now.add(const Duration(seconds: 30)),
        singleUse: true,
        signature: 'signed-token',
      ),
      createdAt: now,
      expiresAt: now.add(const Duration(seconds: 30)),
      consumed: false,
    );
    expect(session.isActive, isTrue);
  });
}
