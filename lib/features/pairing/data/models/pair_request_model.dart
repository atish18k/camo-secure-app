import '../../../../core/enums/pair_request_status.dart';
import '../../domain/entities/pair_request_entity.dart';

class PairRequestModel extends PairRequestEntity {
  const PairRequestModel({
    required super.id,
    required super.senderUid,
    required super.receiverUid,
    required super.createdAt,
    required super.status,
  });

  factory PairRequestModel.fromMap(Map<String, dynamic> map) {
    return PairRequestModel(
      id: map['id'] as String,
      senderUid: map['senderUid'] as String,
      receiverUid: map['receiverUid'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      status: PairRequestStatusX.fromValue(map['status'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderUid': senderUid,
      'receiverUid': receiverUid,
      'createdAt': createdAt.toIso8601String(),
      'status': status.value,
    };
  }

  factory PairRequestModel.fromEntity(PairRequestEntity entity) {
    return PairRequestModel(
      id: entity.id,
      senderUid: entity.senderUid,
      receiverUid: entity.receiverUid,
      createdAt: entity.createdAt,
      status: entity.status,
    );
  }
}