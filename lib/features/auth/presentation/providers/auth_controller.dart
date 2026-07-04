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
      final loginUseCase = sl<LoginUseCase>();
      final authRepository = sl<AuthRepository>();
      final createUserProfileUseCase = sl<CreateUserProfileUseCase>();

      final result = await loginUseCase(
        email: email,
        password: password,
      );

      switch (result) {
        case app_result.Success<void>():
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
  email: user.email ?? email,
  displayName: user.displayName,
  photoUrl: user.photoURL,
  createdAt: DateTime.now(),
),
            );
          } catch (e, stackTrace) {
            debugPrint('PROFILE: Sync exception -> $e');
            debugPrintStack(stackTrace: stackTrace);

            state = const AuthState.failure(
              AuthFailure(
                message: 'Profile sync failed. Check Firestore database/rules.',
              ),
            );
            return;
          }

          state = const AuthState.authenticated();

        case app_result.Error<void>(failure: final failure):
          state = AuthState.failure(failure);
      }
    } catch (e, stackTrace) {
      debugPrint('AUTH: Exception -> $e');
      debugPrintStack(stackTrace: stackTrace);

      state = const AuthState.failure(
        AuthFailure(
          message: 'Authentication failed. Please check your email and password.',
        ),
      );
    }
  }
}