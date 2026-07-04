enum PairRequestStatus {
  pending,
  accepted,
  rejected,
  cancelled,
  expired,
}

extension PairRequestStatusX on PairRequestStatus {
  String get value {
    switch (this) {
      case PairRequestStatus.pending:
        return 'pending';
      case PairRequestStatus.accepted:
        return 'accepted';
      case PairRequestStatus.rejected:
        return 'rejected';
      case PairRequestStatus.cancelled:
        return 'cancelled';
      case PairRequestStatus.expired:
        return 'expired';
    }
  }

  static PairRequestStatus fromValue(String value) {
    switch (value) {
      case 'accepted':
        return PairRequestStatus.accepted;
      case 'rejected':
        return PairRequestStatus.rejected;
      case 'cancelled':
        return PairRequestStatus.cancelled;
      case 'expired':
        return PairRequestStatus.expired;
      case 'pending':
      default:
        return PairRequestStatus.pending;
    }
  }
}