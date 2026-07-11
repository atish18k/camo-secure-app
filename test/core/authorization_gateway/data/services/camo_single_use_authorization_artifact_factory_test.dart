import 'package:camo/core/authorization_gateway/data/services/default_camo_single_use_authorization_artifact_factory.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime issuedAt = DateTime.utc(2026, 7, 12, 3);
  final DateTime expiresAt = DateTime.utc(2026, 7, 12, 3, 1);

  test('creates normalized valid single-use artifact', () {
    const DefaultCamoSingleUseAuthorizationArtifactFactory factory =
        DefaultCamoSingleUseAuthorizationArtifactFactory();

    final artifact = factory.create(
      operationId: ' operation-001 ',
      authorizationId: ' authorization-001 ',
      challengeId: ' challenge-001 ',
      issuedAt: issuedAt,
      expiresAt: expiresAt,
    );

    expect(artifact.operationId, 'operation-001');
    expect(artifact.authorizationId, 'authorization-001');
    expect(artifact.challengeId, 'challenge-001');
    expect(artifact.isStructurallyValid, isTrue);
  });

  test('rejects artifact with empty operation binding', () {
    const DefaultCamoSingleUseAuthorizationArtifactFactory factory =
        DefaultCamoSingleUseAuthorizationArtifactFactory();

    expect(
      () => factory.create(
        operationId: '',
        authorizationId: 'authorization-001',
        challengeId: 'challenge-001',
        issuedAt: issuedAt,
        expiresAt: expiresAt,
      ),
      throwsStateError,
    );
  });

  test('rejects artifact with invalid expiry window', () {
    const DefaultCamoSingleUseAuthorizationArtifactFactory factory =
        DefaultCamoSingleUseAuthorizationArtifactFactory();

    expect(
      () => factory.create(
        operationId: 'operation-001',
        authorizationId: 'authorization-001',
        challengeId: 'challenge-001',
        issuedAt: expiresAt,
        expiresAt: issuedAt,
      ),
      throwsStateError,
    );
  });
}
