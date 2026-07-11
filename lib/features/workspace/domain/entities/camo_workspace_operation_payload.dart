import 'package:camo/core/shared/types/camo_operation_type.dart';

final class CamoWorkspaceOperationPayload {
  const CamoWorkspaceOperationPayload({
    required this.operationId,
    required this.pairingId,
    required this.operationType,
    this.plainText,
    this.encodedText,
    this.subject,
    this.camouflageEnabled = false,
  });

  final String operationId;
  final String pairingId;
  final CamoOperationType operationType;
  final String? plainText;
  final String? encodedText;
  final String? subject;
  final bool camouflageEnabled;

  bool get isValid {
    if (operationId.trim().isEmpty || pairingId.trim().isEmpty) {
      return false;
    }

    if (operationType == CamoOperationType.encode) {
      return plainText != null && plainText!.isNotEmpty;
    }

    if (operationType == CamoOperationType.decode) {
      return encodedText != null && encodedText!.isNotEmpty;
    }

    return false;
  }
}
