import 'package:camo/features/pairing/domain/services/qr_payload_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final parser = QrPayloadParser();
  test('accepts the exact canonical identity payload', () {
    final result = parser.parse('{"v":1,"t":"identity","id":"camo-123"}');
    expect(result.version, 1);
    expect(result.camoId, 'CAMO-123');
  });
  for (final value in <String>[
    '{"version":1,"type":"identity","identity":"CAMO-123"}',
    '{"v":1,"t":"identity","id":"CAMO-123","extra":true}',
    '{"v":"1","t":"identity","id":"CAMO-123"}',
    '{"v":1,"t":"message","id":"CAMO-123"}',
    '{"v":1,"t":"identity","id":"../secret"}',
    '[]',
    'not-json',
  ]) {
    test('rejects non-canonical payload: $value', () {
      expect(() => parser.parse(value), throwsFormatException);
    });
  }
}
