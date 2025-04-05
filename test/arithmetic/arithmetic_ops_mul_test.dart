import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:numdart/numdart.dart'; // Import main library
import 'package:collection/collection.dart';
import 'dart:math' as math; // Import math for arange if needed later

// No 'part of' needed

void main() {
  // Main entry point for this test file
  group('NdArray Multiplication (operator*)', () {
    // Call individual test functions directly within the group
    testMultiplication1DInteger();
    testMultiplication1DDouble();
    testMultiplicationWithZero();
    testMultiplication2DInteger();
    testMultiplicationWithViews();
    testMultiplicationOfEmptyArrays();
    testScalarMultiplicationInt();
    testScalarMultiplicationDouble();
    testScalarMultiplicationWithTypePromotion();
    testScalarMultiplicationWith2DArray();
    testScalarMultiplicationWithView();
    testScalarMultiplicationWithEmptyArray();
    testThrowsArgumentErrorForInvalidScalarTypeMultiplication();
    testBroadcastingMultiplicationRow();
    testBroadcastingMultiplicationColumn();
    testThrowsArgumentErrorForIncompatibleBroadcastShapesMultiplication();
    testTypePromotionMultiplicationIntDouble();
    testTypePromotionMultiplicationDoubleInt();
    testTypePromotionMultiplicationWithBroadcastingIntDouble();
    testTypePromotionMultiplicationWithBroadcastingDoubleInt();
    testBroadcastingMultiplication3DWith2D();
    testBroadcastingMultiplicationMultipleOnes();
    testBroadcastingMultiplicationWithSteppedView();
    testBroadcastingMultiplicationArrayWithScalarArray();
    testBroadcastingMultiplicationScalarArrayWithArray();
    testBroadcastingMultiplicationViewWithScalarArray();
  });
}

void testMultiplication1DInteger() {
  test('1D Integer Multiplication', () {
    var a = NdArray.array([1, 2, 3]); // Use static method
    var b = NdArray.array([4, 5, 6]);
    var expected = NdArray.array([4, 10, 18]);
    var result = a * b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(result.toList(), equals(expected.toList()));
  });
}

void testMultiplication1DDouble() {
  test('1D Double Multiplication', () {
    var a = NdArray.array([1.0, 2.5, 3.0]);
    var b = NdArray.array([4.0, 0.5, 2.0]);
    var expected = NdArray.array([4.0, 1.25, 6.0]);
    var result = a * b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.toList(), equals(expected.toList()));
  });
}

void testMultiplicationWithZero() {
  test('Multiplication with zero', () {
    var a = NdArray.array([1, 2, 3]);
    var b = NdArray.zeros([3], dtype: Int64List); // Use static method
    var expected = NdArray.zeros([3], dtype: Int64List);
    var result = a * b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(result.toList(), equals(expected.toList()));

    var c = NdArray.array([0.0, 5.0, 0.0]);
    var d = NdArray.array([10.0, 0.0, 20.0]);
    var expected2 = NdArray.array([0.0, 0.0, 0.0]);
    var result2 = c * d;
    expect(result2.shape, equals(expected2.shape));
    expect(result2.dtype, equals(double));
    expect(result2.toList(), equals(expected2.toList()));
  });
}

void testMultiplication2DInteger() {
  test('2D Integer Multiplication', () {
    var a = NdArray.array([
      [1, 2],
      [3, 4]
    ]);
    var b = NdArray.array([
      [5, 6],
      [7, 8]
    ]);
    var expected = NdArray.array([
      [5, 12],
      [21, 32]
    ]);
    var result = a * b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality() // Corrected typo
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testMultiplicationWithViews() {
  test('Multiplication with Views (Slices)', () {
    var base = NdArray.arange(10); // Use static method
    var a = base[[Slice(1, 5)]];
    var b = base[[Slice(5, 9)]];
    var expected = NdArray.array([5, 12, 21, 32]);
    var result = a * b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(result.toList(), equals(expected.toList()));
    expect(base.toList(), equals([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]));
  });
}

void testMultiplicationOfEmptyArrays() {
  test('Multiplication of Empty Arrays', () {
    var a = NdArray.zeros([0]);
    var b = NdArray.zeros([0]);
    var expected = NdArray.zeros([0]);
    var result = a * b;
    expect(result.shape, equals(expected.shape));
    expect(result.size, equals(0));
    expect(result.dtype, equals(double));
    expect(result.toList(), equals(expected.toList()));

    var c = NdArray.zeros([2, 0], dtype: Int32List);
    var d = NdArray.zeros([2, 0], dtype: Int32List);
    var expected2 = NdArray.zeros([2, 0], dtype: Int64List);
    var result2 = c * d;
    expect(result2.shape, equals(expected2.shape));
    expect(result2.size, equals(0));
    expect(result2.dtype, equals(int));
    expect(
        const DeepCollectionEquality() // Corrected typo
            .equals(result2.toList(), expected2.toList()),
        isTrue);
  });
}

void testScalarMultiplicationInt() {
  test('Scalar Multiplication (NdArray * int)', () {
    var a = NdArray.array([1, 2, 3]);
    var scalar = 10;
    var expected = NdArray.array([10, 20, 30]);
    var result = a * scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(result.toList(), equals(expected.toList()));
  });
}

void testScalarMultiplicationDouble() {
  test('Scalar Multiplication (NdArray * double)', () {
    var a = NdArray.array([1.0, 2.5, 3.0]);
    var scalar = 2.0;
    var expected = NdArray.array([2.0, 5.0, 6.0]);
    var result = a * scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.toList(), equals(expected.toList()));
  });
}

void testScalarMultiplicationWithTypePromotion() {
  test('Scalar Multiplication with Type Promotion (int Array * double scalar)',
      () {
    var a = NdArray.array([1, 2, 3]);
    var scalar = 0.5;
    var expected = NdArray.array([0.5, 1.0, 1.5], dtype: Float64List);
    var result = a * scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void testScalarMultiplicationWith2DArray() {
  test('Scalar Multiplication with 2D Array', () {
    var a = NdArray.array([
      [1, 2],
      [3, 4]
    ]);
    var scalar = 3;
    var expected = NdArray.array([
      [3, 6],
      [9, 12]
    ]);
    var result = a * scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality() // Corrected typo
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testScalarMultiplicationWithView() {
  test('Scalar Multiplication with View', () {
    var base = NdArray.arange(6).reshape([2, 3]);
    var view = base[[Slice(null, null), Slice(1, null)]];
    var scalar = 2;
    var expected = NdArray.array([
      [2, 4],
      [8, 10]
    ]);
    var result = view * scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality() // Corrected typo
            .equals(result.toList(), expected.toList()),
        isTrue);
    expect(
        base.toList(),
        equals([
          [0, 1, 2],
          [3, 4, 5]
        ]));
  });
}

void testScalarMultiplicationWithEmptyArray() {
  test('Scalar Multiplication with Empty Array', () {
    var a = NdArray.zeros([0]);
    var scalar = 5;
    var expected = NdArray.zeros([0]);
    var result = a * scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.size, equals(0));
    expect(result.dtype, equals(double));
    expect(result.toList(), equals(expected.toList()));
  });
}

void testThrowsArgumentErrorForInvalidScalarTypeMultiplication() {
  test('Throws ArgumentError for invalid scalar type', () {
    var a = NdArray.array([1, 2, 3]);
    expect(() => a * 'hello', throwsArgumentError);
    expect(() => a * true, throwsArgumentError);
    expect(() => a * null, throwsArgumentError);
  });
}

void testBroadcastingMultiplicationRow() {
  test('Broadcasting Multiplication: 2D * 1D (Row)', () {
    var a = NdArray.array([
      [1, 2, 3],
      [4, 5, 6]
    ]);
    var b = NdArray.array([10, 20, 30]);
    var expected = NdArray.array([
      [10, 40, 90],
      [40, 100, 180]
    ]);
    var result = a * b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality() // Corrected typo
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testBroadcastingMultiplicationColumn() {
  test('Broadcasting Multiplication: 2D * 1D (Column)', () {
    var a = NdArray.array([
      [1, 2, 3],
      [4, 5, 6]
    ]);
    var b = NdArray.array([
      [10],
      [20]
    ]);
    var expected = NdArray.array([
      [10, 20, 30],
      [80, 100, 120]
    ]);
    var result = a * b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality() // Corrected typo
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testThrowsArgumentErrorForIncompatibleBroadcastShapesMultiplication() {
  test('Throws ArgumentError for incompatible broadcast shapes', () {
    var a = NdArray.array([
      [1, 2, 3],
      [4, 5, 6]
    ]);
    var b = NdArray.array([10, 20]);
    expect(() => a * b, throwsArgumentError);
  });
}

void testTypePromotionMultiplicationIntDouble() {
  test('Type Promotion Multiplication: int * double', () {
    var a = NdArray.array([1, 2, 3], dtype: Int32List);
    var b = NdArray.array([0.5, 2.0, 1.5], dtype: Float64List);
    var expected = NdArray.array([0.5, 4.0, 4.5], dtype: Float64List);
    var result = a * b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void testTypePromotionMultiplicationDoubleInt() {
  test('Type Promotion Multiplication: double * int', () {
    var a = NdArray.array([0.5, 2.0, 1.5], dtype: Float64List);
    var b = NdArray.array([2, 3, 4], dtype: Int32List);
    var expected = NdArray.array([1.0, 6.0, 6.0], dtype: Float64List);
    var result = a * b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void testTypePromotionMultiplicationWithBroadcastingIntDouble() {
  test('Type Promotion Multiplication with Broadcasting: int[2,3] * double[3]',
      () {
    var a = NdArray.array([
      [1, 2, 3],
      [4, 5, 6]
    ], dtype: Int32List);
    var b = NdArray.array([0.5, 2.0, 1.0], dtype: Float64List);
    var expected = NdArray.array([
      [0.5, 4.0, 3.0],
      [2.0, 10.0, 6.0]
    ], dtype: Float64List);
    var result = a * b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality() // Corrected typo
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testTypePromotionMultiplicationWithBroadcastingDoubleInt() {
  test(
      'Type Promotion Multiplication with Broadcasting: double[2,1] * int[2,3]',
      () {
    var a = NdArray.array([
      [0.5],
      [2.0]
    ], dtype: Float64List);
    var b = NdArray.array([
      [1, 2, 3],
      [4, 5, 6]
    ], dtype: Int32List);
    var expected = NdArray.array([
      [0.5, 1.0, 1.5],
      [8.0, 10.0, 12.0]
    ], dtype: Float64List);
    var result = a * b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality() // Corrected typo
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

// --- New Complex Broadcasting Tests ---

void testBroadcastingMultiplication3DWith2D() {
  test('Broadcasting Multiplication: 3D[2, 2, 3] * 2D[2, 3]', () {
    var a = NdArray.arange(12).reshape([2, 2, 3]);
    // [[[ 0,  1,  2], [ 3,  4,  5]],
    //  [[ 6,  7,  8], [ 9, 10, 11]]]
    var b = NdArray.array([
      [10, 20, 30],
      [40, 50, 60]
    ]); // Shape [2, 3]
    var expected = NdArray.array([
      [
        [0, 20, 60], // a[0,0,:] * b[0,:]
        [120, 200, 300] // a[0,1,:] * b[1,:]
      ],
      [
        [60, 140, 240], // a[1,0,:] * b[0,:]
        [360, 500, 660] // a[1,1,:] * b[1,:]
      ]
    ]);
    var result = a * b;
    expect(result.shape, equals([2, 2, 3]));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testBroadcastingMultiplicationMultipleOnes() {
  test('Broadcasting Multiplication: Multiple Ones [4, 1, 3] * [1, 5, 1]', () {
    var a = NdArray.arange(12).reshape([4, 1, 3]);
    // [[ [0, 1, 2] ],
    //  [ [3, 4, 5] ],
    //  [ [6, 7, 8] ],
    //  [ [9, 10, 11] ]]
    var b = NdArray.arange(100, stop: 105).reshape([1, 5, 1]);
    // [[ [100], [101], [102], [103], [104] ]]

    // Expected shape is [4, 5, 3]
    // result[i, j, k] = a[i, 0, k] * b[0, j, 0]
    var expectedData = List.generate(4, (i) {
      return List.generate(5, (j) {
        return List.generate(3, (k) {
          int aVal = a[[i, 0, k]];
          int bVal = b[[0, j, 0]];
          return aVal * bVal;
        });
      });
    });
    var expected = NdArray.array(expectedData);

    var result = a * b;
    expect(result.shape, equals([4, 5, 3]));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testBroadcastingMultiplicationWithSteppedView() {
  test('Broadcasting Multiplication: Array[2, 3] * SteppedView[3]', () {
    var a = NdArray.array([
      [1, 2, 3],
      [4, 5, 6]
    ]);
    var base = NdArray.arange(0, stop: 10, step: 2); // [0, 2, 4, 6, 8]
    var view = base[[Slice(1, 4)]]; // View [2, 4, 6]
    var expected = NdArray.array([
      [2, 8, 18],
      [8, 20, 36]
    ]);
    var result = a * view;
    expect(result.shape, equals([2, 3]));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
    // Ensure base is unchanged
    expect(base.toList(), equals([0, 2, 4, 6, 8]));
  });
}

void testBroadcastingMultiplicationArrayWithScalarArray() {
  test('Broadcasting Multiplication: Array[m, n] * ScalarArray[()]', () {
    var arr = NdArray.array([
      [1, 2],
      [3, 4]
    ]);
    var scalarArr = NdArray.scalar(10); // Use scalar constructor
    var expected = NdArray.array([
      [10, 20],
      [30, 40]
    ]);
    var result = arr * scalarArr;
    expect(result.shape, equals([2, 2]));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testBroadcastingMultiplicationScalarArrayWithArray() {
  test('Broadcasting Multiplication: ScalarArray[()] * Array[m, n]', () {
    var scalarArr = NdArray.scalar(3); // Use scalar constructor
    var arr = NdArray.array([
      [1.0, 2.0],
      [3.0, 4.0]
    ]);
    var expected = NdArray.array([
      [3.0, 6.0],
      [9.0, 12.0]
    ], dtype: Float64List);
    var result = scalarArr * arr;
    expect(result.shape, equals([2, 2]));
    expect(result.dtype, equals(double)); // Type promotion
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testBroadcastingMultiplicationViewWithScalarArray() {
  test('Broadcasting Multiplication: View[m, n] * ScalarArray[()]', () {
    var base = NdArray.arange(6).reshape([2, 3]); // [[0, 1, 2], [3, 4, 5]]
    var view = base[[Slice(null, null), Slice(0, 2)]]; // View [[0, 1], [3, 4]]
    var scalarArr = NdArray.scalar(2); // Use scalar constructor
    var expected = NdArray.array([
      [0, 2],
      [6, 8]
    ]);
    var result = view * scalarArr;
    expect(result.shape, equals([2, 2]));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}
