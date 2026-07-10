// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../../domain/entities/camo_message_policy_state.dart';
import '../../domain/repositories/camo_message_policy_service.dart';
import '../datasources/camo_message_policy_remote_datasource.dart';

// ---------------------------------------------------------------------------
// CAMO Message Policy Service Implementation
// ---------------------------------------------------------------------------

class CamoMessagePolicyServiceImpl implements CamoMessagePolicyService {
  const CamoMessagePolicyServiceImpl(
    this._remoteDataSource,
  );

  final CamoMessagePolicyRemoteDataSource _remoteDataSource;

  @override
  Future<CamoMessagePolicyState> getMessagePolicy(
    String messageId,
  ) {
    return _remoteDataSource.getMessagePolicy(messageId);
  }
}