import 'package:camo/core/kms/data/repositories/fail_closed_camo_kms_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FailClosedCamoKmsRepository', () {
    const FailClosedCamoKmsRepository repository =
        FailClosedCamoKmsRepository();

    test('consumeKeyRelease rejects an empty release identifier', () async {
      final result = await repository.consumeKeyRelease('   ');

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.code, 'kms_release_id_invalid');
    });

    test('consumeKeyRelease fails closed for a valid identifier', () async {
      final result = await repository.consumeKeyRelease('release-001');

      expect(result.isFailure, isTrue);
      expect(
        result.failureOrNull?.code,
        'kms_key_release_consumption_unavailable',
      );
    });

    test('rotateKey rejects an empty key identifier', () async {
      final result = await repository.rotateKey('');

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.code, 'kms_key_id_invalid');
    });

    test('rotateKey fails closed for a valid key identifier', () async {
      final result = await repository.rotateKey('key-001');

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.code, 'kms_key_rotation_unavailable');
    });

    test('revokeKey rejects an empty reason code', () async {
      final result = await repository.revokeKey('key-001', ' ');

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.code, 'kms_revocation_reason_invalid');
    });

    test('revokeKey fails closed for valid parameters', () async {
      final result = await repository.revokeKey('key-001', 'security_rotation');

      expect(result.isFailure, isTrue);
      expect(result.failureOrNull?.code, 'kms_key_revocation_unavailable');
    });
  });
}
