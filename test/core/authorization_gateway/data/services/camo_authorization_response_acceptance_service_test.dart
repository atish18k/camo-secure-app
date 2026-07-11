import 'package:camo/core/authorization_gateway/data/repositories/camo_memory_single_use_authorization_store.dart';
import 'package:camo/core/authorization_gateway/data/repositories/fail_closed_camo_single_use_authorization_store.dart';
import 'package:camo/core/authorization_gateway/data/services/default_camo_authorization_response_acceptance_service.dart';
import 'package:camo/core/authorization_gateway/data/services/default_camo_single_use_authorization_service.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_signature_verification_decision.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_single_use_authorization_artifact.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime fixedTime = DateTime.utc(2026, 7, 12, 2);

  CamoSingleUseAuthorizationArtifact createArtifact({
    String operationId = 'operation-001',
    String authorizationId = 'authorization-001',
    String challengeId = 'challenge-001',
  }) {
    return CamoSingleUseAuthorizationArtifact(
      operationId: operationId,
      authorizationId: authorizationId,
      challengeId: challengeId,
      issuedAt: fixedTime.subtract(const Duration(seconds: 5)),
      expiresAt: fixedTime.add(const Duration(minutes: 1)),
    );
  }

  test('accepts verified response on first single-use consumption', () async {
    final singleUseService = DefaultCamoSingleUseAuthorizationService(
      store: CamoMemorySingleUseAuthorizationStore(),
      clock: () => fixedTime,
    );

    final service = DefaultCamoAuthorizationResponseAcceptanceService(
      singleUseService: singleUseService,
    );

    final decision = await service.accept(
      signatureDecision:
          const CamoAuthorizationSignatureVerificationDecision.verified(),
      singleUseArtifact: createArtifact(),
    );

    expect(decision.permitsCoordinatorUse, isTrue);
  });

  test('does not consume artifact when signature verification fails', () async {
    final store = CamoMemorySingleUseAuthorizationStore();

    final singleUseService = DefaultCamoSingleUseAuthorizationService(
      store: store,
      clock: () => fixedTime,
    );

    final service = DefaultCamoAuthorizationResponseAcceptanceService(
      singleUseService: singleUseService,
    );

    final deniedDecision = await service.accept(
      signatureDecision:
          const CamoAuthorizationSignatureVerificationDecision.denied(
            'authorization_response_signature_invalid',
          ),
      singleUseArtifact: createArtifact(),
    );

    expect(deniedDecision.permitsCoordinatorUse, isFalse);

    final acceptedDecision = await service.accept(
      signatureDecision:
          const CamoAuthorizationSignatureVerificationDecision.verified(),
      singleUseArtifact: createArtifact(),
    );

    expect(acceptedDecision.permitsCoordinatorUse, isTrue);
  });

  test('denies verified response when artifact is replayed', () async {
    final singleUseService = DefaultCamoSingleUseAuthorizationService(
      store: CamoMemorySingleUseAuthorizationStore(),
      clock: () => fixedTime,
    );

    final service = DefaultCamoAuthorizationResponseAcceptanceService(
      singleUseService: singleUseService,
    );

    await service.accept(
      signatureDecision:
          const CamoAuthorizationSignatureVerificationDecision.verified(),
      singleUseArtifact: createArtifact(),
    );

    final replayDecision = await service.accept(
      signatureDecision:
          const CamoAuthorizationSignatureVerificationDecision.verified(),
      singleUseArtifact: createArtifact(),
    );

    expect(replayDecision.permitsCoordinatorUse, isFalse);

    expect(
      replayDecision.reasonCode,
      'single_use_authorization_replay_detected',
    );
  });

  test('fails closed when replay store is unavailable', () async {
    final singleUseService = DefaultCamoSingleUseAuthorizationService(
      store: const FailClosedCamoSingleUseAuthorizationStore(),
      clock: () => fixedTime,
    );

    final service = DefaultCamoAuthorizationResponseAcceptanceService(
      singleUseService: singleUseService,
    );

    final decision = await service.accept(
      signatureDecision:
          const CamoAuthorizationSignatureVerificationDecision.verified(),
      singleUseArtifact: createArtifact(),
    );

    expect(decision.permitsCoordinatorUse, isFalse);

    expect(decision.reasonCode, 'single_use_authorization_store_unavailable');
  });

  test('signature verification always precedes replay consumption', () async {
    final store = CamoMemorySingleUseAuthorizationStore();

    final singleUseService = DefaultCamoSingleUseAuthorizationService(
      store: store,
      clock: () => fixedTime,
    );

    final service = DefaultCamoAuthorizationResponseAcceptanceService(
      singleUseService: singleUseService,
    );

    final artifact = createArtifact();

    await service.accept(
      signatureDecision:
          const CamoAuthorizationSignatureVerificationDecision.denied(
            'signature_denied',
          ),
      singleUseArtifact: artifact,
    );

    final decision = await service.accept(
      signatureDecision:
          const CamoAuthorizationSignatureVerificationDecision.verified(),
      singleUseArtifact: artifact,
    );

    expect(decision.permitsCoordinatorUse, isTrue);
  });
}
