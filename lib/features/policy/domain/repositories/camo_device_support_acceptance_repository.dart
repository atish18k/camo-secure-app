import '../entities/camo_device_support_acceptance.dart';

abstract interface class CamoDeviceSupportAcceptanceRepository {
  Future<void> saveCurrentUserAcceptance(
    CamoDeviceSupportAcceptance acceptance,
  );
}
