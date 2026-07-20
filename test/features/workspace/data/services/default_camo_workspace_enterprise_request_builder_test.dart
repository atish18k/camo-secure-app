import 'package:camo/core/licensing/domain/entities/camo_entitlement_type.dart';
import 'package:camo/core/message_lifecycle/domain/entities/camo_message_validity.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:camo/core/errors/result.dart';
import 'package:camo/features/auth/domain/repositories/auth_repository.dart';
import 'package:camo/features/policy/domain/repositories/camo_device_identity_service.dart';
import 'package:camo/features/workspace/data/services/default_camo_workspace_enterprise_request_builder.dart';
import 'package:camo/features/workspace/domain/services/camo_workspace_message_context_resolver.dart';
import 'package:camo/features/workspace/domain/services/camo_workspace_request_id_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime fixedTime = DateTime.utc(2026, 7, 12, 12);

  test('builds Standard CAMO encode request without Camouflage', () async {
    final DefaultCamoWorkspaceEnterpriseRequestBuilder builder =
        DefaultCamoWorkspaceEnterpriseRequestBuilder(
          authRepository: const _FakeAuthRepository(),
          deviceIdentityService: const _FakeDeviceIdentityService(),
          messageContextResolver: const _FakeMessageContextResolver(),
          requestIdGenerator: _FakeRequestIdGenerator(),
          clock: () => fixedTime,
        );

    final request = await builder.buildEncodeRequest(
      operationId: 'operation-001',
      pairingId: 'pairing-001',
      camouflageEnabled: false,
    );

    final authorization = request.authorizationRequest;

    expect(request.isValid, isTrue);
    expect(authorization.operationType, CamoOperationType.encode);
    expect(authorization.userId, 'user-001');
    expect(authorization.deviceId, 'device-001');
    expect(authorization.pairId, 'pairing-001');
    expect(authorization.messageId, isNotEmpty);
    expect(authorization.messageValidity, CamoMessageValidity.oneDay);
    expect(authorization.oneTimeView, isFalse);
    expect(authorization.payloadDigest, isNull);
    expect(authorization.requiredEntitlements, const <CamoEntitlementType>{
      CamoEntitlementType.baseEncoding,
    });
    expect(
      authorization.requiredEntitlements,
      isNot(contains(CamoEntitlementType.camouflage)),
    );
  });

  test('fails closed when Camouflage enters Standard CAMO builder', () async {
    final DefaultCamoWorkspaceEnterpriseRequestBuilder builder =
        DefaultCamoWorkspaceEnterpriseRequestBuilder(
          authRepository: const _FakeAuthRepository(),
          deviceIdentityService: const _FakeDeviceIdentityService(),
          messageContextResolver: const _FakeMessageContextResolver(),
          requestIdGenerator: _FakeRequestIdGenerator(),
          clock: () => fixedTime,
        );

    await expectLater(
      builder.buildEncodeRequest(
        operationId: 'operation-002',
        pairingId: 'pairing-001',
        camouflageEnabled: true,
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('builds decode request with authorized message reference', () async {
    final DefaultCamoWorkspaceEnterpriseRequestBuilder builder =
        DefaultCamoWorkspaceEnterpriseRequestBuilder(
          authRepository: const _FakeAuthRepository(),
          deviceIdentityService: const _FakeDeviceIdentityService(),
          messageContextResolver: const _FakeMessageContextResolver(
            messageId: 'message-001',
          ),
          requestIdGenerator: _FakeRequestIdGenerator(),
          clock: () => fixedTime,
        );

    final request = await builder.buildDecodeRequest(
      operationId: 'operation-003',
      pairingId: 'pairing-001',
    );

    final authorization = request.authorizationRequest;

    expect(authorization.operationType, CamoOperationType.decode);
    expect(authorization.messageId, 'message-001');
    expect(authorization.requiredEntitlements, const <CamoEntitlementType>{
      CamoEntitlementType.baseDecoding,
    });
  });

  test('fails closed when decode message reference is unavailable', () async {
    final DefaultCamoWorkspaceEnterpriseRequestBuilder builder =
        DefaultCamoWorkspaceEnterpriseRequestBuilder(
          authRepository: const _FakeAuthRepository(),
          deviceIdentityService: const _FakeDeviceIdentityService(),
          messageContextResolver: const _FakeMessageContextResolver(
            messageId: '',
          ),
          requestIdGenerator: _FakeRequestIdGenerator(),
          clock: () => fixedTime,
        );

    await expectLater(
      builder.buildDecodeRequest(
        operationId: 'operation-004',
        pairingId: 'pairing-001',
      ),
      throwsA(isA<StateError>()),
    );
  });
}

final class _FakeAuthRepository implements AuthRepository {
  const _FakeAuthRepository();

  @override
  bool get isSignedIn => true;

  @override
  String? get currentUserId => 'user-001';

  @override
  bool get isEmailVerified => false;

  @override
  String? get currentUserEmail => null;

  @override
  Future<Result<void>> createAccount({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<void> sendEmailVerification() => throw UnimplementedError();

  @override
  Future<void> reloadCurrentUser() => throw UnimplementedError();

  @override
  Future<void> deleteCurrentUser() => throw UnimplementedError();

  @override
  Future<Result<void>> signIn({
    required String email,
    required String password,
  }) => throw UnimplementedError();

  @override
  Future<Result<void>> signOut() => throw UnimplementedError();
}

final class _FakeDeviceIdentityService implements CamoDeviceIdentityService {
  const _FakeDeviceIdentityService();

  @override
  Future<String> getDeviceId() async => 'device-001';

  @override
  Future<void> deleteDeviceId() async {}
}

final class _FakeMessageContextResolver
    implements CamoWorkspaceMessageContextResolver {
  const _FakeMessageContextResolver({this.messageId = 'message-001'});

  final String messageId;

  @override
  Future<String> resolveMessageId({
    required String pairingId,
    required String operationId,
  }) async => messageId;
}

final class _FakeRequestIdGenerator implements CamoWorkspaceRequestIdGenerator {
  int _counter = 0;

  @override
  String generateOperationId() {
    _counter += 1;
    return 'operation-generated-$_counter';
  }

  @override
  String generateRequestId() {
    _counter += 1;
    return 'request-generated-$_counter';
  }
}
