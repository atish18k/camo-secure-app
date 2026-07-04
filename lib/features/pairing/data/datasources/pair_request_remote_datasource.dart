import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_paths.dart';
import '../models/pair_request_model.dart';

abstract class PairRequestRemoteDataSource {
  Future<void> sendRequest(PairRequestModel request);

  Future<PairRequestModel?> getRequest(String id);

  Stream<List<PairRequestModel>> watchIncomingRequests(
    String receiverUid,
  );
}

class FirebasePairRequestRemoteDataSource
    implements PairRequestRemoteDataSource {
  final FirebaseFirestore _firestore;

  const FirebasePairRequestRemoteDataSource(
    this._firestore,
  );

  @override
  Future<void> sendRequest(
    PairRequestModel request,
  ) async {
    await _firestore
        .collection(FirestorePaths.pairRequests)
        .doc(request.id)
        .set(
          request.toMap(),
          SetOptions(merge: true),
        );
  }

  @override
  Future<PairRequestModel?> getRequest(
    String id,
  ) async {
    final snapshot = await _firestore
        .collection(FirestorePaths.pairRequests)
        .doc(id)
        .get();

    if (!snapshot.exists) {
      return null;
    }

    return PairRequestModel.fromMap(snapshot.data()!);
  }

  @override
  Stream<List<PairRequestModel>> watchIncomingRequests(
    String receiverUid,
  ) {
    return _firestore
        .collection(FirestorePaths.pairRequests)
        .where(
          'receiverUid',
          isEqualTo: receiverUid,
        )
        .where(
          'status',
          isEqualTo: 'pending',
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => PairRequestModel.fromMap(
                  doc.data(),
                ),
              )
              .toList(),
        );
  }
}