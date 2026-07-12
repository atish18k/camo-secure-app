import '../../domain/services/camo_workspace_message_context_resolver.dart';

final class FailClosedCamoWorkspaceMessageContextResolver
    implements CamoWorkspaceMessageContextResolver {
  const FailClosedCamoWorkspaceMessageContextResolver();

  @override
  Future<String> resolveMessageId({
    required String pairingId,
    required String operationId,
  }) async {
    if (pairingId.trim().isEmpty) {
      throw StateError('Pairing identifier is required.');
    }

    if (operationId.trim().isEmpty) {
      throw StateError('Operation identifier is required.');
    }

    throw StateError(
      'Authorized message context resolution is not available.',
    );
  }
}