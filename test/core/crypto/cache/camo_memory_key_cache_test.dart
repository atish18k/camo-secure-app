import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:camo/core/crypto/cache/camo_memory_key_cache.dart';

void main() {
  group('CamoMemoryKeyCache', () {
    late CamoMemoryKeyCache cache;

    setUp(() {
      cache = CamoMemoryKeyCache();
    });

    test('cache is empty initially', () {
      expect(cache.get('pair-1'), isNull);
    });

    test('put stores a key', () {
      final key = Uint8List.fromList(
        List<int>.generate(32, (index) => index),
      );

      cache.put(
        pairId: 'pair-1',
        key: key,
      );

      final entry = cache.get('pair-1');

      expect(entry, isNotNull);
      expect(entry!.key, key);
    });

    test('remove deletes only one entry', () {
      cache.put(
        pairId: 'pair-1',
        key: Uint8List.fromList([1, 2, 3]),
      );

      cache.put(
        pairId: 'pair-2',
        key: Uint8List.fromList([4, 5, 6]),
      );

      cache.remove('pair-1');

      expect(cache.get('pair-1'), isNull);
      expect(cache.get('pair-2'), isNotNull);
    });

    test('clear removes all entries', () {
      cache.put(
        pairId: 'pair-1',
        key: Uint8List.fromList([1]),
      );

      cache.put(
        pairId: 'pair-2',
        key: Uint8List.fromList([2]),
      );

      cache.clear();

      expect(cache.get('pair-1'), isNull);
      expect(cache.get('pair-2'), isNull);
    });

    test('returned key matches stored key', () {
      final key = Uint8List.fromList(
        List<int>.generate(32, (index) => index + 10),
      );

      cache.put(
        pairId: 'pair-100',
        key: key,
      );

      final entry = cache.get('pair-100');

      expect(entry, isNotNull);
      expect(entry!.key, key);
    });
  });
}