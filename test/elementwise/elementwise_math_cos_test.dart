import 'dart:typed_data';
import 'dart:math' as math; // Import math library with prefix
import 'package:test/test.dart';
import 'package:numdart/numdart.dart'; // Import main library
import 'package:collection/collection.dart';

// No 'part of' needed

void main() {
  // Main entry point for this test file
  group('NdArray Cosine (cos)', () {
    // Call individual test functions directly within the group
    testCos1DInteger();
    testCos1DDouble();
    testCos2D();
    testCosEmptyArray();
    testCosView();
  });
}

void testCos1DInteger() {
  test('cos of 1D Integer Array (as radians)', () {
    var a = NdArray.array([0, 1, 2]); // Use static method
    var expected = NdArray.array([math.cos(0), math.cos(1), math.cos(2)],
        dtype: Float64List); // Use static method
    var result = a.cos();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    for (int i = 0; i < result.size; i++) {
      expect(result.toList()[i], closeTo(expected.toList()[i], 1e-9));
    }
  });
}

void testCos1DDouble() {
  test('cos of 1D Double Array (radians)', () {
    var a = NdArray.array([
      0.0,
      math.pi / 2,
      math.pi,
      3 * math.pi / 2,
      2 * math.pi
    ]); // Use static method
    var expected = NdArray.array([1.0, 0.0, -1.0, 0.0, 1.0],
        dtype: Float64List); // Use static method
    var result = a.cos();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    for (int i = 0; i < result.size; i++) {
      expect(result.toList()[i], closeTo(expected.toList()[i], 1e-9));
    }
  });
}

void testCos2D() {
  test('cos of 2D Array (radians)', () {
    var a = NdArray.array([
      // Use static method
      [0, math.pi / 2],
      [math.pi, 3 * math.pi / 2]
    ]);
    var expected = NdArray.array([
      // Use static method
      [1.0, 0.0],
      [-1.0, 0.0]
    ], dtype: Float64List);
    var result = a.cos();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList()[0][0], closeTo(expected.toList()[0][0], 1e-9));
    expect(result.toList()[0][1], closeTo(expected.toList()[0][1], 1e-9));
    expect(result.toList()[1][0], closeTo(expected.toList()[1][0], 1e-9));
    expect(result.toList()[1][1], closeTo(expected.toList()[1][1], 1e-9));
  });
}

void testCosEmptyArray() {
  test('cos of Empty Array', () {
    var a = NdArray.zeros([0]); // Use static method
    // cos(0) is 1, but for empty array...
    // Let's refine: expected should be empty float array
    var expected = NdArray.array([], dtype: Float64List); // Use static method
    var result = a.cos();
    expect(result.shape, equals(expected.shape));
    expect(result.size, equals(0));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));

    var c = NdArray.zeros([2, 0], dtype: Int32List); // Use static method
    var expected2 =
        NdArray.zeros([2, 0], dtype: Float64List); // Use static method
    var result2 = c.cos();
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

void testCosView() {
  test('cos of View', () {
    var base = NdArray.array([
      // Use static method
      [0, math.pi / 2, math.pi],
      [math.pi, 3 * math.pi / 2, 2 * math.pi]
    ]);
    var view =
        base[[Slice(null, null), Slice(1, null)]]; // [[pi/2, pi], [3pi/2, 2pi]]
    var expected = NdArray.array([
      // Use static method
      [0.0, -1.0],
      [0.0, 1.0]
    ], dtype: Float64List);
    var result = view.cos();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList()[0][0], closeTo(expected.toList()[0][0], 1e-9));
    expect(result.toList()[0][1], closeTo(expected.toList()[0][1], 1e-9));
    expect(result.toList()[1][0], closeTo(expected.toList()[1][0], 1e-9));
    expect(result.toList()[1][1], closeTo(expected.toList()[1][1], 1e-9));
    // Ensure original base array is unchanged
    expect(base.toList()[0][1], closeTo(math.pi / 2, 1e-9)); // Check a value
  });
}
