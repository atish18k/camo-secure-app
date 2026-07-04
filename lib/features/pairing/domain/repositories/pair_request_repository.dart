import '../entities/pair_request_entity.dart';

abstract interface class PairRequestRepository {
  Future<void> sendRequest(
    PairRequestEntity request,
  );

  Future<PairRequestEntity?> getRequest(
    String id,
  );

  Stream<List<PairRequestEntity>> watchIncomingRequests(
    String receiverUid,
  );
}