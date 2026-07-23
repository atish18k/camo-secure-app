import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('decode requires verified V2 runtime and permit carrier', () {
    final String source = File(
      'lib/features/workspace/data/services/'
      'default_camo_authorized_operation_executor.dart',
    ).readAsStringSync();

    expect(source, contains('CamoVerifiedV2UncamoRuntime? runtime'));
    expect(source, contains('!context.hasVerifiedV2Permit'));
    expect(source, contains('verified_v2_uncamo_runtime_unavailable'));
  });

  test('decode forwards exact bindings to verified runtime', () {
    final String source = File(
      'lib/features/workspace/data/services/'
      'default_camo_authorized_operation_executor.dart',
    ).readAsStringSync();

    expect(source, contains('requestId: context.request.requestId'));
    expect(source, contains('operationId: operationId'));
    expect(source, contains('messageId: messageId'));
    expect(source, contains('pairingId: pairingId'));
    expect(source, contains('encodedText: payload.encodedText!'));
  });

  test('decode branch has no alternate crypto-port path', () {
    final String source = File(
      'lib/features/workspace/data/services/'
      'default_camo_authorized_operation_executor.dart',
    ).readAsStringSync();

    final int start = source.indexOf(
      'payload.operationType == CamoOperationType.decode',
    );
    final int end = source.indexOf('} else {', start);
    final String branch = source.substring(start, end);

    expect(branch, contains('runtime.decrypt('));
    expect(branch, isNot(contains('_cryptoPort.decode(')));
    expect(branch, isNot(contains('decodeForPair')));
  });

  test('encode remains on existing workspace crypto port', () {
    final String source = File(
      'lib/features/workspace/data/services/'
      'default_camo_authorized_operation_executor.dart',
    ).readAsStringSync();

    expect(source, contains('output = await _cryptoPort.encode('));
  });

  test('DI registers and injects verified V2 UNCAMO runtime', () {
    final String source = File(
      'lib/core/di/injection_container.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('sl.registerLazySingleton<CamoDecodeKeyMaterialProvider>'),
    );
    expect(
      source,
      contains('sl.registerLazySingleton<CamoVerifiedV2UncamoRuntime>'),
    );
    expect(source, contains('permitStore: sl()'));
    expect(source, contains('keyMaterialProvider: sl()'));
    expect(source, contains('verifiedV2UncamoRuntime: sl()'));
  });

  test('enterprise authorization remains fail closed', () {
    final String source = File(
      'lib/core/di/injection_container.dart',
    ).readAsStringSync();

    expect(
      source,
      contains('FailClosedCamoAuthorizationGatewayCoordinatorPort'),
    );
    expect(
      source,
      contains('FailClosedCamoAuthorizationPipelineDecisionFactory'),
    );
  });
}
