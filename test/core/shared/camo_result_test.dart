// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/shared/failures/camo_failure.dart';
import 'package:camo/core/shared/result/camo_result.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  group('CamoResult', () {
    test('success exposes value and executes success branch', () {
      const CamoResult<String> result = CamoSuccess<String>('CAMO');
      final String output = result.fold(
        onSuccess: (String value) => value,
        onFailure: (CamoFailure failure) => failure.message,
      );
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.valueOrNull, 'CAMO');
      expect(result.failureOrNull, isNull);
      expect(output, 'CAMO');
    });
    test('failure exposes failure and executes failure branch', () {
      const CamoFailure failure = CamoSecurityFailure(
        code: 'authorization_denied',
        message: 'Authorization denied.',
      );
      const CamoResult<String> result = CamoError<String>(failure);
      final String output = result.fold(
        onSuccess: (String value) => value,
        onFailure: (CamoFailure failure) => failure.code,
      );
      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.valueOrNull, isNull);
      expect(result.failureOrNull, failure);
      expect(output, 'authorization_denied');
    });
  });
}
