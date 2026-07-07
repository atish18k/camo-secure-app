// ---------------------------------------------------------------------------
// Entity
// ---------------------------------------------------------------------------

class UserEntity {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const UserEntity({
    required this.uid,
    required this.camoId,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final String uid;
  final String camoId;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;

  // ---------------------------------------------------------------------------
  // Copy With
  // ---------------------------------------------------------------------------

  UserEntity copyWith({
    String? uid,
    String? camoId,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      camoId: camoId ?? this.camoId,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ---------------------------------------------------------------------------
  // Equality
  // ---------------------------------------------------------------------------

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
            createdAt == other.createdAt;
  }

  @override
  int get hashCode => Object.hash(
        uid,
        camoId,
        email,
        displayName,
        photoUrl,
        createdAt,
      );
}