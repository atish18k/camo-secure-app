import '../../domain/entities/pairing_entity.dart';

class PairingModel extends PairingEntity {
  const PairingModel({
    required super.id,
    required super.ownerUid,
    required super.peerUid,
    required super.createdAt,
    required super.isTrusted,
  });

  factory PairingModel.fromMap(Map<String, dynamic> map) {
    return PairingModel(
      id: map['id'] as String,
      ownerUid: map['ownerUid'] as String,
      peerUid: map['peerUid'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      isTrusted: map['isTrusted'] as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ownerUid': ownerUid,
      'peerUid': peerUid,
      'createdAt': createdAt.toIso8601String(),
      'isTrusted': isTrusted,
    };
  }

  factory PairingModel.fromEntity(PairingEntity entity) {
    return PairingModel(
      id: entity.id,
      ownerUid: entity.ownerUid,
      peerUid: entity.peerUid,
      createdAt: entity.createdAt,
      isTrusted: entity.isTrusted,
    );
  }
}