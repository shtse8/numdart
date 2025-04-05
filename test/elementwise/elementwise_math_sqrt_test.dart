import 'dart:typed_data';
import 'dart:math' as math; // For isNaN checks
import 'package:test/test.dart';
import 'package:numdart/numdart.dart'; // Import main library
import 'package:collection/collection.dart';

// No 'part of' needed

void main() {
  // Main entry point for this test file
  group('NdArray Square Root (sqrt)', () {
    // Call individual test functions directly within the group
    testSqrt1DInteger();
    testSqrt1DDouble();
    testSqrt2D();
    testSqrtWithNegativeNumbers();
    testSqrtEmptyArray();
    testSqrtView();
  });
}

void testSqrt1DInteger() {
  test('sqrt of 1D Integer Array', () {
    var a = NdArray.array([0, 1, 4, 9, 16, 25]); // Use static method
    var expected = NdArray.array([0.0, 1.0, 2.0, 3.0, 4.0, 5.0],
        dtype: Float64List); // Use static method
    var result = a.sqrt();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void testSqrt1DDouble() {
  test('sqrt of 1D Double Array', () {
    var a = NdArray.array([0.0, 1.0, 2.25, 6.25]); // Use static method
    var expected = NdArray.array([0.0, 1.0, 1.5, 2.5],
        dtype: Float64List); // Use static method
    var result = a.sqrt();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void testSqrt2D() {
  test('sqrt of 2D Array', () {
    var a = NdArray.array([
      // Use static method
      [4, 9],
      [1, 16]
    ]);
    var expected = NdArray.array([
      // Use static method
      [2.0, 3.0],
      [1.0, 4.0]
    ], dtype: Float64List);
    var result = a.sqrt();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testSqrtWithNegativeNumbers() {
  test('sqrt with Negative Numbers (results in NaN)', () {
    var a = NdArray.array([4.0, -9.0, 16.0, -1.0]); // Use static method
    var result = a.sqrt();
    expect(result.shape, equals([4]));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    var listResult = result.toList();
    expect(listResult[0], equals(2.0));
    expect(listResult[1].isNaN, isTrue);
    expect(listResult[2], equals(4.0));
    expect(listResult[3].isNaN, isTrue);
  });
}

void testSqrtEmptyArray() {
  test('sqrt of Empty Array', () {
    var a = NdArray.zeros([0]); // Use static method
    var expected = NdArray.zeros([0], dtype: Float64List); // Use static method
    var result = a.sqrt();

    expect(result.shape, equals(expected.shape));
    expect(result.size, equals(0));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));

    var c = NdArray.zeros([2, 0], dtype: Int32List); // Use static method
    var expected2 =
        NdArray.zeros([2, 0], dtype: Float64List); // Use static method
    var result2 = c.sqrt();
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

void testSqrtView() {
  test('sqrt of View', () {
    var base = NdArray.array([
      // Use static method
      [1, 4, 9],
      [16, 25, 36]
    ]);
    var view = base[[Slice(null, null), Slice(1, null)]]; // [[4, 9], [25, 36]]
    var expected = NdArray.array([
      // Use static method
      [2.0, 3.0],
      [5.0, 6.0]
    ], dtype: Float64List);
    var result = view.sqrt();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}
