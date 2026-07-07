// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'package:equatable/equatable.dart';

// ---------------------------------------------------------------------------
// Enum
// ---------------------------------------------------------------------------

/// Represents the current lifecycle state of a CAMO pairing.
enum PairingStatus {
  pending,
  accepted,
  rejected,
  blocked,
  cancelled,
  expired,
}

// ---------------------------------------------------------------------------
// Entity
// ---------------------------------------------------------------------------

/// Core domain entity representing a trusted pairing relationship
/// between two CAMO identities.
class PairingEntity extends Equatable {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  const PairingEntity({
    required this.id,
    required this.requesterUid,
    required this.requesterCamoId,
    required this.receiverUid,
    required this.receiverCamoId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.acceptedAt,
    this.version = 1,
  });

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final String id;

  final String requesterUid;
  final String requesterCamoId;

  final String receiverUid;
  final String receiverCamoId;

  final PairingStatus status;

  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? acceptedAt;

  final int version;

  // ---------------------------------------------------------------------------
  // Copy With
  // ---------------------------------------------------------------------------

  PairingEntity copyWith({
    String? id,
    String? requesterUid,
    String? requesterCamoId,
    String? receiverUid,
    String? receiverCamoId,
    PairingStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? acceptedAt,
    int? version,
  }) {
    return PairingEntity(
      id: id ?? this.id,
      requesterUid: requesterUid ?? this.requesterUid,
      requesterCamoId: requesterCamoId ?? this.requesterCamoId,
      receiverUid: receiverUid ?? this.receiverUid,
      receiverCamoId: receiverCamoId ?? this.receiverCamoId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      version: version ?? this.version,
    );
  }

  // ---------------------------------------------------------------------------
  // Equatable
  // ---------------------------------------------------------------------------

  @override
  List<Object?> get props => [
        id,
        requesterUid,
        requesterCamoId,
        receiverUid,
        receiverCamoId,
        status,
        createdAt,
        updatedAt,
        acceptedAt,
        version,
      ];
}