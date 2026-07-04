import '../../domain/entities/pair_request_entity.dart';
import '../../domain/repositories/pair_request_repository.dart';
import '../datasources/pair_request_remote_datasource.dart';
import '../models/pair_request_model.dart';

class PairRequestRepositoryImpl implements PairRequestRepository {
  final PairRequestRemoteDataSource _remoteDataSource;

  const PairRequestRepositoryImpl(
    this._remoteDataSource,
  );

  @override
  Future<void> sendRequest(
    PairRequestEntity request,
  ) async {
    final model = PairRequestModel.fromEntity(request);

    await _remoteDataSource.sendRequest(model);
  }

  @override
  Future<PairRequestEntity?> getRequest(
    String id,
  ) {
    return _remoteDataSource.getRequest(id);
  }

  @override
  Stream<List<PairRequestEntity>> watchIncomingRequests(
    String receiverUid,
  ) {
    return _remoteDataSource.watchIncomingRequests(receiverUid);
  }
}