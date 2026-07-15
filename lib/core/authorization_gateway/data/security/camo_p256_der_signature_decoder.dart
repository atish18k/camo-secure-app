final class CamoP256DerSignatureDecoder {
  const CamoP256DerSignatureDecoder();

  static const int _coordinateLength = 32;
  static const int _rawSignatureLength = 64;

  List<int> decode(List<int> derSignature) {
    if (derSignature.isEmpty) {
      throw const FormatException('DER signature is empty.');
    }

    int offset = 0;

    int readByte() {
      if (offset >= derSignature.length) {
        throw const FormatException('DER signature ended unexpectedly.');
      }

      return derSignature[offset++];
    }

    int readLength() {
      final int value = readByte();

      if ((value & 0x80) != 0) {
        throw const FormatException(
          'Long-form DER lengths are not allowed for P-256 signatures.',
        );
      }

      return value;
    }

    if (readByte() != 0x30) {
      throw const FormatException('DER signature must begin with a sequence.');
    }

    final int sequenceLength = readLength();

    if (sequenceLength != derSignature.length - offset) {
      throw const FormatException('DER signature sequence length is invalid.');
    }

    List<int> readInteger(String componentName) {
      if (readByte() != 0x02) {
        throw FormatException(
          'DER signature $componentName component is not an integer.',
        );
      }

      final int integerLength = readLength();

      if (integerLength < 1 || integerLength > _coordinateLength + 1) {
        throw FormatException(
          'DER signature $componentName length is invalid.',
        );
      }

      if (offset + integerLength > derSignature.length) {
        throw FormatException('DER signature $componentName is truncated.');
      }

      final List<int> encoded = List<int>.of(
        derSignature.sublist(offset, offset + integerLength),
        growable: false,
      );

      offset += integerLength;

      if ((encoded.first & 0x80) != 0) {
        throw FormatException(
          'DER signature $componentName must not be negative.',
        );
      }

      List<int> magnitude = encoded;

      if (encoded.first == 0x00) {
        if (encoded.length == 1 || (encoded[1] & 0x80) == 0) {
          throw FormatException(
            'DER signature $componentName has non-minimal padding.',
          );
        }

        magnitude = encoded.sublist(1);
      }

      if (magnitude.length > _coordinateLength) {
        throw FormatException(
          'DER signature $componentName exceeds P-256 size.',
        );
      }

      if (magnitude.every((int value) => value == 0)) {
        throw FormatException('DER signature $componentName must not be zero.');
      }

      return List<int>.unmodifiable(<int>[
        ...List<int>.filled(_coordinateLength - magnitude.length, 0),
        ...magnitude,
      ]);
    }

    final List<int> r = readInteger('r');
    final List<int> s = readInteger('s');

    if (offset != derSignature.length) {
      throw const FormatException('DER signature contains trailing bytes.');
    }

    final List<int> rawSignature = <int>[...r, ...s];

    if (rawSignature.length != _rawSignatureLength) {
      throw const FormatException('Decoded P-256 signature length is invalid.');
    }

    return List<int>.unmodifiable(rawSignature);
  }
}
