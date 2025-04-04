import 'dart:typed_data';
import 'dart:math' as math; // Import math library with prefix
import 'package:test/test.dart';
import 'package:numdart/numdart.dart'; // Import main library
import 'package:collection/collection.dart';

// No 'part of' needed

void main() {
  // Main entry point for this test file
  group('NdArray Natural Logarithm (log)', () {
    // Call individual test functions directly within the group
    testLog1DInteger();
    testLog1DDouble();
    testLog2D();
    testLogWithZeroAndNegative();
    testLogEmptyArray();
    testLogView();
  });
}

void testLog1DInteger() {
  test('log of 1D Integer Array', () {
    var a = NdArray.array([1, 2, 3]); // Use static method
    var expected = NdArray.array([math.log(1), math.log(2), math.log(3)],
        dtype: Float64List); // Use static method
    var result = a.log();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    for (int i = 0; i < result.size; i++) {
      expect(result.toList()[i], closeTo(expected.toList()[i], 1e-9));
    }
  });
}

void testLog1DDouble() {
  test('log of 1D Double Array', () {
    var a = NdArray.array([1.0, math.e, 10.0]); // Use static method
    var expected = NdArray.array([0.0, 1.0, math.log(10.0)],
        dtype: Float64List); // Use static method
    var result = a.log();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    for (int i = 0; i < result.size; i++) {
      expect(result.toList()[i], closeTo(expected.toList()[i], 1e-9));
    }
  });
}

void testLog2D() {
  test('log of 2D Array', () {
    var a = NdArray.array([
      // Use static method
      [1.0, math.e],
      [10.0, 0.5]
    ]);
    var expected = NdArray.array([
      // Use static method
      [0.0, 1.0],
      [math.log(10.0), math.log(0.5)]
    ], dtype: Float64List);
    var result = a.log();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList()[0][0], closeTo(expected.toList()[0][0], 1e-9));
    expect(result.toList()[0][1], closeTo(expected.toList()[0][1], 1e-9));
    expect(result.toList()[1][0], closeTo(expected.toList()[1][0], 1e-9));
    expect(result.toList()[1][1], closeTo(expected.toList()[1][1], 1e-9));
  });
}

void testLogWithZeroAndNegative() {
  // Test log with 0 and negative numbers (should result in -Infinity and NaN)
  test('log with zero and negative numbers', () {
    var a = NdArray.array([1.0, 0.0, -1.0, math.e]); // Use static method
    var result = a.log();
    expect(result.dtype, equals(double));
    var listResult = result.toList();
    expect(listResult[0], closeTo(0.0, 1e-9)); // log(1) = 0
    expect(listResult[1].isNegativeInfinity, isTrue); // log(0) = -Infinity
    expect(listResult[2].isNaN, isTrue); // log(-1) = NaN
    expect(listResult[3], closeTo(1.0, 1e-9)); // log(e) = 1
  });
}

void testLogEmptyArray() {
  test('log of Empty Array', () {
    var a = NdArray.zeros([0]); // Use static method
    var expected = NdArray.zeros([0], dtype: Float64List); // Use static method
    var result = a.log();
    expect(result.shape, equals(expected.shape));
    expect(result.size, equals(0));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));

    var c = NdArray.zeros([2, 0], dtype: Int32List); // Use static method
    var expected2 =
        NdArray.zeros([2, 0], dtype: Float64List); // Use static method
    var result2 = c.log();
    expect(result2.shape, equals(expected2.shape));
    expect(result2.size, equals(0));
    expect(result2.dtype, equals(double));
    expect(result2.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality()
            .equals(result2.toList(), expected2.toList()),
        isTrue);
  });
}

void testLogView() {
  test('log of View', () {
    var base = NdArray.array([
      // Use static method
      [1.0, math.e, 10.0],
      [0.1, 0.0, -5.0] // Include 0 and negative for edge cases
    ]);
    var view = base[[Slice(null, null), Slice(1, null)]]; // [[e, 10], [0, -5]]
    var expected = NdArray.array([
      // Use static method
      [1.0, math.log(10.0)],
      [double.negativeInfinity, double.nan]
    ], dtype: Float64List);
    var result = view.log();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList()[0][0], closeTo(expected.toList()[0][0], 1e-9));
    expect(result.toList()[0][1], closeTo(expected.toList()[0][1], 1e-9));
    expect(result.toList()[1][0].isNegativeInfinity, isTrue);
    expect(result.toList()[1][1].isNaN, isTrue);
    // Ensure original base array is unchanged
    expect(base.toList()[1][2], equals(-5)); // Check a value
  });
}
