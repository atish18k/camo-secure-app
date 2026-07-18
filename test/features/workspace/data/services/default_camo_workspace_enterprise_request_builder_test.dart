import 'package:camo/core/licensing/domain/entities/camo_entitlement_type.dart';
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

  test('builds base encode request without camouflage entitlement', () async {
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

    expect(
      authorization.requiredEntitlements,
      contains(CamoEntitlementType.baseEncoding),
    );

    expect(
      authorization.requiredEntitlements,
      isNot(contains(CamoEntitlementType.camouflage)),
    );
  });

  test('adds camouflage as a separate encode entitlement', () async {
    final DefaultCamoWorkspaceEnterpriseRequestBuilder builder =
        DefaultCamoWorkspaceEnterpriseRequestBuilder(
          authRepository: const _FakeAuthRepository(),
          deviceIdentityService: const _FakeDeviceIdentityService(),
          messageContextResolver: const _FakeMessageContextResolver(),
          requestIdGenerator: _FakeRequestIdGenerator(),
          clock: () => fixedTime,
        );

    final request = await builder.buildEncodeRequest(
      operationId: 'operation-002',
      pairingId: 'pairing-001',
      camouflageEnabled: true,
    );

    expect(
      request.authorizationRequest.requiredEntitlements,
      containsAll(<CamoEntitlementType>[
        CamoEntitlementType.baseEncoding,
        CamoEntitlementType.camouflage,
      ]),
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
      throwsA(
        isA<StateError>().having(
          (StateError error) => error.message,
          'message',
          'Authorized message reference is required for decoding.',
        ),
      ),
    );
  });

  test('fails closed when authenticated user is unavailable', () async {
    final DefaultCamoWorkspaceEnterpriseRequestBuilder builder =
        DefaultCamoWorkspaceEnterpriseRequestBuilder(
          authRepository: const _FakeAuthRepository(
            signedIn: false,
            userId: null,
          ),
          deviceIdentityService: const _FakeDeviceIdentityService(),
          messageContextResolver: const _FakeMessageContextResolver(),
          requestIdGenerator: _FakeRequestIdGenerator(),
          clock: () => fixedTime,
        );

    await expectLater(
      builder.buildEncodeRequest(
        operationId: 'operation-005',
        pairingId: 'pairing-001',
        camouflageEnabled: false,
      ),
      throwsA(isA<StateError>()),
    );
  });

  test('fails closed when device id is unavailable', () async {
    final DefaultCamoWorkspaceEnterpriseRequestBuilder builder =
        DefaultCamoWorkspaceEnterpriseRequestBuilder(
          authRepository: const _FakeAuthRepository(),
          deviceIdentityService: const _FakeDeviceIdentityService(deviceId: ''),
          messageContextResolver: const _FakeMessageContextResolver(),
          requestIdGenerator: _FakeRequestIdGenerator(),
          clock: () => fixedTime,
        );

    await expectLater(
      builder.buildEncodeRequest(
        operationId: 'operation-006',
        pairingId: 'pairing-001',
        camouflageEnabled: false,
      ),
      throwsA(isA<StateError>()),
    );
  });
}

final class _FakeAuthRepository implements AuthRepository {
  // Fake-only registration boundary; not exercised by this test.
  @override
  Future<Result<void>> createAccount({
    required String email,
    required String password,
  }) => throw UnsupportedError('createAccount is outside this test boundary.');

  @override
  Future<void> sendEmailVerification() => throw UnsupportedError(
    'Email verification is outside this test boundary.',
  );

  @override
  Future<void> reloadCurrentUser() =>
      throw UnsupportedError('User reload is outside this test boundary.');

  @override
  Future<void> deleteCurrentUser() =>
      throw UnsupportedError('User deletion is outside this test boundary.');

  @override
  bool get isEmailVerified => false;

  @override
  String? get currentUserEmail => null;
  const _FakeAuthRepository({this.signedIn = true, this.userId = 'user-001'});

  final bool signedIn;
  final String? userId;

  @override
  bool get isSignedIn => signedIn;

  @override
  String? get currentUserId => userId;

  @override
  Future<Result<void>> signIn({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<Result<void>> signOut() {
    throw UnimplementedError();
  }
}

final class _FakeDeviceIdentityService implements CamoDeviceIdentityService {
  const _FakeDeviceIdentityService({this.deviceId = 'device-001'});

  final String deviceId;

  @override
  Future<String> getDeviceId() async {
    return deviceId;
  }

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
  }) async {
    return messageId;
  }
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
