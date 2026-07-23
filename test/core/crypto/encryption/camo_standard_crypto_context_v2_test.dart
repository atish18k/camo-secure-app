import 'dart:convert';

import 'package:camo/core/crypto/encryption/camo_standard_crypto_context_v2.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('builds one canonical V2 context for Standard CAMO and UNCAMO', () {
    final List<int> context = CamoStandardCryptoContextV2.build(
      operationId: 'operation-1',
      messageId: 'message-1',
      pairingId: 'pair-1',
      authorizationId: 'authorization-1',
      challengeId: 'challenge-1',
    );

    expect(
      utf8.decode(context),
      'CAMO|standard-message|v2'
      '|operation-1'
      '|message-1'
      '|pair-1'
      '|authorization-1'
      '|challenge-1',
    );
  });

  test('rejects incomplete context instead of deriving a key', () {
    expect(
      () => CamoStandardCryptoContextV2.build(
        operationId: 'operation-1',
        messageId: '',
        pairingId: 'pair-1',
        authorizationId: 'authorization-1',
        challengeId: 'challenge-1',
      ),
      throwsStateError,
    );
  });
}
