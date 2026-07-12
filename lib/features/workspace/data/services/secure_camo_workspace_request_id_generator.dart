import 'dart:math';

import '../../domain/services/camo_workspace_request_id_generator.dart';

final class SecureCamoWorkspaceRequestIdGenerator
    implements CamoWorkspaceRequestIdGenerator {
  SecureCamoWorkspaceRequestIdGenerator({Random? secureRandom})
    : _secureRandom = secureRandom ?? Random.secure();

  final Random _secureRandom;

  @override
  String generateRequestId() {
    return _generateIdentifier('request');
  }

  @override
  String generateOperationId() {
    return _generateIdentifier('operation');
  }

  String _generateIdentifier(String prefix) {
    final int timestamp = DateTime.now().toUtc().microsecondsSinceEpoch;

    final String randomPart = List<String>.generate(
      4,
      (_) => _secureRandom.nextInt(0x100000000).toRadixString(16).padLeft(8, '0'),
      growable: false,
    ).join();

    return 'camo_${prefix}_${timestamp}_$randomPart';
  }
}