import '../../../../core/enums/pair_request_status.dart';

class PairRequestEntity {
  final String id;
  final String senderUid;
  final String receiverUid;
  final DateTime createdAt;
  final PairRequestStatus status;

  const PairRequestEntity({
    required this.id,
    required this.senderUid,
    required this.receiverUid,
    required this.createdAt,
    required this.status,
  });

  PairRequestEntity copyWith({
    String? id,
    String? senderUid,
    String? receiverUid,
    DateTime? createdAt,
    PairRequestStatus? status,
  }) {
    return PairRequestEntity(
      id: id ?? this.id,
      senderUid: senderUid ?? this.senderUid,
      receiverUid: receiverUid ?? this.receiverUid,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PairRequestEntity &&
          id == other.id &&
          senderUid == other.senderUid &&
          receiverUid == other.receiverUid &&
          createdAt == other.createdAt &&
          status == other.status;

  @override
  int get hashCode => Object.hash(
        id,
        senderUid,
        receiverUid,
        createdAt,
        status,
      );
}