// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/authorization_gateway/domain/entities/camo_authorization_timestamp.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  test('timestamp validates allowed clock skew', () {
    final DateTime serverTime = DateTime.now();
    final CamoAuthorizationTimestamp timestamp = CamoAuthorizationTimestamp(
      clientTime: serverTime.subtract(const Duration(seconds: 10)),
      maximumClockSkew: const Duration(seconds: 30),
    );
    expect(timestamp.isWithinAllowedSkew(serverTime), isTrue);
  });
}
