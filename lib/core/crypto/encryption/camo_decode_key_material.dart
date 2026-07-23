import 'dart:typed_data';

final class CamoDecodeKeyMaterial {
  CamoDecodeKeyMaterial({
    required Uint8List deviceSharedSecret,
    required Uint8List salt,
  }) : deviceSharedSecret = Uint8List.fromList(deviceSharedSecret),
       salt = Uint8List.fromList(salt);

  final Uint8List deviceSharedSecret;
  final Uint8List salt;

  bool get isValid {
    return deviceSharedSecret.isNotEmpty && salt.isNotEmpty;
  }
}
