// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../../domain/entities/user_entity.dart';

// ---------------------------------------------------------------------------
// Class
// ---------------------------------------------------------------------------

class UserProfileModel extends UserEntity {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const UserProfileModel({
    required super.uid,
    required super.camoId,
    required super.email,
    super.displayName,
    super.photoUrl,
    required super.createdAt,
  });

  // ---------------------------------------------------------------------------
  // Factories
  // ---------------------------------------------------------------------------

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      uid: map['uid'] as String? ?? '',
      camoId: map['camoId'] as String? ?? '',
      email: map['email'] as String? ?? '',
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      createdAt: DateTime.tryParse(
            map['createdAt'] as String? ?? '',
          ) ??
          DateTime.now(),
    );
  }

  factory UserProfileModel.fromEntity(UserEntity entity) {
    return UserProfileModel(
      uid: entity.uid,
      camoId: entity.camoId,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      createdAt: entity.createdAt,
    );
  }

  // ---------------------------------------------------------------------------
  // Mapping
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'camoId': camoId,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}