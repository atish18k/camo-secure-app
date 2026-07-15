// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

import '../../core/crypto/cache/camo_key_cache.dart';
import '../../core/crypto/cache/camo_memory_key_cache.dart';
import '../../core/crypto/encryption/camo_aes_gcm_engine.dart';
import '../../core/crypto/encryption/camo_crypto_engine.dart';
import '../../core/crypto/encryption/camo_crypto_facade.dart';
import '../../core/crypto/encryption/camo_hkdf_key_derivation.dart';
import '../../core/crypto/encryption/camo_key_agreement.dart';
import '../../core/crypto/encryption/camo_key_derivation.dart';
import '../../core/crypto/encryption/camo_message_crypto_service.dart';
import '../../core/crypto/encryption/camo_nonce_generator.dart';
import '../../core/crypto/encryption/camo_payload_formatter.dart';
import '../../core/crypto/encryption/camo_secure_nonce_generator.dart';
import '../../core/crypto/encryption/camo_secure_random.dart';
import '../../core/crypto/encryption/camo_x25519_key_agreement.dart';
import '../../core/crypto/keys/camo_remote_device_resolver.dart';
import '../../core/crypto/keys/camo_remote_public_key_provider.dart';
import '../../core/crypto/keys/firestore_remote_public_key_provider.dart';
import '../../core/crypto/trust/camo_local_device_trust_guard.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/check_auth_status_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_id_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';

import '../../features/pairing/data/datasources/pairing_remote_datasource.dart';
import '../../features/pairing/data/repositories/pairing_repository_impl.dart';
import '../../features/pairing/domain/repositories/pairing_repository.dart';
import '../../features/pairing/domain/usecases/accept_pair_request_usecase.dart';
import '../../features/pairing/domain/usecases/create_pairing_usecase.dart';
import '../../features/pairing/domain/usecases/delete_pairing_usecase.dart';
import '../../features/pairing/domain/usecases/find_pairing_user_usecase.dart';
import '../../features/pairing/domain/usecases/get_pairing_between_users_usecase.dart';
import '../../features/pairing/domain/usecases/get_pairing_usecase.dart';
import '../../features/pairing/domain/usecases/reject_pair_request_usecase.dart';
import '../../features/pairing/domain/usecases/watch_accepted_pairings_usecase.dart';
import '../../features/pairing/domain/usecases/watch_pending_pair_requests_usecase.dart';
import '../../features/pairing/security/device_key_manager.dart';
import '../../features/pairing/security/flutter_secure_device_key_manager.dart';

import '../../features/payload/data/parsers/camo_compact_payload_parser.dart';
import '../../features/payload/data/serializers/camo_compact_payload_serializer.dart';
import '../../features/payload/domain/repositories/camo_payload_parser.dart';
import '../../features/payload/domain/repositories/camo_payload_serializer.dart';

import '../../features/policy/data/datasources/camo_device_registry_remote_datasource.dart';
import '../../features/policy/data/datasources/camo_message_policy_remote_datasource.dart';
import '../../features/policy/data/repositories/camo_device_identity_service_impl.dart';
import '../../features/policy/data/repositories/camo_device_registration_service_impl.dart';
import '../../features/policy/data/repositories/camo_device_registry_repository_impl.dart';
import '../../features/policy/data/repositories/firestore_remote_device_resolver.dart';
import '../../features/policy/data/repositories/realtime_local_device_trust_guard.dart';
import '../../features/policy/data/repositories/camo_message_policy_service_impl.dart';
import '../../features/policy/data/repositories/camo_policy_evaluator_impl.dart';
import '../../features/policy/data/repositories/camo_secure_device_id_generator.dart';
import '../../features/policy/data/repositories/flutter_camo_platform_info_provider.dart';
import '../../features/policy/domain/repositories/camo_device_id_generator.dart';
import '../../features/policy/domain/repositories/camo_device_identity_service.dart';
import '../../features/policy/domain/repositories/camo_device_registration_service.dart';
import '../../features/policy/domain/repositories/camo_device_registry_repository.dart';
import '../../features/policy/domain/repositories/camo_message_policy_service.dart';
import '../../features/policy/domain/repositories/camo_platform_info_provider.dart';
import '../../features/policy/domain/repositories/camo_policy_evaluator.dart';
import '../../features/policy/domain/usecases/evaluate_camo_policy_usecase.dart';

import '../../core/authorization_gateway/data/repositories/fail_closed_camo_single_use_authorization_store.dart';
import '../../core/authorization_gateway/data/services/default_camo_authorization_response_acceptance_service.dart';
import '../../core/authorization_gateway/data/services/default_camo_authorization_response_canonicalizer.dart';
import '../../core/authorization_gateway/data/services/default_camo_signed_authorization_response_service.dart';
import '../../core/authorization_gateway/data/services/default_camo_single_use_authorization_artifact_factory.dart';
import '../../core/authorization_gateway/data/services/default_camo_single_use_authorization_service.dart';
import '../../core/authorization_gateway/data/services/fail_closed_camo_authorization_gateway.dart';
import '../../core/authorization_gateway/data/services/fail_closed_camo_production_authorization_gateway_adapter.dart';
import '../../core/authorization_gateway/data/services/transport_backed_camo_production_authorization_gateway_adapter.dart';
import '../../core/authorization_gateway/data/services/fail_closed_camo_authorization_response_signature_verifier.dart';
import '../../core/authorization_gateway/domain/repositories/camo_single_use_authorization_store.dart';
import '../../core/authorization_gateway/domain/services/camo_authorization_gateway.dart';
import '../../core/authorization_gateway/domain/services/camo_production_authorization_gateway_adapter.dart';
import '../../core/authorization_gateway/domain/services/camo_authorization_response_acceptance_service.dart';
import '../../core/authorization_gateway/domain/services/camo_authorization_response_canonicalizer.dart';
import '../../core/authorization_gateway/domain/services/camo_authorization_response_signature_verifier.dart';
import '../../core/authorization_gateway/domain/services/camo_signed_authorization_response_service.dart';
import '../../core/authorization_gateway/domain/services/camo_single_use_authorization_artifact_factory.dart';
import '../../core/authorization_gateway/domain/services/camo_single_use_authorization_service.dart';
import '../../core/authorization_gateway/domain/services/camo_authorization_transport_mapper.dart';
import '../../core/authorization_gateway/domain/services/camo_authorization_transport.dart';
import '../../core/authorization_gateway/data/services/fail_closed_camo_authorization_transport.dart';
import '../../core/authorization_gateway/data/services/default_camo_authorization_transport_mapper.dart';
import '../../core/authorization_gateway/data/services/default_camo_authorization_gateway_switch.dart';
import '../../core/authorization_gateway/domain/services/camo_authorization_gateway_switch.dart';
import '../../core/operation_coordinator/data/services/default_camo_production_activation_guard.dart';
import '../../core/operation_coordinator/data/services/default_camo_production_activation_readiness_service.dart';
import '../../core/operation_coordinator/data/services/fail_closed_camo_production_readiness_probe.dart';
import '../../core/operation_coordinator/domain/services/camo_production_activation_guard.dart';
import '../../core/operation_coordinator/domain/services/camo_production_activation_readiness_service.dart';
import '../../core/operation_coordinator/domain/services/camo_production_readiness_probe.dart';
import '../../core/authorization_gateway/data/services/default_camo_production_authorization_gateway_resolver.dart';
import '../../core/authorization_gateway/domain/services/camo_production_authorization_gateway_resolver.dart';
import '../../core/operation_coordinator/domain/services/camo_authorized_operation_executor.dart';
import '../../features/workspace/domain/services/camo_workspace_crypto_port.dart';
import '../../features/workspace/domain/repositories/camo_workspace_operation_payload_store.dart';
import '../../features/workspace/data/services/default_camo_authorized_operation_executor.dart';
import '../../features/workspace/data/services/camo_crypto_facade_workspace_port.dart';
import '../../features/workspace/data/repositories/camo_memory_workspace_operation_payload_store.dart';
import '../../features/workspace/data/services/fail_closed_camo_authorized_workspace_service.dart';
import '../../features/workspace/domain/services/camo_authorized_workspace_service.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/create_user_profile_usecase.dart';
import '../../features/profile/domain/usecases/get_user_by_camo_id_usecase.dart';
import '../../features/profile/domain/usecases/get_user_profile_usecase.dart';

import '../../services/identity/camo_id_generator.dart';
import '../../services/secure_storage/flutter_secure_storage_service.dart';
import '../../services/secure_storage/secure_storage_service.dart';

import '../../core/authorization/data/services/fail_closed_camo_enterprise_authorization_service.dart';
import '../../core/authorization/domain/services/camo_enterprise_authorization_service.dart';
import '../../features/workspace/data/services/fail_closed_camo_workspace_message_context_resolver.dart';
import '../../features/workspace/domain/services/camo_workspace_message_context_resolver.dart';
import '../../features/workspace/data/services/secure_camo_workspace_request_id_generator.dart';
import '../../features/workspace/domain/services/camo_workspace_request_id_generator.dart';
import '../../core/kms/data/repositories/fail_closed_camo_kms_repository.dart';
import '../../core/kms/domain/repositories/camo_kms_repository.dart';
import '../../core/operation_coordinator/domain/services/default_camo_enterprise_operation_coordinator.dart';
import '../../features/workspace/data/services/default_camo_workspace_enterprise_request_builder.dart';
import '../../features/workspace/data/services/coordinator_backed_camo_authorized_workspace_service.dart';
import '../../core/operation_coordinator/data/services/fail_closed_camo_enterprise_security_pipeline_ports.dart';
import '../../core/operation_coordinator/domain/services/camo_enterprise_security_pipeline_ports.dart';
import '../../core/operation_coordinator/domain/services/default_camo_enterprise_security_pipeline.dart';
import '../../core/authorization/data/services/default_camo_enterprise_authorization_operation_request_mapper.dart';
import '../../core/authorization/data/services/fail_closed_camo_authorization_pipeline_decision_factory.dart';
import '../../core/authorization/data/services/pipeline_backed_camo_enterprise_authorization_service.dart';
import '../../core/authorization/domain/services/camo_authorization_pipeline_decision_factory.dart';
import '../../core/authorization/domain/services/camo_enterprise_authorization_operation_request_mapper.dart';
// ---------------------------------------------------------------------------
// Service Locator
// ---------------------------------------------------------------------------

final sl = GetIt.instance;

// ---------------------------------------------------------------------------
// Init Dependencies
// ---------------------------------------------------------------------------

Future<void> initDependencies() async {
  // ---------------------------------------------------------------------------
  // External
  // ---------------------------------------------------------------------------

  sl.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);

  sl.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);

  sl.registerLazySingleton<FlutterSecureStorage>(FlutterSecureStorage.new);

  // ---------------------------------------------------------------------------
  // Core Services
  // ---------------------------------------------------------------------------

  sl.registerLazySingleton<CamoIdGenerator>(CamoIdGenerator.new);

  sl.registerLazySingleton<SecureStorageService>(
    () => FlutterSecureStorageService(sl()),
  );

  sl.registerLazySingleton<CamoSecureRandom>(CamoSecureRandom.new);

  sl.registerLazySingleton<CamoKeyCache>(CamoMemoryKeyCache.new);

  sl.registerLazySingleton<DeviceKeyManager>(
    () => FlutterSecureDeviceKeyManager(sl(), sl()),
  );

  sl.registerLazySingleton<CamoNonceGenerator>(
    () => CamoSecureNonceGenerator(sl()),
  );

  sl.registerLazySingleton<CamoCryptoEngine>(CamoAesGcmEngine.new);

  sl.registerLazySingleton<CamoKeyAgreement>(CamoX25519KeyAgreement.new);

  sl.registerLazySingleton<CamoKeyDerivation>(CamoHkdfKeyDerivation.new);
  sl.registerLazySingleton<CamoRemotePublicKeyProvider>(
    () => FirestoreRemotePublicKeyProvider(sl()),
  );

  sl.registerLazySingleton<CamoPayloadSerializer>(
    CamoCompactPayloadSerializer.new,
  );

  sl.registerLazySingleton<CamoPayloadParser>(CamoCompactPayloadParser.new);

  sl.registerLazySingleton<CamoPayloadFormatter>(CamoPayloadFormatter.new);

  sl.registerLazySingleton<CamoMessageCryptoService>(
    () => CamoMessageCryptoService(
      cryptoEngine: sl(),
      nonceGenerator: sl(),
      payloadFormatter: sl(),
      payloadSerializer: sl(),
      payloadParser: sl(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Device Identity and Registration
  // ---------------------------------------------------------------------------

  sl.registerLazySingleton<CamoDeviceIdGenerator>(
    CamoSecureDeviceIdGenerator.new,
  );

  sl.registerLazySingleton<CamoDeviceIdentityService>(
    () => CamoDeviceIdentityServiceImpl(sl(), sl()),
  );

  sl.registerLazySingleton<CamoPlatformInfoProvider>(
    FlutterCamoPlatformInfoProvider.new,
  );

  sl.registerLazySingleton<CamoDeviceRegistrationService>(
    () => CamoDeviceRegistrationServiceImpl(
      sl(),
      sl(),
      sl(),
      sl(),
      sl(),
      sl<CamoDeviceIdGenerator>().generate,
    ),
  );

  // ---------------------------------------------------------------------------
  // Policy
  // ---------------------------------------------------------------------------

  sl.registerLazySingleton<CamoPolicyEvaluator>(CamoPolicyEvaluatorImpl.new);

  sl.registerLazySingleton<EvaluateCamoPolicyUseCase>(
    () => EvaluateCamoPolicyUseCase(sl()),
  );

  sl.registerLazySingleton<CamoMessagePolicyService>(
    () => CamoMessagePolicyServiceImpl(sl()),
  );

  // ---------------------------------------------------------------------------
  // Data Sources
  // ---------------------------------------------------------------------------

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => FirebaseAuthRemoteDataSource(sl()),
  );

  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => FirebaseProfileRemoteDataSource(sl()),
  );

  sl.registerLazySingleton<PairingRemoteDataSource>(
    () => FirebasePairingRemoteDataSource(sl()),
  );

  sl.registerLazySingleton<CamoDeviceRegistryRemoteDataSource>(
    () => FirebaseCamoDeviceRegistryRemoteDataSource(sl()),
  );

  sl.registerLazySingleton<CamoMessagePolicyRemoteDataSource>(
    () => FirebaseCamoMessagePolicyRemoteDataSource(sl()),
  );

  // ---------------------------------------------------------------------------
  // Repositories
  // ---------------------------------------------------------------------------

  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<PairingRepository>(
    () => PairingRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<CamoDeviceRegistryRepository>(
    () => CamoDeviceRegistryRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<CamoRemoteDeviceResolver>(
    () => FirestoreRemoteDeviceResolver(sl()),
  );

  sl.registerLazySingleton<CamoLocalDeviceTrustGuard>(
    () => RealtimeLocalDeviceTrustGuard(sl(), sl(), sl(), sl()),
  );

  sl.registerLazySingleton<CamoCryptoFacade>(
    () => CamoCryptoFacade(
      authRepository: sl(),
      pairingRepository: sl(),
      deviceKeyManager: sl(),
      keyAgreement: sl(),
      keyDerivation: sl(),
      keyCache: sl(),
      localDeviceTrustGuard: sl(),
      remotePublicKeyProvider: sl(),
      messageCryptoService: sl(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Auth Use Cases
  // ---------------------------------------------------------------------------

  sl.registerLazySingleton<LoginUseCase>(() => LoginUseCase(sl(), sl()));

  sl.registerLazySingleton<CheckAuthStatusUseCase>(
    () => CheckAuthStatusUseCase(sl()),
  );

  sl.registerLazySingleton<GetCurrentUserIdUseCase>(
    () => GetCurrentUserIdUseCase(sl()),
  );

  // ---------------------------------------------------------------------------
  // Profile Use Cases
  // ---------------------------------------------------------------------------

  sl.registerLazySingleton<CreateUserProfileUseCase>(
    () => CreateUserProfileUseCase(sl(), sl()),
  );

  sl.registerLazySingleton<GetUserProfileUseCase>(
    () => GetUserProfileUseCase(sl()),
  );

  sl.registerLazySingleton<GetUserByCamoIdUseCase>(
    () => GetUserByCamoIdUseCase(sl()),
  );

  // ---------------------------------------------------------------------------
  // Pairing Use Cases
  // ---------------------------------------------------------------------------

  sl.registerLazySingleton<CreatePairingUseCase>(
    () => CreatePairingUseCase(sl()),
  );

  sl.registerLazySingleton<GetPairingUseCase>(() => GetPairingUseCase(sl()));

  sl.registerLazySingleton<GetPairingBetweenUsersUseCase>(
    () => GetPairingBetweenUsersUseCase(sl()),
  );

  sl.registerLazySingleton<WatchPendingPairRequestsUseCase>(
    () => WatchPendingPairRequestsUseCase(sl()),
  );

  sl.registerLazySingleton<WatchAcceptedPairingsUseCase>(
    () => WatchAcceptedPairingsUseCase(sl()),
  );

  sl.registerLazySingleton<AcceptPairRequestUseCase>(
    () => AcceptPairRequestUseCase(sl()),
  );

  sl.registerLazySingleton<RejectPairRequestUseCase>(
    () => RejectPairRequestUseCase(sl()),
  );

  sl.registerLazySingleton<DeletePairingUseCase>(
    () => DeletePairingUseCase(sl()),
  );

  sl.registerLazySingleton<FindPairingUserUseCase>(
    () => FindPairingUserUseCase(sl()),
  );
  // ---------------------------------------------------------------------------
  // Authorized Workspace Execution Boundary
  // ---------------------------------------------------------------------------
  // ---------------------------------------------------------------------------
  // Authorized Crypto Executor Infrastructure
  // ---------------------------------------------------------------------------
  // ---------------------------------------------------------------------------
  // Authorization Gateway Security Boundary
  // ---------------------------------------------------------------------------

  sl.registerLazySingleton<CamoAuthorizationTransportMapper>(
    DefaultCamoAuthorizationTransportMapper.new,
  );

  sl.registerLazySingleton<CamoAuthorizationTransport>(
    FailClosedCamoAuthorizationTransport.new,
  );
  sl.registerLazySingleton<CamoAuthorizationResponseCanonicalizer>(
    DefaultCamoAuthorizationResponseCanonicalizer.new,
  );

  sl.registerLazySingleton<CamoAuthorizationResponseSignatureVerifier>(
    FailClosedCamoAuthorizationResponseSignatureVerifier.new,
  );

  sl.registerLazySingleton<CamoSignedAuthorizationResponseService>(
    () => DefaultCamoSignedAuthorizationResponseService(
      canonicalizer: sl(),
      verifier: sl(),
    ),
  );

  sl.registerLazySingleton<CamoSingleUseAuthorizationStore>(
    FailClosedCamoSingleUseAuthorizationStore.new,
  );

  sl.registerLazySingleton<CamoSingleUseAuthorizationService>(
    () => DefaultCamoSingleUseAuthorizationService(
      store: sl(),
      clock: DateTime.now,
    ),
  );

  sl.registerLazySingleton<CamoAuthorizationResponseAcceptanceService>(
    () => DefaultCamoAuthorizationResponseAcceptanceService(
      singleUseService: sl(),
    ),
  );

  sl.registerLazySingleton<CamoSingleUseAuthorizationArtifactFactory>(
    DefaultCamoSingleUseAuthorizationArtifactFactory.new,
  );
  sl.registerLazySingleton<CamoProductionReadinessProbe>(
    FailClosedCamoProductionReadinessProbe.new,
  );

  sl.registerLazySingleton<CamoProductionActivationReadinessService>(
    () => DefaultCamoProductionActivationReadinessService(probe: sl()),
  );

  sl.registerLazySingleton<CamoProductionActivationGuard>(
    () => DefaultCamoProductionActivationGuard(readinessService: sl()),
  );

  sl.registerLazySingleton<CamoAuthorizationGatewaySwitch>(
    () => DefaultCamoAuthorizationGatewaySwitch(activationGuard: sl()),
  );
  sl.registerLazySingleton<CamoProductionAuthorizationGatewayResolver>(
    () => DefaultCamoProductionAuthorizationGatewayResolver(
      gatewaySwitch: sl(),
      failClosedGateway: sl<CamoAuthorizationGateway>(),
    ),
  );
  sl.registerLazySingleton<CamoProductionAuthorizationGatewayAdapter>(
    FailClosedCamoProductionAuthorizationGatewayAdapter.new,
  );

  sl.registerLazySingleton<
    TransportBackedCamoProductionAuthorizationGatewayAdapter
  >(
    () => TransportBackedCamoProductionAuthorizationGatewayAdapter(
      transport: sl(),
      mapper: sl(),
      signedResponseService: sl(),
      artifactFactory: sl(),
      acceptanceService: sl(),
    ),
  );
  sl.registerLazySingleton<CamoAuthorizationGateway>(
    FailClosedCamoAuthorizationGateway.new,
  );

  sl.registerLazySingleton<CamoWorkspaceOperationPayloadStore>(
    CamoMemoryWorkspaceOperationPayloadStore.new,
  );

  sl.registerLazySingleton<CamoWorkspaceCryptoPort>(
    () => CamoCryptoFacadeWorkspacePort(sl()),
  );

  sl.registerLazySingleton<CamoAuthorizedOperationExecutor>(
    () => DefaultCamoAuthorizedOperationExecutor(
      payloadStore: sl(),
      cryptoPort: sl(),
      clock: DateTime.now,
    ),
  );
  sl.registerLazySingleton<CamoSecuritySessionCoordinatorPort>(
    FailClosedCamoSecuritySessionCoordinatorPort.new,
  );

  sl.registerLazySingleton<CamoAuthorizationGatewayCoordinatorPort>(
    FailClosedCamoAuthorizationGatewayCoordinatorPort.new,
  );

  sl.registerLazySingleton<CamoAuthorizationCoordinatorPort>(
    FailClosedCamoAuthorizationCoordinatorPort.new,
  );

  sl.registerLazySingleton<CamoPolicyCoordinatorPort>(
    FailClosedCamoPolicyCoordinatorPort.new,
  );

  sl.registerLazySingleton<CamoDeviceTrustCoordinatorPort>(
    FailClosedCamoDeviceTrustCoordinatorPort.new,
  );

  sl.registerLazySingleton<CamoRiskCoordinatorPort>(
    FailClosedCamoRiskCoordinatorPort.new,
  );

  sl.registerLazySingleton<CamoLicensingCoordinatorPort>(
    FailClosedCamoLicensingCoordinatorPort.new,
  );

  sl.registerLazySingleton<CamoKmsCoordinatorPort>(
    FailClosedCamoKmsCoordinatorPort.new,
  );

  sl.registerLazySingleton<CamoAuditCoordinatorPort>(
    FailClosedCamoAuditCoordinatorPort.new,
  );

  sl.registerLazySingleton<DefaultCamoEnterpriseSecurityPipeline>(
    () => DefaultCamoEnterpriseSecurityPipeline(
      securitySessionPort: sl(),
      authorizationGatewayPort: sl(),
      authorizationPort: sl(),
      policyPort: sl(),
      deviceTrustPort: sl(),
      riskPort: sl(),
      licensingPort: sl(),
      kmsPort: sl(),
      auditPort: sl(),
      clock: DateTime.now,
      authorizationReferenceGenerator:
          sl<CamoWorkspaceRequestIdGenerator>().generateRequestId,
    ),
  );
  sl.registerLazySingleton<DefaultCamoEnterpriseOperationCoordinator>(
    () => DefaultCamoEnterpriseOperationCoordinator(
      authorizationService:
          sl<PipelineBackedCamoEnterpriseAuthorizationService>(),
      kmsRepository: sl(),
      executor: sl(),
    ),
  );

  sl.registerLazySingleton<CamoEnterpriseAuthorizationOperationRequestMapper>(
    () => DefaultCamoEnterpriseAuthorizationOperationRequestMapper(
      requestIdGenerator:
          sl<CamoWorkspaceRequestIdGenerator>().generateRequestId,
      clock: DateTime.now,
    ),
  );

  sl.registerLazySingleton<CamoAuthorizationPipelineDecisionFactory>(
    FailClosedCamoAuthorizationPipelineDecisionFactory.new,
  );

  sl.registerLazySingleton<PipelineBackedCamoEnterpriseAuthorizationService>(
    () => PipelineBackedCamoEnterpriseAuthorizationService(
      pipeline: sl<DefaultCamoEnterpriseSecurityPipeline>(),
      requestMapper: sl(),
      decisionFactory: sl(),
    ),
  );
  sl.registerLazySingleton<CamoEnterpriseAuthorizationService>(
    FailClosedCamoEnterpriseAuthorizationService.new,
  );
  sl.registerLazySingleton<CamoKmsRepository>(FailClosedCamoKmsRepository.new);

  sl.registerLazySingleton<CamoWorkspaceMessageContextResolver>(
    FailClosedCamoWorkspaceMessageContextResolver.new,
  );

  sl.registerLazySingleton<CamoWorkspaceRequestIdGenerator>(
    SecureCamoWorkspaceRequestIdGenerator.new,
  );

  sl.registerLazySingleton<DefaultCamoWorkspaceEnterpriseRequestBuilder>(
    () => DefaultCamoWorkspaceEnterpriseRequestBuilder(
      authRepository: sl(),
      deviceIdentityService: sl(),
      messageContextResolver: sl(),
      requestIdGenerator: sl(),
      clock: DateTime.now,
    ),
  );
  sl.registerLazySingleton<CoordinatorBackedCamoAuthorizedWorkspaceService>(
    () => CoordinatorBackedCamoAuthorizedWorkspaceService(
      coordinator: sl<DefaultCamoEnterpriseOperationCoordinator>(),
      requestBuilder: sl<DefaultCamoWorkspaceEnterpriseRequestBuilder>(),
      payloadStore: sl(),
      operationIdGenerator:
          sl<CamoWorkspaceRequestIdGenerator>().generateOperationId,
    ),
  );
  sl.registerLazySingleton<CamoAuthorizedWorkspaceService>(
    FailClosedCamoAuthorizedWorkspaceService.new,
  );
}
