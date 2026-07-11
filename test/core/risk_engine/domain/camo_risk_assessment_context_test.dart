// -----------------------------------------------------------------------------
// Imports
// -----------------------------------------------------------------------------
import 'package:camo/core/risk_engine/domain/entities/camo_risk_assessment_context.dart';
import 'package:camo/core/risk_engine/domain/entities/camo_risk_signal.dart';
import 'package:camo/core/risk_engine/domain/entities/camo_risk_signal_type.dart';
import 'package:camo/core/shared/types/camo_operation_type.dart';
import 'package:flutter_test/flutter_test.dart';

// -----------------------------------------------------------------------------
// Tests
// -----------------------------------------------------------------------------
void main() {
  group('CamoRiskAssessmentContext', () {
    test('aggregates signals and detects critical signal', () {
      final CamoRiskAssessmentContext context = CamoRiskAssessmentContext(
        assessmentId: 'assessment-001',
        userId: 'user-001',
        deviceId: 'device-001',
        operationId: 'operation-001',
        operationType: CamoOperationType.decode,
        requestedAt: DateTime.utc(2026, 7, 11),
        signals: <CamoRiskSignal>[
          CamoRiskSignal(
            signalId: 'signal-001',
            type: CamoRiskSignalType.newDevice,
            score: 20,
            detectedAt: DateTime.utc(2026, 7, 11),
            source: 'device',
          ),
          CamoRiskSignal(
            signalId: 'signal-002',
            type: CamoRiskSignalType.replayAttempt,
            score: 50,
            detectedAt: DateTime.utc(2026, 7, 11),
            source: 'network',
          ),
        ],
      );
      expect(context.aggregateSignalScore, 70);
      expect(context.hasCriticalSignal, isTrue);
    });
  });
}
