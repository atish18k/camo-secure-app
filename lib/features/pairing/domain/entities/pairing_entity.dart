class PairingEntity {
  final String id;
  final String ownerUid;
  final String peerUid;
  final DateTime createdAt;
  final bool isTrusted;

  const PairingEntity({
    required this.id,
    required this.ownerUid,
    required this.peerUid,
    required this.createdAt,
    required this.isTrusted,
  });

  PairingEntity copyWith({
    String? id,
    String? ownerUid,
    String? peerUid,
    DateTime? createdAt,
    bool? isTrusted,
  }) {
    return PairingEntity(
      id: id ?? this.id,
      ownerUid: ownerUid ?? this.ownerUid,
      peerUid: peerUid ?? this.peerUid,
      createdAt: createdAt ?? this.createdAt,
      isTrusted: isTrusted ?? this.isTrusted,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PairingEntity &&
          id == other.id &&
          ownerUid == other.ownerUid &&
          peerUid == other.peerUid &&
          createdAt == other.createdAt &&
          isTrusted == other.isTrusted;

  @override
  int get hashCode =>
      Object.hash(id, ownerUid, peerUid, createdAt, isTrusted);
}