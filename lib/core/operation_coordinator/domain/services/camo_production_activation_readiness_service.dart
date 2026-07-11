import '../entities/camo_production_activation_readiness.dart';

abstract interface class CamoProductionActivationReadinessService {
  Future<CamoProductionActivationReadiness> evaluate();
}
