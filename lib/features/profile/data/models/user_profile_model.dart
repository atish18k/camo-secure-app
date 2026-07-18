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
      uid: _requiredString(map, 'uid'),
      camoId: _requiredString(map, 'camoId'),
      email: _requiredString(map, 'email'),
      displayName: _nullableString(map, 'displayName'),
      photoUrl: _nullableString(map, 'photoUrl'),
      createdAt: _requiredDateTime(map, 'createdAt'),
    );
  }

  factory UserProfileModel.fromEntity(UserEntity entity) {
    final model = UserProfileModel(
      uid: entity.uid,
      camoId: entity.camoId,
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      createdAt: entity.createdAt,
    );
    model.validate();
    return model;
  }

  void validate() {
    _validateRequired('uid', uid);
    _validateRequired('camoId', camoId);
    _validateRequired('email', email);
    _validateOptional('displayName', displayName);
    _validateOptional('photoUrl', photoUrl);
  }

  Map<String, dynamic> toMap() {
    validate();
    return <String, dynamic>{
      'uid': uid.trim(),
      'camoId': camoId.trim(),
      'email': email.trim(),
      'displayName': displayName?.trim(),
      'photoUrl': photoUrl?.trim(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static String _requiredString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! String || value.trim().isEmpty) {
      throw FormatException('Missing or invalid profile $key.');
    }
    return value.trim();
  }

  static String? _nullableString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value == null) return null;
    if (value is! String) {
      throw FormatException('Invalid profile $key.');
    }
    return value.trim();
  }

  static DateTime _requiredDateTime(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! String) {
      throw FormatException('Missing or invalid profile $key.');
    }
    final parsed = DateTime.tryParse(value);
    if (parsed == null) {
      throw FormatException('Missing or invalid profile $key.');
    }
    return parsed;
  }

  static void _validateRequired(String key, String value) {
    if (value.trim().isEmpty) {
      throw FormatException('Missing or invalid profile $key.');
    }
  }

  static void _validateOptional(String key, String? value) {
    if (value != null && value.length > 512) {
      throw FormatException('Invalid profile $key.');
    }
  }
}
