import 'dart:typed_data';

import '../entities/camo_payload_packet.dart';

abstract class CamoPayloadParser {
  CamoPayloadPacket parse(Uint8List bytes);
}