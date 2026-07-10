import 'package:camo/features/policy/data/repositories/camo_policy_evaluator_impl.dart';
import 'package:camo/features/policy/domain/entities/camo_policy_context.dart';
import 'package:camo/features/policy/domain/entities/camo_policy_failure_reason.dart';
import 'package:camo/features/policy/domain/entities/camo_policy_operation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CamoPolicyEvaluatorImpl', () {
    const CamoPolicyEvaluatorImpl evaluator =
        CamoPolicyEvaluatorImpl();

    CamoPolicyContext createContext({
      CamoPolicyOperation operation = CamoPolicyOperation.encode,
      String currentUserId = 'user-a',
      String deviceId = 'device-a',
      String pairingId = 'pair-1',
      String? messageId,
      bool isAuthenticated = true,
      bool isDeviceValid = true,
      bool isLicenseValid = true,
      bool isPairAccepted = true,
      bool isExpired = false,
      bool isBurned = false,
      bool isDeleted = false,
      bool isRevoked = false,
      bool isBlocked = false,
      int policyVersion = 1,
      int requiredPolicyVersion = 1,
    }) {
      return CamoPolicyContext(
        operation: operation,
        currentUserId: currentUserId,
        deviceId: deviceId,
        pairingId: pairingId,
        messageId: messageId,
        isAuthenticated: isAuthenticated,
        isDeviceValid: isDeviceValid,
        isLicenseValid: isLicenseValid,
        isPairAccepted: isPairAccepted,
        isExpired: isExpired,
        isBurned: isBurned,
        isDeleted: isDeleted,
        isRevoked: isRevoked,
        isBlocked: isBlocked,
        policyVersion: policyVersion,
        requiredPolicyVersion: requiredPolicyVersion,
      );
    }

    test('allows valid encode operation', () {
      final result = evaluator.evaluate(
        createContext(),
      );

      expect(result.isAllowed, isTrue);
      expect(result.failureReason, isNull);
    });

    test('denies unauthenticated operation', () {
      final result = evaluator.evaluate(
        createContext(
          isAuthenticated: false,
        ),
      );

      expect(result.isDenied, isTrue);
      expect(
        result.failureReason,
        CamoPolicyFailureReason.authenticationRequired,
      );
    });

    test('denies invalid device', () {
      final result = evaluator.evaluate(
        createContext(
          isDeviceValid: false,
        ),
      );

      expect(result.isDenied, isTrue);
      expect(
        result.failureReason,
        CamoPolicyFailureReason.deviceMismatch,
      );
    });

    test('denies invalid license', () {
      final result = evaluator.evaluate(
        createContext(
          isLicenseValid: false,
        ),
      );

      expect(result.isDenied, isTrue);
      expect(
        result.failureReason,
        CamoPolicyFailureReason.licenseExpired,
      );
    });

    test('denies unaccepted pairing', () {
      final result = evaluator.evaluate(
        createContext(
          isPairAccepted: false,
        ),
      );

      expect(result.isDenied, isTrue);
      expect(
        result.failureReason,
        CamoPolicyFailureReason.pairNotAccepted,
      );
    });

    test('denies blocked operation', () {
      final result = evaluator.evaluate(
        createContext(
          isBlocked: true,
        ),
      );

      expect(result.isDenied, isTrue);
      expect(
        result.failureReason,
        CamoPolicyFailureReason.blocked,
      );
    });

    test('denies policy version mismatch', () {
      final result = evaluator.evaluate(
        createContext(
          policyVersion: 1,
          requiredPolicyVersion: 2,
        ),
      );

      expect(result.isDenied, isTrue);
      expect(
        result.failureReason,
        CamoPolicyFailureReason.policyVersionMismatch,
      );
    });

    test('allows valid decode operation', () {
      final result = evaluator.evaluate(
        createContext(
          operation: CamoPolicyOperation.decode,
          messageId: 'message-1',
        ),
      );

      expect(result.isAllowed, isTrue);
      expect(result.failureReason, isNull);
    });

    test('denies decode without message id', () {
      final result = evaluator.evaluate(
        createContext(
          operation: CamoPolicyOperation.decode,
        ),
      );

      expect(result.isDenied, isTrue);
      expect(
        result.failureReason,
        CamoPolicyFailureReason.policyViolation,
      );
    });

    test('denies deleted message', () {
      final result = evaluator.evaluate(
        createContext(
          operation: CamoPolicyOperation.decode,
          messageId: 'message-1',
          isDeleted: true,
        ),
      );

      expect(result.isDenied, isTrue);
      expect(
        result.failureReason,
        CamoPolicyFailureReason.deleted,
      );
    });

    test('denies revoked message', () {
      final result = evaluator.evaluate(
        createContext(
          operation: CamoPolicyOperation.decode,
          messageId: 'message-1',
          isRevoked: true,
        ),
      );

      expect(result.isDenied, isTrue);
      expect(
        result.failureReason,
        CamoPolicyFailureReason.revoked,
      );
    });

    test('denies burned message', () {
      final result = evaluator.evaluate(
        createContext(
          operation: CamoPolicyOperation.decode,
          messageId: 'message-1',
          isBurned: true,
        ),
      );

      expect(result.isDenied, isTrue);
      expect(
        result.failureReason,
        CamoPolicyFailureReason.burned,
      );
    });

    test('denies expired message', () {
      final result = evaluator.evaluate(
        createContext(
          operation: CamoPolicyOperation.decode,
          messageId: 'message-1',
          isExpired: true,
        ),
      );

      expect(result.isDenied, isTrue);
      expect(
        result.failureReason,
        CamoPolicyFailureReason.messageExpired,
      );
    });
  });
}