import 'dart:typed_data';
import 'dart:math' as math; // Import math library with prefix
import 'package:test/test.dart';
import 'package:numdart/numdart.dart'; // Import main library
import 'package:collection/collection.dart';

// No 'part of' needed

void main() {
  // Main entry point for this test file
  group('NdArray Exponential (exp)', () {
    // Call individual test functions directly within the group
    testExp1DInteger();
    testExp1DDouble();
    testExp2D();
    testExpEmptyArray();
    testExpView();
  });
}

void testExp1DInteger() {
  test('exp of 1D Integer Array', () {
    var a = NdArray.array([0, 1, 2, -1]); // Use static method
    var expected = NdArray.array([
      math.exp(0),
      math.exp(1),
      math.exp(2),
      math.exp(-1)
    ], // Use static method
        dtype: Float64List);
    var result = a.exp();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    // Use closeTo for floating point comparisons
    for (int i = 0; i < result.size; i++) {
      expect(result.toList()[i], closeTo(expected.toList()[i], 1e-9));
    }
  });
}

void testExp1DDouble() {
  test('exp of 1D Double Array', () {
    var a = NdArray.array([0.0, 1.0, -0.5, 2.5]); // Use static method
    var expected = NdArray.array(// Use static method
        [math.exp(0.0), math.exp(1.0), math.exp(-0.5), math.exp(2.5)],
        dtype: Float64List);
    var result = a.exp();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    for (int i = 0; i < result.size; i++) {
      expect(result.toList()[i], closeTo(expected.toList()[i], 1e-9));
    }
  });
}

void testExp2D() {
  test('exp of 2D Array', () {
    var a = NdArray.array([
      // Use static method
      [0, 1],
      [-1, 2]
    ]);
    var expected = NdArray.array([
      // Use static method
      [math.exp(0), math.exp(1)],
      [math.exp(-1), math.exp(2)]
    ], dtype: Float64List);
    var result = a.exp();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList()[0][0], closeTo(expected.toList()[0][0], 1e-9));
    expect(result.toList()[0][1], closeTo(expected.toList()[0][1], 1e-9));
    expect(result.toList()[1][0], closeTo(expected.toList()[1][0], 1e-9));
    expect(result.toList()[1][1], closeTo(expected.toList()[1][1], 1e-9));
  });
}

void testExpEmptyArray() {
  test('exp of Empty Array', () {
    var a = NdArray.zeros([0]); // Use static method
    var expected = NdArray.zeros([0], dtype: Float64List); // Use static method
    var result = a.exp();
    expect(result.shape, equals(expected.shape));
    expect(result.size, equals(0));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));

    var c = NdArray.zeros([2, 0], dtype: Int32List); // Use static method
    var expected2 =
        NdArray.zeros([2, 0], dtype: Float64List); // Use static method
    var result2 = c.exp();
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

void testExpView() {
  test('exp of View', () {
    var base = NdArray.array([
      // Use static method
      [0, 1, 2],
      [3, 4, 5]
    ]);
    var view = base[[Slice(null, null), Slice(1, null)]]; // [[1, 2], [4, 5]]
    var expected = NdArray.array([
      // Use static method
      [math.exp(1), math.exp(2)],
      [math.exp(4), math.exp(5)]
    ], dtype: Float64List);
    var result = view.exp();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList()[0][0], closeTo(expected.toList()[0][0], 1e-9));
    expect(result.toList()[0][1], closeTo(expected.toList()[0][1], 1e-9));
    expect(result.toList()[1][0], closeTo(expected.toList()[1][0], 1e-9));
    expect(result.toList()[1][1], closeTo(expected.toList()[1][1], 1e-9));
    // Ensure original base array is unchanged
    expect(
        base.toList(),
        equals([
          [0, 1, 2],
          [3, 4, 5]
        ]));
  });
}
