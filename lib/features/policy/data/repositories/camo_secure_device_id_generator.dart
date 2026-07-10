// ---------------------------------------------------------------------------
// Imports
// ---------------------------------------------------------------------------

import 'dart:math';
import 'dart:typed_data';

import '../../domain/repositories/camo_device_id_generator.dart';

// ---------------------------------------------------------------------------
// CAMO Secure Device ID Generator
// ---------------------------------------------------------------------------

/// Generates privacy-preserving UUID v4 compatible device identifiers using
/// the operating system's cryptographically secure random source.
///
/// This generator does not read or expose hardware identifiers.
class CamoSecureDeviceIdGenerator implements CamoDeviceIdGenerator {
  CamoSecureDeviceIdGenerator({
    Random? secureRandom,
  }) : _secureRandom = secureRandom ?? Random.secure();

  // ---------------------------------------------------------------------------
  // Dependencies
  // ---------------------------------------------------------------------------

  final Random _secureRandom;

  // ---------------------------------------------------------------------------
  // Generate
  // ---------------------------------------------------------------------------

  @override
  String generate() {
    final Uint8List bytes = Uint8List(16);

    for (int index = 0; index < bytes.length; index++) {
      bytes[index] = _secureRandom.nextInt(256);
    }

    // UUID version 4.
    bytes[6] = (bytes[6] & 0x0f) | 0x40;

    // RFC 4122 variant.
    bytes[8] = (bytes[8] & 0x3f) | 0x80;

    final String value = bytes
        .map(
          (int byte) => byte.toRadixString(16).padLeft(2, '0'),
        )
        .join();

    return '${value.substring(0, 8)}-'
        '${value.substring(8, 12)}-'
        '${value.substring(12, 16)}-'
        '${value.substring(16, 20)}-'
        '${value.substring(20, 32)}';
  }
}