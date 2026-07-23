import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('P1-019 DI exposes the V2 authorization runtime only', () {
    final String source = File(
      'lib/core/di/injection_container.dart',
    ).readAsStringSync();

    const List<String> requiredV2Symbols = <String>[
      'CamoV2AuthorizationCallableClient',
      'CamoSignedAuthorizationContractV2Canonicalizer',
      'CamoSignedAuthorizationContractV2Verifier',
      'CamoSignedAuthorizationContractV2TransportDecoder',
    ];

    for (final String symbol in requiredV2Symbols) {
      expect(
        source,
        contains(symbol),
        reason: 'Required V2 DI symbol is missing: $symbol',
      );
    }

    const List<String> forbiddenOldSymbols = <String>[
      'CamoSignedAuthorizationContract'
          'V1Canonicalizer',
      'CamoSignedAuthorizationContract'
          'V1Verifier',
      'CamoSignedAuthorizationContract'
          'V1TransportDecoder',
      'CamoAuthorizationCallable'
          'Client',
    ];

    for (final String symbol in forbiddenOldSymbols) {
      expect(
        source,
        isNot(contains(symbol)),
        reason: 'Obsolete authorization residue remains in DI: $symbol',
      );
    }
  });
}
