import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/pairing_entity.dart';

class PairingModel extends PairingEntity {
  const PairingModel({
    required super.id,
    required super.requesterUid,
    required super.requesterCamoId,
    required super.receiverUid,
    required super.receiverCamoId,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    super.acceptedAt,
    super.version = 1,
  });

  factory PairingModel.fromEntity(PairingEntity entity) {
    return PairingModel(
      id: entity.id,
      requesterUid: entity.requesterUid,
      requesterCamoId: entity.requesterCamoId,
      receiverUid: entity.receiverUid,
      receiverCamoId: entity.receiverCamoId,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      acceptedAt: entity.acceptedAt,
      version: entity.version,
    );
  }

  factory PairingModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    return PairingModel.fromMap(
      document.data() ?? {},
      id: document.id,
    );
  }

  factory PairingModel.fromMap(
    Map<String, dynamic> map, {
    String id = '',
  }) {
    return PairingModel(
      id: id,
      requesterUid: map['requesterUid'] as String? ?? '',
      requesterCamoId: map['requesterCamoId'] as String? ?? '',
      receiverUid: map['receiverUid'] as String? ?? '',
      receiverCamoId: map['receiverCamoId'] as String? ?? '',
      status: _statusFromString(map['status'] as String?),
      createdAt: _dateTimeFromTimestamp(map['createdAt']),
      updatedAt: _dateTimeFromTimestamp(map['updatedAt']),
      acceptedAt: _nullableDateTimeFromTimestamp(map['acceptedAt']),
      version: map['version'] as int? ?? 1,
    );
  }

  Map<String, dynamic> toFirestore() => toMap();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requesterUid': requesterUid,
      'requesterCamoId': requesterCamoId,
      'receiverUid': receiverUid,
      'receiverCamoId': receiverCamoId,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'acceptedAt': acceptedAt == null ? null : Timestamp.fromDate(acceptedAt!),
      'version': version,
    };
  }

  static PairingStatus _statusFromString(String? value) {
    return PairingStatus.values.firstWhere(
      (status) => status.name == value,
      orElse: () => PairingStatus.pending,
    );
  }

  static DateTime _dateTimeFromTimestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static DateTime? _nullableDateTimeFromTimestamp(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}