import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart' as app_result;
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

      debugPrint('AUTH: Login started');

      final result = await loginUseCase(
        email: email,
        password: password,
      );

      switch (result) {
        case app_result.Success<void>():
          debugPrint('AUTH: Login successful');
          state = const AuthState.authenticated();

        case app_result.Error<void>(failure: final failure):
          debugPrint('AUTH: Login failed -> ${failure.message}');
          state = AuthState.failure(failure);
      }
    } catch (e, stackTrace) {
      debugPrint('AUTH: Exception -> $e');
      debugPrintStack(stackTrace: stackTrace);

      state = AuthState.failure(
        const AuthFailure(
          message: 'Authentication failed. Please check your email and password.',
        ),
      );
    }
  }
}