import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/result.dart' as app_result;
import '../../domain/usecases/login_usecase.dart';
import 'auth_state.dart';

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);

class AuthController extends Notifier<AuthState> {
  late final LoginUseCase _loginUseCase;

  @override
  AuthState build() {
    _loginUseCase = sl<LoginUseCase>();
    return const AuthState.initial();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthState.loading();

    final result = await _loginUseCase(
      email: email,
      password: password,
    );

    switch (result) {
      case app_result.Success<void>():
        state = const AuthState.authenticated();

      case app_result.Error<void>(failure: final failure):
        state = AuthState.failure(failure);
    }
  }
}