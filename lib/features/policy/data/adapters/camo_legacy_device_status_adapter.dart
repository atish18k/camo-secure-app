import 'package:camo/core/device_trust/domain/entities/camo_device_status.dart';

/// Converts explicit legacy Firestore device status values into the canonical
/// device lifecycle status model.
///
/// Missing, malformed, and unknown values are rejected. This adapter never
/// invents an approved status when the source value is absent or ambiguous.
final class CamoLegacyDeviceStatusAdapter {
  const CamoLegacyDeviceStatusAdapter();

  CamoDeviceStatus toCanonical(Object? value) {
    switch (value) {
      case 'active':
      case 'approved':
        return CamoDeviceStatus.approved;
      case 'revoked':
        return CamoDeviceStatus.revoked;
      case 'blocked':
      case 'blacklisted':
        return CamoDeviceStatus.blacklisted;
      case 'pending':
        return CamoDeviceStatus.pending;
      case 'rejected':
        return CamoDeviceStatus.rejected;
      default:
        throw const FormatException(
          'Device status is missing, invalid, or unsupported.',
        );
    }
  }
}
