import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:numdart/numdart.dart'; // Assuming numdart.dart exports NdArray

// Helper function to create a benchmark emitter
// (This might be moved to a shared benchmark utility file later)
class _NumDartEmitter implements ScoreEmitter {
  final String _reportName;
  const _NumDartEmitter(this._reportName);

  @override
  void emit(String testName, double value) {
    print('$_reportName/$testName(RunTime): $value us.'); // us = microseconds
  }
}

// Benchmark for NdArray.zeros creation
class ZerosCreationBenchmark extends BenchmarkBase {
  final List<int> shape;
  final Type dtype;

  ZerosCreationBenchmark(this.shape, this.dtype, {required String name})
      : super(name, emitter: _NumDartEmitter(name));

  @override
  void run() {
    NdArray.zeros(shape, dtype: dtype);
  }

  // Optional: Override setup/teardown if needed
  // @override
  // void setup() { ... }
  // @override
  // void teardown() { ... }

  // Optional: Override exercise to run multiple times per measurement
  // @override
  // void exercise() => List.generate(10, (_) => run());
}

// Benchmark for NdArray.array creation (from List)
class ArrayCreationBenchmark extends BenchmarkBase {
  final List sourceList;
  final List<int> shape; // Expected shape after creation
  final Type dtype;

  ArrayCreationBenchmark(this.sourceList, this.shape, this.dtype,
      {required String name})
      : super(name, emitter: _NumDartEmitter(name));

  @override
  void run() {
    NdArray.array(sourceList, dtype: dtype);
  }
}

void main() {
  // --- Zeros Benchmarks ---
  ZerosCreationBenchmark([100], int, name: 'Zeros_1D_100_int').report();
  ZerosCreationBenchmark([1000], int, name: 'Zeros_1D_1000_int').report();
  ZerosCreationBenchmark([100, 100], double, name: 'Zeros_2D_100x100_double')
      .report();
  ZerosCreationBenchmark([10, 10, 100], int, name: 'Zeros_3D_10x10x100_int')
      .report();

  // --- Array Benchmarks ---
  final list1D_100 = List.generate(100, (i) => i);
  final list2D_100x100 =
      List.generate(100, (_) => List.generate(100, (j) => j.toDouble()));

  ArrayCreationBenchmark(list1D_100, [100], int, name: 'Array_1D_100_int')
      .report();
  ArrayCreationBenchmark(list2D_100x100, [100, 100], double,
          name: 'Array_2D_100x100_double')
      .report();

  // Add more benchmarks for different shapes, dtypes, and creation functions (ones, arange etc.)
}
