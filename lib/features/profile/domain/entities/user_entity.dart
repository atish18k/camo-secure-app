// ---------------------------------------------------------------------------
// Entity
// ---------------------------------------------------------------------------

class UserEntity {
  const UserEntity({
    required this.uid,
    required this.camoId,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.publicKey,
    required this.createdAt,
  });

  final String uid;
  final String camoId;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? publicKey;
  final DateTime createdAt;

  UserEntity copyWith({
    String? uid,
    String? camoId,
    String? email,
    String? displayName,
    String? photoUrl,
    String? publicKey,
    DateTime? createdAt,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      camoId: camoId ?? this.camoId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      publicKey: publicKey ?? this.publicKey,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is UserEntity &&
            runtimeType == other.runtimeType &&
            uid == other.uid &&
            camoId == other.camoId &&
            email == other.email &&
            displayName == other.displayName &&
            photoUrl == other.photoUrl &&
            publicKey == other.publicKey &&
            createdAt == other.createdAt;
  }

  @override
  int get hashCode => Object.hash(
        uid,
        camoId,
        email,
        displayName,
        photoUrl,
        publicKey,
        createdAt,
      );
}