// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/risk_engine/domain/entities/camo_risk_signal.dart';
import 'package:camo/core/risk_engine/domain/entities/camo_risk_signal_type.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  group('CamoRiskSignal', () {
    test('valid low-score signal is not critical', () {
      final CamoRiskSignal signal = CamoRiskSignal(
        signalId: 'signal-001',
        type: CamoRiskSignalType.newDevice,
        score: 20,
        detectedAt: DateTime.utc(2026, 7, 11),
        source: 'device',
      );
      expect(signal.isValidScore, isTrue);
      expect(signal.isCritical, isFalse);
    });
    test('replay attempt is always critical', () {
      final CamoRiskSignal signal = CamoRiskSignal(
        signalId: 'signal-002',
        type: CamoRiskSignalType.replayAttempt,
        score: 40,
        detectedAt: DateTime.utc(2026, 7, 11),
        source: 'network',
      );
      expect(signal.isCritical, isTrue);
    });
  });
}
