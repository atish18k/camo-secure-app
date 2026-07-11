// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import '../../../shared/types/camo_operation_type.dart';
import 'camo_risk_signal.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoRiskAssessmentContext {
  CamoRiskAssessmentContext({
    required this.assessmentId,
    required this.userId,
    required this.deviceId,
    required this.operationId,
    required this.operationType,
    required this.requestedAt,
    required List<CamoRiskSignal> signals,
    this.pairId,
    this.messageId,
    Map<String, String> attributes = const <String, String>{},
  }) : signals = List<CamoRiskSignal>.unmodifiable(signals),
       attributes = Map<String, String>.unmodifiable(attributes);
  final String assessmentId;
  final String userId;
  final String deviceId;
  final String operationId;
  final CamoOperationType operationType;
  final DateTime requestedAt;
  final List<CamoRiskSignal> signals;
  final String? pairId;
  final String? messageId;
  final Map<String, String> attributes;
  int get aggregateSignalScore {
    return signals.fold<int>(
      0,
      (int total, CamoRiskSignal signal) => total + signal.score,
    );
  }

  bool get hasCriticalSignal {
    return signals.any((CamoRiskSignal signal) => signal.isCritical);
  }
}
