import '../../../../core/errors/failure.dart';
import '../../domain/entities/pairing_entity.dart';

// ---------------------------------------------------------------------------
// UI Status
// ---------------------------------------------------------------------------

enum PairRequestUiStatus {
  initial,
  loading,
  sent,
  loaded,
  failure,
}

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class PairRequestState {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const PairRequestState({
    required this.status,
    this.pairing,
    this.failure,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final PairRequestUiStatus status;
  final PairingEntity? pairing;
  final Failure? failure;

  // ---------------------------------------------------------------------------
  // Named Constructors
  // ---------------------------------------------------------------------------

  const PairRequestState.initial()
      : status = PairRequestUiStatus.initial,
        pairing = null,
        failure = null;

  const PairRequestState.loading()
      : status = PairRequestUiStatus.loading,
        pairing = null,
        failure = null;

  const PairRequestState.sent()
      : status = PairRequestUiStatus.sent,
        pairing = null,
        failure = null;

  const PairRequestState.loaded(this.pairing)
      : status = PairRequestUiStatus.loaded,
        failure = null;

  const PairRequestState.failure(this.failure)
      : status = PairRequestUiStatus.failure,
        pairing = null;
}