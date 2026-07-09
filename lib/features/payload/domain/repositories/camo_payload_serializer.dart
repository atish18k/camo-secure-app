import 'dart:typed_data';

import '../entities/camo_payload_packet.dart';

abstract class CamoPayloadSerializer {
  Uint8List serialize(CamoPayloadPacket packet);
}