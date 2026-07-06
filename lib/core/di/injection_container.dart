// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/check_auth_status_usecase.dart';
import '../../features/auth/domain/usecases/get_current_user_id_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/pairing/data/datasources/pairing_remote_datasource.dart';
import '../../features/pairing/data/repositories/pairing_repository_impl.dart';
import '../../features/pairing/domain/repositories/pairing_repository.dart';
import '../../features/pairing/domain/usecases/create_pairing_usecase.dart';
import '../../features/pairing/domain/usecases/find_pairing_user_usecase.dart';
import '../../features/pairing/domain/usecases/get_pairing_usecase.dart';
import '../../features/profile/data/datasources/profile_remote_datasource.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/create_user_profile_usecase.dart';
import '../../features/profile/domain/usecases/get_user_by_camo_id_usecase.dart';
import '../../features/profile/domain/usecases/get_user_profile_usecase.dart';
import '../../services/identity/camo_id_generator.dart';
import '../../features/pairing/domain/usecases/accept_pair_request_usecase.dart';
import '../../features/pairing/domain/usecases/delete_pairing_usecase.dart';
import '../../features/pairing/domain/usecases/reject_pair_request_usecase.dart';

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

  // ---------------------------------------------------------------------------
  // Services
  // ---------------------------------------------------------------------------

  sl.registerLazySingleton<CamoIdGenerator>(
    CamoIdGenerator.new,
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