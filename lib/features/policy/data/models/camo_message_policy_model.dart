// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../../domain/entities/camo_message_policy_state.dart';

// ---------------------------------------------------------------------------
// CAMO Message Policy Model
// ---------------------------------------------------------------------------

/// Data-layer representation of server-side CAMO message policy flags.
///
/// This model contains policy information only. Plaintext, decrypted content,
/// encryption keys, and private keys must never be added to this model.
class CamoMessagePolicyModel extends CamoMessagePolicyState {
  const CamoMessagePolicyModel({
    required super.messageId,
    required super.isExpired,
    required super.isBurned,
    required super.isDeleted,
    required super.isRevoked,
    required super.isBlocked,
    required super.policyVersion,
    required super.requiredPolicyVersion,
  });

  // ---------------------------------------------------------------------------
  // Firestore Mapping
  // ---------------------------------------------------------------------------

  factory CamoMessagePolicyModel.fromMap({
    required String messageId,
    required Map<String, dynamic> map,
  }) {
    return CamoMessagePolicyModel(
      messageId: messageId,
      isExpired: map['expired'] as bool? ?? false,
      isBurned: map['burned'] as bool? ?? false,
      isDeleted: map['deleted'] as bool? ?? false,
      isRevoked: map['revoked'] as bool? ?? false,
      isBlocked: map['blocked'] as bool? ?? false,
      policyVersion: map['policyVersion'] as int? ?? 1,
      requiredPolicyVersion:
          map['requiredPolicyVersion'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'expired': isExpired,
      'burned': isBurned,
      'deleted': isDeleted,
      'revoked': isRevoked,
      'blocked': isBlocked,
      'policyVersion': policyVersion,
      'requiredPolicyVersion': requiredPolicyVersion,
    };
  }
}