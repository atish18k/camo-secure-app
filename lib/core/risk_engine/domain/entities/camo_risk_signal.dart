// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'camo_risk_signal_type.dart';

// -----------------------------------------------------------------------------
// Class
// -----------------------------------------------------------------------------
final class CamoRiskSignal {
  CamoRiskSignal({
    required this.signalId,
    required this.type,
    required this.score,
    required this.detectedAt,
    required this.source,
    Map<String, String> metadata = const <String, String>{},
  }) : metadata = Map<String, String>.unmodifiable(metadata);
  final String signalId;
  final CamoRiskSignalType type;
  final int score;
  final DateTime detectedAt;
  final String source;
  final Map<String, String> metadata;
  bool get isValidScore => score >= 0 && score <= 100;
  bool get isCritical => type.isCritical || score >= 90;
}
