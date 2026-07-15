import 'package:cloud_firestore/cloud_firestore.dart';

enum CamoCanonicalPairStatus {
  pending,
  active,
  rejected,
  revoked,
  expired,
  blocked,
}

final class CamoCanonicalPairModel {
  CamoCanonicalPairModel({
    required this.pairId,
    required List<String> participantUserIds,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.requestedBy,
    this.acceptedAt,
    this.rejectedAt,
    this.revokedAt,
    this.expiresAt,
    this.blockedAt,
  }) : participantUserIds = _canonicalParticipants(participantUserIds) {
    _validate();
  }

  static const int schemaVersion = 1;

  final String pairId;
  final List<String> participantUserIds;
  final CamoCanonicalPairStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? requestedBy;
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final DateTime? revokedAt;
  final DateTime? expiresAt;
  final DateTime? blockedAt;

  factory CamoCanonicalPairModel.fromMap(Map<String, dynamic> map) {
    final version = map['schemaVersion'];
    if (version != schemaVersion) {
      throw const FormatException('Unsupported canonical pair schemaVersion.');
    }
    return CamoCanonicalPairModel(
      pairId: _requiredString(map, 'pairId'),
      participantUserIds: _requiredStringList(map, 'participantUserIds'),
      status: _requiredStatus(map['status']),
      createdAt: _requiredDate(map, 'createdAt'),
      updatedAt: _requiredDate(map, 'updatedAt'),
      requestedBy: _optionalString(map, 'requestedBy'),
      acceptedAt: _optionalDate(map, 'acceptedAt'),
      rejectedAt: _optionalDate(map, 'rejectedAt'),
      revokedAt: _optionalDate(map, 'revokedAt'),
      expiresAt: _optionalDate(map, 'expiresAt'),
      blockedAt: _optionalDate(map, 'blockedAt'),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'schemaVersion': schemaVersion,
      'pairId': pairId,
      'participantUserIds': List<String>.unmodifiable(participantUserIds),
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt.toUtc()),
      'updatedAt': Timestamp.fromDate(updatedAt.toUtc()),
      if (requestedBy != null) 'requestedBy': requestedBy,
      if (acceptedAt != null)
        'acceptedAt': Timestamp.fromDate(acceptedAt!.toUtc()),
      if (rejectedAt != null)
        'rejectedAt': Timestamp.fromDate(rejectedAt!.toUtc()),
      if (revokedAt != null)
        'revokedAt': Timestamp.fromDate(revokedAt!.toUtc()),
      if (expiresAt != null)
        'expiresAt': Timestamp.fromDate(expiresAt!.toUtc()),
      if (blockedAt != null)
        'blockedAt': Timestamp.fromDate(blockedAt!.toUtc()),
    };
  }

  void _validate() {
    if (pairId.trim().isEmpty ||
        pairId != pairId.trim() ||
        pairId.contains('/')) {
      throw const FormatException('pairId must be a non-empty document ID.');
    }
    if (!createdAt.isUtc || !updatedAt.isUtc || updatedAt.isBefore(createdAt)) {
      throw const FormatException(
        'Canonical pair timestamps must be ordered UTC values.',
      );
    }
    if (requestedBy != null && !participantUserIds.contains(requestedBy)) {
      throw const FormatException('requestedBy must be a pair participant.');
    }
    final lifecycleTimes = <DateTime?>[
      acceptedAt,
      rejectedAt,
      revokedAt,
      expiresAt,
      blockedAt,
    ];
    if (lifecycleTimes.whereType<DateTime>().any((value) => !value.isUtc)) {
      throw const FormatException('Lifecycle timestamps must be UTC values.');
    }
    final requiredTime = switch (status) {
      CamoCanonicalPairStatus.active => acceptedAt,
      CamoCanonicalPairStatus.rejected => rejectedAt,
      CamoCanonicalPairStatus.revoked => revokedAt,
      CamoCanonicalPairStatus.expired => expiresAt,
      CamoCanonicalPairStatus.blocked => blockedAt,
      CamoCanonicalPairStatus.pending => createdAt,
    };
    if (requiredTime == null) {
      throw FormatException(
        '${status.name} requires its canonical lifecycle timestamp.',
      );
    }
  }

  static List<String> _canonicalParticipants(List<String> values) {
    if (values.length != 2) {
      throw const FormatException(
        'Exactly two participantUserIds are required.',
      );
    }
    final result = values.map((value) => value.trim()).toList()..sort();
    if (result.any((value) => value.isEmpty || value.contains('/')) ||
        result[0] == result[1]) {
      throw const FormatException(
        'Participants must be distinct non-empty Firebase UIDs.',
      );
    }
    return List<String>.unmodifiable(result);
  }

  static String _requiredString(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is! String || value.trim().isEmpty || value != value.trim()) {
      throw FormatException('$key must be a non-empty string.');
    }
    return value;
  }

  static String? _optionalString(Map<String, dynamic> map, String key) {
    if (!map.containsKey(key)) return null;
    return _requiredString(map, key);
  }

  static List<String> _requiredStringList(
    Map<String, dynamic> map,
    String key,
  ) {
    final value = map[key];
    if (value is! List || value.any((item) => item is! String)) {
      throw FormatException('$key must be a string list.');
    }
    return value.cast<String>();
  }

  static CamoCanonicalPairStatus _requiredStatus(dynamic value) {
    if (value is! String) throw const FormatException('status is required.');
    for (final status in CamoCanonicalPairStatus.values) {
      if (status.name == value) return status;
    }
    throw FormatException('Unknown canonical pair status: $value');
  }

  static DateTime _requiredDate(Map<String, dynamic> map, String key) {
    final value = map[key];
    if (value is Timestamp) return value.toDate().toUtc();
    if (value is DateTime) return value.toUtc();
    throw FormatException('$key must be a Firestore Timestamp or DateTime.');
  }

  static DateTime? _optionalDate(Map<String, dynamic> map, String key) {
    if (!map.containsKey(key)) return null;
    return _requiredDate(map, key);
  }
}
