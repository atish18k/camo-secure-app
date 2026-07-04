import '../../../../core/errors/failure.dart';
import '../../domain/entities/pair_request_entity.dart';

enum PairRequestUiStatus {
  initial,
  loading,
  sent,
  loaded,
  failure,
}

class PairRequestState {
  final PairRequestUiStatus status;
  final PairRequestEntity? request;
  final Failure? failure;

  const PairRequestState({
    required this.status,
    this.request,
    this.failure,
  });

  const PairRequestState.initial()
      : status = PairRequestUiStatus.initial,
        request = null,
        failure = null;

  const PairRequestState.loading()
      : status = PairRequestUiStatus.loading,
        request = null,
        failure = null;

  const PairRequestState.sent()
      : status = PairRequestUiStatus.sent,
        request = null,
        failure = null;

  const PairRequestState.loaded(this.request)
      : status = PairRequestUiStatus.loaded,
        failure = null;

  const PairRequestState.failure(this.failure)
      : status = PairRequestUiStatus.failure,
        request = null;
}