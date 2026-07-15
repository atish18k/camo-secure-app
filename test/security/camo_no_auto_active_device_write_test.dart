import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('login never calls the legacy auto-active registration method', () {
    final source = File(
      'lib/features/auth/domain/usecases/login_usecase.dart',
    ).readAsStringSync();
    expect(source, contains('submitCurrentDeviceRegistrationRequest()'));
    expect(source, isNot(contains('.registerCurrentDevice()')));
  });

  test('new registration path submits pending request facts only', () {
    final service = File(
      'lib/features/policy/data/repositories/camo_device_registration_service_impl.dart',
    ).readAsStringSync();
    expect(service, contains('CamoDeviceRegistrationRequestModel('));
    expect(service, contains('submitRegistrationRequest('));
    final method = service
        .split('submitCurrentDeviceRegistrationRequest() async {')[1]
        .split('Existing Registration Validation')[0];
    expect(method, isNot(contains('CamoDeviceStatus.active')));
    expect(method, isNot(contains('registerDevice(')));
  });

  test('datasource writes the pending registration request collection', () {
    final source = File(
      'lib/features/policy/data/datasources/camo_device_registry_remote_datasource.dart',
    ).readAsStringSync();
    expect(source, contains('deviceRegistrationRequests'));
    expect(source, contains('request.toMap()'));
    expect(source, contains('SetOptions(merge: false)'));
  });
}
