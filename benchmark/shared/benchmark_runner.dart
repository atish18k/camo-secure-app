import 'dart:io';

class BenchmarkRunner {
  const BenchmarkRunner({
    required this.name,
    required this.warmUpIterations,
    required this.measuredIterations,
    required this.operation,
  });

  final String name;
  final int warmUpIterations;
  final int measuredIterations;
  final Future<void> Function() operation;

  Future<void> run() async {
    for (int i = 0; i < warmUpIterations; i++) {
      await operation();
    }

    final Stopwatch stopwatch = Stopwatch()..start();

    for (int i = 0; i < measuredIterations; i++) {
      await operation();
    }

    stopwatch.stop();

    final int totalMicroseconds = stopwatch.elapsedMicroseconds;
    final double averageMicroseconds = totalMicroseconds / measuredIterations;
    final double operationsPerSecond =
        measuredIterations / (totalMicroseconds / 1000000);

    stdout.writeln('----------------------------------------');
    stdout.writeln('Benchmark: $name');
    stdout.writeln('Iterations: $measuredIterations');
    stdout.writeln('Total: $totalMicrosecondsµs');
    stdout.writeln('Average: ${averageMicroseconds.toStringAsFixed(2)}µs/op');
    stdout.writeln('Ops/sec: ${operationsPerSecond.toStringAsFixed(2)}');
    stdout.writeln('----------------------------------------');
  }
}