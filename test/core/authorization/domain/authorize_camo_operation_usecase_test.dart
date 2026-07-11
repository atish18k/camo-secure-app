// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/authorization/domain/entities/camo_authorization_context.dart';
import 'package:camo/core/authorization/domain/entities/camo_authorization_decision.dart';
import 'package:camo/core/authorization/domain/entities/camo_authorization_status.dart';
import 'package:camo/core/authorization/domain/repositories/camo_authorization_repository.dart';
import 'package:camo/core/authorization/domain/usecases/authorize_camo_operation_usecase.dart';
import 'package:camo/core/shared/result/camo_result.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:camo/core/shared/types/camo_security_decision.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Fake Repository
// -----------------------------------------------------------------------------
final class _FakeAuthorizationRepository
    implements CamoAuthorizationRepository {
  @override
  Future<CamoResult<CamoAuthorizationDecision>> authorizeOperation(
    CamoAuthorizationContext context,
  ) async {
    final DateTime now = DateTime.now();
    return CamoSuccess<CamoAuthorizationDecision>(
      CamoAuthorizationDecision(
        authorizationId: 'authorization-001',
        status: CamoAuthorizationStatus.allowed,
        securityDecision: CamoSecurityDecision.allow,
        reasonCode: 'authorized',
        issuedAt: now,
        expiresAt: now.add(const Duration(seconds: 30)),
      ),
    );
  }

  @override
  Future<CamoResult<void>> consumeAuthorization(String authorizationId) async {
    return const CamoSuccess<void>(null);
  }
}

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  test('use case delegates authorization to repository', () async {
    final AuthorizeCamoOperationUseCase useCase = AuthorizeCamoOperationUseCase(
      _FakeAuthorizationRepository(),
    );
    final CamoAuthorizationContext context = CamoAuthorizationContext(
      operationId: 'operation-001',
      userId: 'user-001',
      deviceId: 'device-001',
      operationType: CamoOperationType.decode,
      requestedAt: DateTime.now(),
      messageId: 'message-001',
    );
    final CamoResult<CamoAuthorizationDecision> result = await useCase(context);
    expect(result.isSuccess, isTrue);
    expect(result.valueOrNull?.permitsOperation, isTrue);
  });
}
