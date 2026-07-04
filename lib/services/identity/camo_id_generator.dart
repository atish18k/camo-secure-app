import 'dart:math';

class CamoIdGenerator {
  static const _chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  final Random _random;

  CamoIdGenerator({
  Random? random,
}) : _random = random ?? Random.secure();

  String generate() {
    final first = _generateBlock(4);
    final second = _generateBlock(4);

    return 'CM-$first-$second';
  }

  String _generateBlock(int length) {
    return List.generate(
      length,
      (_) => _chars[_random.nextInt(_chars.length)],
    ).join();
  }
}