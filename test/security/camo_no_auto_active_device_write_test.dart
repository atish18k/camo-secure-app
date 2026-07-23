import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('login never calls the removed auto-active registration method', () {
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
    expect(method, isNot(contains('updateLastSeen(')));
  });

  test('trusted-device parser and query are canonical-only', () {
    final model = File(
      'lib/features/policy/data/models/camo_device_registry_model.dart',
    ).readAsStringSync();
    final datasource = File(
      'lib/features/policy/data/datasources/camo_device_registry_remote_datasource.dart',
    ).readAsStringSync();
    expect(model, contains("case 'approved':"));
    expect(model, isNot(contains("case 'active':")));
    expect(model, isNot(contains("case 'blocked':")));
    expect(datasource, contains('CamoDeviceStatus.approved.name'));
  });
  test('datasource writes the pending registration request collection', () {
    final source = File(
      'lib/features/policy/data/datasources/camo_device_registry_remote_datasource.dart',
    ).readAsStringSync();
    expect(source, contains('deviceRegistrationRequests'));
    expect(source, contains('request.toMap()'));
    expect(source, contains('SetOptions(merge: false)'));
  });

  test('registration request identity is deterministic per device', () {
    final source = File(
      'lib/features/policy/data/repositories/camo_device_registration_service_impl.dart',
    ).readAsStringSync();
    final rules = File('firestore.rules').readAsStringSync();
    expect(source, contains('requestId: deviceId'));
    expect(source, isNot(contains('requestId: generator()')));
    expect(rules, contains("resource.data.status == 'approved'"));
    expect(rules, contains("hasOnly(['requestedAt'])"));
    expect(rules, contains('allow create, update, delete: if false;'));
  });
}
