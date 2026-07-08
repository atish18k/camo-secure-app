// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import '../../domain/entities/user_crypto_entity.dart';

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

class UserCryptoModel extends UserCryptoEntity {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const UserCryptoModel({
    required super.publicKey,
    required super.algorithm,
    required super.version,
    required super.createdAt,
    required super.updatedAt,
  });

  // ---------------------------------------------------------------------------
  // From Map
  // ---------------------------------------------------------------------------

  factory UserCryptoModel.fromMap(
    Map<String, dynamic> map,
  ) {
    return UserCryptoModel(
      publicKey: map['publicKey'] as String? ?? '',
      algorithm: map['algorithm'] as String? ?? 'X25519',
      version: map['version'] as int? ?? 1,
      createdAt: DateTime.tryParse(
            map['createdAt'] as String? ?? '',
          ) ??
          DateTime.now().toUtc(),
      updatedAt: DateTime.tryParse(
            map['updatedAt'] as String? ?? '',
          ) ??
          DateTime.now().toUtc(),
    );
  }

  // ---------------------------------------------------------------------------
  // From Entity
  // ---------------------------------------------------------------------------

  factory UserCryptoModel.fromEntity(
    UserCryptoEntity entity,
  ) {
    return UserCryptoModel(
      publicKey: entity.publicKey,
      algorithm: entity.algorithm,
      version: entity.version,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // ---------------------------------------------------------------------------
  // To Map
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toMap() {
    return {
      'publicKey': publicKey,
      'algorithm': algorithm,
      'version': version,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}