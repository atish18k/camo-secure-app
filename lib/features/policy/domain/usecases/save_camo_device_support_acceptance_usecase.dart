import '../entities/camo_device_support_acceptance.dart';
import '../repositories/camo_device_support_acceptance_repository.dart';

final class SaveCamoDeviceSupportAcceptanceUseCase {
  const SaveCamoDeviceSupportAcceptanceUseCase(this._repository);
  final CamoDeviceSupportAcceptanceRepository _repository;

  Future<void> call(CamoDeviceSupportAcceptance acceptance) {
    acceptance.validate();
    return _repository.saveCurrentUserAcceptance(acceptance);
  }
}
