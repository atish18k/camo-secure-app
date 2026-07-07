// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:convert';
import 'dart:typed_data';

import 'camo_crypto_payload.dart';

// ---------------------------------------------------------------------------
// Binary Serializer
// ---------------------------------------------------------------------------

class CamoBinarySerializer {
  // ---------------------------------------------------------------------------
  // Serialize
  // ---------------------------------------------------------------------------

  Uint8List serialize(
    CamoCryptoPayload payload,
  ) {
    final BytesBuilder builder = BytesBuilder();

    _writeInt(builder, payload.version);
    _writeString(builder, payload.algorithm);
    _writeString(builder, payload.nonce);
    _writeString(builder, payload.cipherText);
    _writeString(builder, payload.authenticationTag);
    _writeInt(builder, payload.createdAt.toUtc().millisecondsSinceEpoch);
    _writeBool(builder, payload.camouflageEnabled);
    _writeNullableString(builder, payload.subject);

    return builder.toBytes();
  }

  // ---------------------------------------------------------------------------
  // Deserialize
  // ---------------------------------------------------------------------------

  CamoCryptoPayload deserialize(
    Uint8List bytes,
  ) {
    final _BinaryReader reader = _BinaryReader(bytes);

    return CamoCryptoPayload(
      version: reader.readInt(),
      algorithm: reader.readString(),
      nonce: reader.readString(),
      cipherText: reader.readString(),
      authenticationTag: reader.readString(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        reader.readInt(),
        isUtc: true,
      ),
      camouflageEnabled: reader.readBool(),
      subject: reader.readNullableString(),
    );
  }

  // ---------------------------------------------------------------------------
  // Writers
  // ---------------------------------------------------------------------------

  void _writeInt(
    BytesBuilder builder,
    int value,
  ) {
    final ByteData data = ByteData(8)..setInt64(0, value);
    builder.add(data.buffer.asUint8List());
  }

  void _writeBool(
    BytesBuilder builder,
    bool value,
  ) {
    builder.addByte(value ? 1 : 0);
  }

  void _writeString(
    BytesBuilder builder,
    String value,
  ) {
    final List<int> bytes = utf8.encode(value);
    _writeInt(builder, bytes.length);
    builder.add(bytes);
  }

  void _writeNullableString(
    BytesBuilder builder,
    String? value,
  ) {
    if (value == null) {
      _writeInt(builder, -1);
      return;
    }

    _writeString(builder, value);
  }
}

// ---------------------------------------------------------------------------
// Binary Reader
// ---------------------------------------------------------------------------

class _BinaryReader {
  // ---------------------------------------------------------------------------
  // Constructor
  // ---------------------------------------------------------------------------

  _BinaryReader(this._bytes);

  // ---------------------------------------------------------------------------
  // Properties
  // ---------------------------------------------------------------------------

  final Uint8List _bytes;

  int _offset = 0;

  // ---------------------------------------------------------------------------
  // Readers
  // ---------------------------------------------------------------------------

  int readInt() {
    _ensureAvailable(8);

    final ByteData data = ByteData.sublistView(
      _bytes,
      _offset,
      _offset + 8,
    );

    _offset += 8;

    return data.getInt64(0);
  }

  bool readBool() {
    _ensureAvailable(1);

    final int value = _bytes[_offset];
    _offset += 1;

    return value == 1;
  }

  String readString() {
    final int length = readInt();

    if (length < 0) {
      throw const FormatException('Invalid CAMO string length.');
    }

    _ensureAvailable(length);

    final String value = utf8.decode(
      _bytes.sublist(
        _offset,
        _offset + length,
      ),
    );

    _offset += length;

    return value;
  }

  String? readNullableString() {
    final int length = readInt();

    if (length == -1) {
      return null;
    }

    if (length < -1) {
      throw const FormatException('Invalid CAMO nullable string length.');
    }

    _ensureAvailable(length);

    final String value = utf8.decode(
      _bytes.sublist(
        _offset,
        _offset + length,
      ),
    );

    _offset += length;

    return value;
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  void _ensureAvailable(
    int length,
  ) {
    if (_offset + length > _bytes.length) {
      throw const FormatException('Invalid CAMO binary payload.');
    }
  }
}