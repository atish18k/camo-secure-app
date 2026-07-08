// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart' as app_result;
import '../../../pairing/security/device_key_manager.dart';
import '../../../profile/domain/entities/user_crypto_entity.dart';
import '../../../profile/domain/entities/user_entity.dart';
import '../../../profile/domain/repositories/profile_repository.dart';
import '../../../profile/domain/usecases/create_user_profile_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_state.dart';

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState.initial();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();

    try {
      final LoginUseCase loginUseCase = sl<LoginUseCase>();
      final AuthRepository authRepository = sl<AuthRepository>();
      final CreateUserProfileUseCase createUserProfileUseCase =
          sl<CreateUserProfileUseCase>();
      final DeviceKeyManager deviceKeyManager = sl<DeviceKeyManager>();
      final ProfileRepository profileRepository = sl<ProfileRepository>();

      final app_result.Result<void> result = await loginUseCase(
        email: email,
        password: password,
      );

      switch (result) {
        case app_result.Success<void>():
          await _syncUserProfile(
            authRepository: authRepository,
            createUserProfileUseCase: createUserProfileUseCase,
            deviceKeyManager: deviceKeyManager,
            profileRepository: profileRepository,
            fallbackEmail: email,
          );

        case app_result.Error<void>(failure: final Failure failure):
          state = AuthState.failure(failure);
      }
    } catch (error, stackTrace) {
      debugPrint('AUTH: Exception -> $error');
      debugPrintStack(stackTrace: stackTrace);

      state = const AuthState.failure(
        AuthFailure(
          message: 'Authentication failed. Please check your email and password.',
        ),
      );
    }
  }

  Future<void> _syncUserProfile({
    required AuthRepository authRepository,
    required CreateUserProfileUseCase createUserProfileUseCase,
    required DeviceKeyManager deviceKeyManager,
    required ProfileRepository profileRepository,
    required String fallbackEmail,
  }) async {
    final String? currentUserId = authRepository.currentUserId;

    if (currentUserId == null) {
      state = const AuthState.failure(
        AuthFailure(
          message: 'Login succeeded but user data was not found.',
        ),
      );
      return;
    }

    try {
      await createUserProfileUseCase(
        UserEntity(
          uid: currentUserId,
          camoId: '',
          email: fallbackEmail.trim(),
          displayName: 'CAMO User',
          photoUrl: null,
          createdAt: DateTime.now(),
        ),
      );

      var keyPair = await deviceKeyManager.loadKeyPair();

      if (keyPair == null) {
        keyPair = await deviceKeyManager.createKeyPair();
        await deviceKeyManager.saveKeyPair(keyPair);
      }

      final DateTime now = DateTime.now().toUtc();

      await profileRepository.saveUserCrypto(
        uid: currentUserId,
        crypto: UserCryptoEntity(
          publicKey: base64Encode(keyPair.publicKey),
          algorithm: 'X25519',
          version: 1,
          createdAt: now,
          updatedAt: now,
        ),
      );

      state = const AuthState.authenticated();
    } catch (error, stackTrace) {
      debugPrint('PROFILE: Sync exception -> $error');
      debugPrintStack(stackTrace: stackTrace);

      state = const AuthState.failure(
        AuthFailure(
          message: 'Profile sync failed. Check Firestore database/rules.',
        ),
      );
    }
  }
}