class UserEntity {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final DateTime createdAt;

  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoUrl,
    required this.createdAt,
  });

  UserEntity copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is UserEntity &&
            runtimeType == other.runtimeType &&
            uid == other.uid &&
            email == other.email &&
            displayName == other.displayName &&
            photoUrl == other.photoUrl &&
            createdAt == other.createdAt;
  }

  @override
  int get hashCode => Object.hash(
        uid,
        email,
        displayName,
        photoUrl,
        createdAt,
      );
}