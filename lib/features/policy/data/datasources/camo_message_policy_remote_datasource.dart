// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../models/camo_message_policy_model.dart';

// ---------------------------------------------------------------------------
// CAMO Message Policy Remote Data Source
// ---------------------------------------------------------------------------

abstract class CamoMessagePolicyRemoteDataSource {
  Future<CamoMessagePolicyModel> getMessagePolicy(
    String messageId,
  );
}

// ---------------------------------------------------------------------------
// Firebase CAMO Message Policy Remote Data Source
// ---------------------------------------------------------------------------

class FirebaseCamoMessagePolicyRemoteDataSource
    implements CamoMessagePolicyRemoteDataSource {
  const FirebaseCamoMessagePolicyRemoteDataSource(
    this._firestore,
  );

  final FirebaseFirestore _firestore;

  @override
  Future<CamoMessagePolicyModel> getMessagePolicy(
    String messageId,
  ) async {
    final String normalizedMessageId = messageId.trim();

    if (normalizedMessageId.isEmpty) {
      throw StateError('Message policy identifier is required.');
    }

    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await _firestore
            .collection(FirestorePaths.messagePolicies)
            .doc(normalizedMessageId)
            .get();

    final Map<String, dynamic>? data = snapshot.data();

    if (!snapshot.exists || data == null) {
      throw StateError('Message policy record not found.');
    }

    return CamoMessagePolicyModel.fromMap(
      messageId: snapshot.id,
      map: data,
    );
  }
}