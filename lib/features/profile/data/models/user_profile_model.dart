import '../../domain/entities/user_entity.dart';

class UserProfileModel extends UserEntity {
  const UserProfileModel({
    required super.uid,
    required super.camoId,
    required super.email,
    super.displayName,
    super.photoUrl,
    required super.createdAt,
  });

  factory UserProfileModel.fromMap(Map<String, dynamic> map) {
    return UserProfileModel(
      uid: map['uid'] as String,
      camoId: map['camoId'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

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
}