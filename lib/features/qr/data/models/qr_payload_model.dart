// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:convert';

import '../../domain/entities/qr_payload.dart';

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

class QrPayloadModel extends QrPayload {
  const QrPayloadModel({
    required super.version,
    required super.type,
    required super.identity,
  });

  factory QrPayloadModel.identity({
    required String camoId,
  }) {
    return QrPayloadModel(
      version: 1,
      type: 'identity',
      identity: camoId,
    );
  }

  String toQrString() {
    return jsonEncode(toJson());
  }
}