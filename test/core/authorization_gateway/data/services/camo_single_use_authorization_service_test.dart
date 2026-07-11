import 'package:camo/core/authorization_gateway/data/repositories/camo_memory_single_use_authorization_store.dart';
import 'package:camo/core/authorization_gateway/data/repositories/fail_closed_camo_single_use_authorization_store.dart';
import 'package:camo/core/authorization_gateway/data/services/default_camo_single_use_authorization_service.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_single_use_authorization_artifact.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime fixedTime = DateTime.utc(2026, 7, 12, 1);

  CamoSingleUseAuthorizationArtifact createArtifact({
    String operationId = 'operation-001',
    String authorizationId = 'authorization-001',
    String challengeId = 'challenge-001',
    DateTime? expiresAt,
  }) {
    return CamoSingleUseAuthorizationArtifact(
      operationId: operationId,
      authorizationId: authorizationId,
      challengeId: challengeId,
      issuedAt: fixedTime.subtract(const Duration(seconds: 10)),
      expiresAt: expiresAt ?? fixedTime.add(const Duration(minutes: 1)),
    );
  }

  test('permits first valid artifact consumption', () async {
    final service = DefaultCamoSingleUseAuthorizationService(
      store: CamoMemorySingleUseAuthorizationStore(),
      clock: () => fixedTime,
    );

    final decision = await service.consume(createArtifact());

    expect(decision.permitsOperation, isTrue);
  });

  test('denies duplicate operation id', () async {
    final store = CamoMemorySingleUseAuthorizationStore();

    final service = DefaultCamoSingleUseAuthorizationService(
      store: store,
      clock: () => fixedTime,
    );

    await service.consume(createArtifact());

    final decision = await service.consume(
      createArtifact(
        authorizationId: 'authorization-002',
        challengeId: 'challenge-002',
      ),
    );

    expect(decision.permitsOperation, isFalse);
    expect(decision.reasonCode, 'single_use_authorization_replay_detected');
  });

  test('denies duplicate authorization id', () async {
    final store = CamoMemorySingleUseAuthorizationStore();

    final service = DefaultCamoSingleUseAuthorizationService(
      store: store,
      clock: () => fixedTime,
    );

    await service.consume(createArtifact());

    final decision = await service.consume(
      createArtifact(
        operationId: 'operation-002',
        challengeId: 'challenge-002',
      ),
    );

    expect(decision.permitsOperation, isFalse);
  });

  test('denies duplicate challenge id', () async {
    final store = CamoMemorySingleUseAuthorizationStore();

    final service = DefaultCamoSingleUseAuthorizationService(
      store: store,
      clock: () => fixedTime,
    );

    await service.consume(createArtifact());

    final decision = await service.consume(
      createArtifact(
        operationId: 'operation-002',
        authorizationId: 'authorization-002',
      ),
    );

    expect(decision.permitsOperation, isFalse);
  });

  test('denies expired authorization artifact', () async {
    final service = DefaultCamoSingleUseAuthorizationService(
      store: CamoMemorySingleUseAuthorizationStore(),
      clock: () => fixedTime,
    );

    final decision = await service.consume(
      createArtifact(expiresAt: fixedTime),
    );

    expect(decision.permitsOperation, isFalse);
    expect(decision.reasonCode, 'single_use_authorization_artifact_expired');
  });

  test('fails closed when production store is unavailable', () async {
    final service = DefaultCamoSingleUseAuthorizationService(
      store: const FailClosedCamoSingleUseAuthorizationStore(),
      clock: () => fixedTime,
    );

    final decision = await service.consume(createArtifact());

    expect(decision.permitsOperation, isFalse);
    expect(decision.reasonCode, 'single_use_authorization_store_unavailable');
  });

  test('rejects structurally invalid artifact', () async {
    final service = DefaultCamoSingleUseAuthorizationService(
      store: CamoMemorySingleUseAuthorizationStore(),
      clock: () => fixedTime,
    );

    final decision = await service.consume(createArtifact(operationId: ''));

    expect(decision.permitsOperation, isFalse);
    expect(decision.reasonCode, 'single_use_authorization_artifact_invalid');
  });
}
