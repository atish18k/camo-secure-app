import 'camo_decode_key_material.dart';

abstract interface class CamoDecodeKeyMaterialProvider {
  Future<CamoDecodeKeyMaterial> resolve({required String pairingId});
}
