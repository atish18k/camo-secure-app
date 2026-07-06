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

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  AuthState build() {
    return const AuthState.initial();
  }

  // ---------------------------------------------------------------------------
  // Public Methods
  // ---------------------------------------------------------------------------

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
          message: 'Authentication failed. Please check your email and password.',
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Private Methods
  // ---------------------------------------------------------------------------

  Future<void> _syncUserProfile({
    required AuthRepository authRepository,
    required CreateUserProfileUseCase createUserProfileUseCase,
    required String fallbackEmail,
  }) async {
    final user = authRepository.currentUser;

    if (user == null) {
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
          uid: user.uid,
          camoId: '',
          email: user.email ?? fallbackEmail,
          displayName: user.displayName ?? 'CAMO User',
          photoUrl: user.photoURL,
          createdAt: DateTime.now(),
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