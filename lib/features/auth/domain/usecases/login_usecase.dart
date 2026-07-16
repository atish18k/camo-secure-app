import '../../../../core/errors/failure.dart';
import '../../../../core/errors/result.dart';
import '../../../policy/domain/repositories/camo_device_registration_service.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository, this._deviceRegistrationService);

  final AuthRepository _repository;
  final CamoDeviceRegistrationService _deviceRegistrationService;

  Future<Result<void>> call({
    required String email,
    required String password,
  }) async {
    final Result<void> authenticationResult = await _repository.signIn(
      email: email,
      password: password,
    );
    if (authenticationResult is Error<void>) return authenticationResult;

    try {
      await _deviceRegistrationService.submitCurrentDeviceRegistrationRequest();
      return const Success<void>(null);
    } catch (error) {
      await _repository.signOut();
      final String reason = switch (error) {
        StateError stateError => stateError.message.toString(),
        _ => error.toString(),
      };
      return Error<void>(
        DeviceRegistrationFailure(
          message: 'Secure device registration failed: $reason',
          cause: error,
        ),
      );
    }
  }
}
