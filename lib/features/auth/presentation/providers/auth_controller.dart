import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart' as app_result;
import '../../../policy/domain/entities/camo_device_support_acceptance.dart';
import '../../../policy/domain/repositories/camo_device_registration_service.dart';
import '../../../policy/domain/usecases/save_camo_device_support_acceptance_usecase.dart';
import '../../../profile/domain/entities/user_entity.dart';
import '../../../profile/domain/usecases/create_user_profile_usecase.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_state.dart';

final authControllerProvider = NotifierProvider<AuthController, AuthState>(
  AuthController.new,
);

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState.initial();

  Future<void> login({required String email, required String password}) async {
    state = const AuthState.loading();
    final AuthRepository repository = sl<AuthRepository>();
    try {
      final app_result.Result<void> result = await sl<LoginUseCase>()(
        email: email,
        password: password,
      );
      switch (result) {
        case app_result.Success<void>():
          await _saveProfile(repository.currentUserEmail ?? email, 'CAMO User');
          state = const AuthState.authenticated();
        case app_result.Error<void>(failure: final Failure failure):
          state = repository.isSignedIn && !repository.isEmailVerified
              ? const AuthState.awaitingEmailVerification()
              : AuthState.failure(failure);
      }
    } catch (_) {
      state = const AuthState.failure(
        AuthFailure(
          message:
              'Authentication failed. Please check your email and password.',
        ),
      );
    }
  }

  Future<void> createAccount({
    required String email,
    required String password,
    required String displayName,
    required CamoDeviceSupportAcceptance acceptance,
  }) async {
    state = const AuthState.loading();
    final AuthRepository repository = sl<AuthRepository>();
    final app_result.Result<void> result = await repository.createAccount(
      email: email,
      password: password,
    );
    switch (result) {
      case app_result.Error<void>(failure: final Failure failure):
        state = AuthState.failure(failure);
      case app_result.Success<void>():
        try {
          await sl<SaveCamoDeviceSupportAcceptanceUseCase>()(acceptance);
          await _saveProfile(email, displayName);
          await repository.sendEmailVerification();
          state = const AuthState.awaitingEmailVerification();
        } catch (_) {
          try {
            await repository.deleteCurrentUser();
          } catch (_) {
            await repository.signOut();
          }
          state = const AuthState.failure(
            AuthFailure(
              message:
                  'Account setup failed safely. Please try registration again.',
            ),
          );
        }
    }
  }

  Future<void> resendEmailVerification() async {
    try {
      await sl<AuthRepository>().sendEmailVerification();
      state = const AuthState.awaitingEmailVerification();
    } catch (_) {
      state = const AuthState.failure(
        AuthFailure(
          message: 'Verification email could not be sent. Please try again.',
        ),
      );
    }
  }

  Future<void> completeEmailVerification() async {
    state = const AuthState.loading();
    final AuthRepository repository = sl<AuthRepository>();
    try {
      await repository.reloadCurrentUser();
      if (!repository.isEmailVerified) {
        state = const AuthState.awaitingEmailVerification();
        return;
      }
      await sl<CamoDeviceRegistrationService>()
          .submitCurrentDeviceRegistrationRequest();
      await _saveProfile(repository.currentUserEmail ?? '', 'CAMO User');
      state = const AuthState.authenticated();
    } catch (_) {
      state = const AuthState.failure(
        AuthFailure(
          message: 'Verified session setup failed. No CAMO access was granted.',
        ),
      );
    }
  }

  Future<void> _saveProfile(String email, String displayName) async {
    final AuthRepository repository = sl<AuthRepository>();
    final String? uid = repository.currentUserId;
    if (uid == null || uid.trim().isEmpty) {
      throw StateError('Authenticated user data missing.');
    }
    await sl<CreateUserProfileUseCase>()(
      UserEntity(
        uid: uid.trim(),
        camoId: '',
        email: email.trim(),
        displayName: displayName.trim().isEmpty
            ? 'CAMO User'
            : displayName.trim(),
        photoUrl: null,
        createdAt: DateTime.now(),
      ),
    );
  }
}
