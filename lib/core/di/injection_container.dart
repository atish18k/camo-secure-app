// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

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
import '../../features/pairing/security/flutter_secure_pair_secret_manager.dart';
import '../../features/pairing/security/pair_secret_manager.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/create_user_profile_usecase.dart';
import '../../features/profile/domain/usecases/get_user_by_camo_id_usecase.dart';
import '../../features/profile/domain/usecases/get_user_profile_usecase.dart';
import '../../services/identity/camo_id_generator.dart';
import '../../services/secure_storage/flutter_secure_storage_service.dart';
import '../../services/secure_storage/secure_storage_service.dart';

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

  sl.registerLazySingleton<FirebaseAuth>(
    () => FirebaseAuth.instance,
  );

  sl.registerLazySingleton<FirebaseFirestore>(
    () => FirebaseFirestore.instance,
  );

  sl.registerLazySingleton<FlutterSecureStorage>(
    FlutterSecureStorage.new,
  );

  // ---------------------------------------------------------------------------
  // Services
  // ---------------------------------------------------------------------------

  sl.registerLazySingleton<CamoIdGenerator>(
    CamoIdGenerator.new,
  );

  sl.registerLazySingleton<SecureStorageService>(
    () => FlutterSecureStorageService(sl()),
  );

  sl.registerLazySingleton<CamoSecureRandom>(
    CamoSecureRandom.new,
  );

  sl.registerLazySingleton<PairSecretManager>(
    () => FlutterSecurePairSecretManager(
      sl(),
      sl(),
    ),
  );

  sl.registerLazySingleton<DeviceKeyManager>(
    () => FlutterSecureDeviceKeyManager(
      sl(),
    ),
  );

  sl.registerLazySingleton<CamoNonceGenerator>(
    () => CamoSecureNonceGenerator(
      sl(),
    ),
  );

  sl.registerLazySingleton<CamoCryptoEngine>(
    CamoAesGcmEngine.new,
  );

  sl.registerLazySingleton<CamoKeyAgreement>(
    CamoX25519KeyAgreement.new,
  );

  sl.registerLazySingleton<CamoKeyDerivation>(
    CamoHkdfKeyDerivation.new,
  );

  sl.registerLazySingleton<CamoPayloadFormatter>(
    CamoPayloadFormatter.new,
  );

  sl.registerLazySingleton<CamoMessageCryptoService>(
    () => CamoMessageCryptoService(
      cryptoEngine: sl(),
      nonceGenerator: sl(),
      payloadFormatter: sl(),
    ),
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

  // ---------------------------------------------------------------------------
  // Repositories
  // ---------------------------------------------------------------------------

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<PairingRepository>(
    () => PairingRepositoryImpl(
      remoteDataSource: sl(),
    ),
  );

  sl.registerLazySingleton<CamoCryptoFacade>(
    () => CamoCryptoFacade(
      authRepository: sl(),
      pairingRepository: sl(),
      profileRepository: sl(),
      deviceKeyManager: sl(),
      keyAgreement: sl(),
      keyDerivation: sl(),
      messageCryptoService: sl(),
    ),
  );

  // ---------------------------------------------------------------------------
  // Auth Use Cases
  // ---------------------------------------------------------------------------

  sl.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(sl()),
  );

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
    () => CreateUserProfileUseCase(
      sl(),
      sl(),
    ),
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

  sl.registerLazySingleton<GetPairingUseCase>(
    () => GetPairingUseCase(sl()),
  );

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
}