// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart' as app_result;
import '../../../profile/domain/entities/user_entity.dart';
import '../../../profile/domain/usecases/create_user_profile_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_state.dart';

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

// ---------------------------------------------------------------------------
// Controller
// ---------------------------------------------------------------------------

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState.initial();
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthState.loading();

    try {
      final LoginUseCase loginUseCase = sl<LoginUseCase>();
      final AuthRepository authRepository = sl<AuthRepository>();
      final CreateUserProfileUseCase createUserProfileUseCase =
          sl<CreateUserProfileUseCase>();

      final app_result.Result<void> result = await loginUseCase(
        email: email,
        password: password,
      );

      switch (result) {
        case app_result.Success<void>():
          await _syncUserProfile(
            authRepository: authRepository,
            createUserProfileUseCase: createUserProfileUseCase,
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
          message:
              'Authentication failed. Please check your email and password.',
        ),
      );
    }
  }

  Future<void> _syncUserProfile({
    required AuthRepository authRepository,
    required CreateUserProfileUseCase createUserProfileUseCase,
    required String fallbackEmail,
  }) async {
    final String? currentUserId = authRepository.currentUserId;

    if (currentUserId == null || currentUserId.trim().isEmpty) {
      state = const AuthState.failure(
        AuthFailure(message: 'Login succeeded but user data was not found.'),
      );
      return;
    }

    try {
      await createUserProfileUseCase(
        UserEntity(
          uid: currentUserId.trim(),
          camoId: '',
          email: fallbackEmail.trim(),
          displayName: 'CAMO User',
          photoUrl: null,
          createdAt: DateTime.now(),
        ),
      );

      // Trusted-device registration and X25519 public-key publication are
      // handled exclusively by LoginUseCase through
      // CamoDeviceRegistrationService.
      //
      // Legacy profile crypto metadata is intentionally no longer written.

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
