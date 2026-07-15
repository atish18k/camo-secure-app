import 'package:camo/core/device_trust/domain/entities/camo_device_status.dart';
import 'package:camo/features/policy/data/adapters/camo_legacy_device_status_adapter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const adapter = CamoLegacyDeviceStatusAdapter();

  test('maps explicit legacy active to canonical approved', () {
    expect(adapter.toCanonical('active'), CamoDeviceStatus.approved);
  });

  test('maps explicit legacy revoked to canonical revoked', () {
    expect(adapter.toCanonical('revoked'), CamoDeviceStatus.revoked);
  });

  test('maps explicit legacy blocked to canonical blacklisted', () {
    expect(adapter.toCanonical('blocked'), CamoDeviceStatus.blacklisted);
  });

  test('accepts every canonical value idempotently', () {
    const expected = <String, CamoDeviceStatus>{
      'pending': CamoDeviceStatus.pending,
      'approved': CamoDeviceStatus.approved,
      'rejected': CamoDeviceStatus.rejected,
      'revoked': CamoDeviceStatus.revoked,
      'blacklisted': CamoDeviceStatus.blacklisted,
    };
    for (final entry in expected.entries) {
      expect(adapter.toCanonical(entry.key), entry.value);
    }
  });

  test('fails closed for missing status', () {
    expect(() => adapter.toCanonical(null), throwsFormatException);
  });

  test('fails closed for an empty status', () {
    expect(() => adapter.toCanonical(''), throwsFormatException);
  });

  test('fails closed for unknown status', () {
    expect(() => adapter.toCanonical('unexpected'), throwsFormatException);
  });

  test('fails closed for non-string status', () {
    expect(() => adapter.toCanonical(1), throwsFormatException);
  });
}
