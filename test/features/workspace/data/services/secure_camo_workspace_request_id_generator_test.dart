import 'dart:math';

import 'package:camo/features/workspace/data/services/secure_camo_workspace_request_id_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generates distinct non-empty request and operation identifiers', () {
    final SecureCamoWorkspaceRequestIdGenerator generator =
        SecureCamoWorkspaceRequestIdGenerator(
          secureRandom: Random(100),
        );

    final String requestId = generator.generateRequestId();
    final String operationId = generator.generateOperationId();

    expect(requestId, isNotEmpty);
    expect(operationId, isNotEmpty);
    expect(requestId, startsWith('camo_request_'));
    expect(operationId, startsWith('camo_operation_'));
    expect(requestId, isNot(operationId));
  });
}