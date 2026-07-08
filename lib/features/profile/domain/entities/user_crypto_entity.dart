// ---------------------------------------------------------------------------
// Entity
// ---------------------------------------------------------------------------

class UserCryptoEntity {
  const UserCryptoEntity({
    required this.publicKey,
    required this.algorithm,
    required this.version,
    required this.createdAt,
    required this.updatedAt,
  });

  final String publicKey;
  final String algorithm;
  final int version;
  final DateTime createdAt;
  final DateTime updatedAt;
}