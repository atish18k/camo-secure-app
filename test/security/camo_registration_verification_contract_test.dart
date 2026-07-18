import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'registration uses Firebase account creation and real email verification',
    () {
      final source = File(
        'lib/features/auth/data/datasources/auth_remote_datasource.dart',
      ).readAsStringSync();
      expect(source, contains('createUserWithEmailAndPassword'));
      expect(source, contains('sendEmailVerification'));
      expect(source, contains('user.reload()'));
    },
  );

  test('device registration is denied until email is verified', () {
    final login = File(
      'lib/features/auth/domain/usecases/login_usecase.dart',
    ).readAsStringSync();
    expect(
      login.indexOf('isEmailVerified'),
      lessThan(login.indexOf('submitCurrentDeviceRegistrationRequest')),
    );
    final splash = File(
      'lib/features/auth/domain/usecases/check_auth_status_usecase.dart',
    ).readAsStringSync();
    expect(splash, contains('isSignedIn && _repository.isEmailVerified'));
  });

  test('limited support acceptance is immutable and server timestamped', () {
    final repository = File(
      'lib/features/policy/data/repositories/firestore_camo_device_support_acceptance_repository.dart',
    ).readAsStringSync();
    final rules = File('firestore.rules').readAsStringSync();
    expect(repository, contains("doc('deviceSupportAcceptance')"));
    expect(repository, contains('FieldValue.serverTimestamp()'));
    expect(rules, contains("policyVersion == 'device-support-v1'"));
    expect(rules, contains('acceptedAt == request.time'));
    expect(rules, contains('allow update, delete: if false'));
  });

  test('profile sync preserves an existing CAMO identity', () {
    final source = File(
      'lib/features/profile/domain/usecases/create_user_profile_usecase.dart',
    ).readAsStringSync();
    expect(source, contains('final UserEntity? existing'));
    expect(source, contains('existing.copyWith'));
    expect(source, contains('_camoIdGenerator.generate()'));
  });

  test('passkey screen is honest while provider binding is unavailable', () {
    final source = File(
      'lib/features/auth/presentation/screens/passkey_setup_screen.dart',
    ).readAsStringSync();
    expect(
      source,
      contains('Passkey enrollment is not enabled in this build.'),
    );
    expect(source, contains('will not display a fake passkey success state'));
  });
}
