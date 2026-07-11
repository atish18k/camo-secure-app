// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_challenge.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_gateway_request.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_gateway_response.dart';
import 'package:camo/core/authorization_gateway/domain/entities/camo_replay_protection_decision.dart';
import 'package:camo/core/authorization_gateway/domain/repositories/camo_authorization_gateway_repository.dart';
import 'package:camo/core/authorization_gateway/domain/usecases/request_camo_authorization_challenge_usecase.dart';
import 'package:camo/core/shared/result/camo_result.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Fake Repository
// -----------------------------------------------------------------------------
final class _FakeGatewayRepository
    implements CamoAuthorizationGatewayRepository {
  @override
  Future<CamoResult<CamoAuthorizationChallenge>> requestChallenge({
    required String userId,
    required String deviceId,
  }) async {
    final DateTime now = DateTime.now();
    return CamoSuccess<CamoAuthorizationChallenge>(
      CamoAuthorizationChallenge(
        challengeId: 'challenge-001',
        challenge: 'challenge-value',
        issuedAt: now,
        expiresAt: now.add(const Duration(seconds: 30)),
      ),
    );
  }

  @override
  Future<CamoResult<CamoAuthorizationGatewayResponse>> submitAuthorization(
    CamoAuthorizationGatewayRequest request,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<CamoResult<CamoReplayProtectionDecision>> validateReplayProtection({
    required String challengeId,
    required String nonce,
    required DateTime clientTime,
  }) async {
    return CamoSuccess<CamoReplayProtectionDecision>(
      CamoReplayProtectionDecision(
        allowed: true,
        reasonCode: 'replay_check_passed',
        evaluatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<CamoResult<void>> consumeChallenge(String challengeId) async {
    return const CamoSuccess<void>(null);
  }
}

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  test('challenge use case delegates to repository', () async {
    final RequestCamoAuthorizationChallengeUseCase useCase =
        RequestCamoAuthorizationChallengeUseCase(_FakeGatewayRepository());
    final CamoResult<CamoAuthorizationChallenge> result = await useCase(
      userId: 'user-001',
      deviceId: 'device-001',
    );
    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull?.isUsable, isTrue);
  });
}
