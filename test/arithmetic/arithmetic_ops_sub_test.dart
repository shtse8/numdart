import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:numdart/numdart.dart'; // Import main library
import 'package:collection/collection.dart';

// No 'part of' needed

void main() {
  // Main entry point for this test file
  group('NdArray Subtraction (operator-)', () {
    // Call individual test functions directly within the group
    testSubtraction1DInteger();
    testSubtraction1DDouble();
    testSubtraction2DInteger();
    testSubtractionWithViews();
    testSubtractionOfEmptyArrays();
    testScalarSubtractionInt();
    testScalarSubtractionDouble();
    testScalarSubtractionWithTypePromotion();
    testScalarSubtractionWith2DArray();
    testScalarSubtractionWithView();
    testScalarSubtractionWithEmptyArray();
    testThrowsArgumentErrorForInvalidScalarTypeSubtraction();
    testBroadcastingSubtractionRow();
    testBroadcastingSubtractionColumn();
    testThrowsArgumentErrorForIncompatibleBroadcastShapesSubtraction();
    testTypePromotionSubtractionIntDouble();
    testTypePromotionSubtractionDoubleInt();
    testTypePromotionSubtractionWithBroadcastingIntDouble();
    testTypePromotionSubtractionWithBroadcastingDoubleInt();
    testBroadcastingSubtraction3DWith2D();
    testBroadcastingSubtractionMultipleOnes();
    testBroadcastingSubtractionWithSteppedView();
    testBroadcastingSubtractionArrayWithScalarArray();
    testBroadcastingSubtractionScalarArrayWithArray();
    testBroadcastingSubtractionViewWithScalarArray();
  });
}

void testSubtraction1DInteger() {
  test('1D Integer Subtraction', () {
    var a = NdArray.array([5, 7, 9]); // Use static method
    var b = NdArray.array([1, 2, 3]); // Use static method
    var expected = NdArray.array([4, 5, 6]); // Use static method
    var result = a - b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(result.toList(), equals(expected.toList()));
  });
}

void testSubtraction1DDouble() {
  test('1D Double Subtraction', () {
    var a = NdArray.array([5.0, 3.0, 9.9]); // Use static method
    var b = NdArray.array([1.0, 0.5, 6.9]); // Use static method
    var expected = NdArray.array([4.0, 2.5, 3.0]); // Use static method
    var result = a - b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.toList(), equals(expected.toList()));
  });
}

void testSubtraction2DInteger() {
  test('2D Integer Subtraction', () {
    var a = NdArray.array([
      // Use static method
      [6, 8],
      [10, 12]
    ]);
    var b = NdArray.array([
      // Use static method
      [5, 6],
      [7, 8]
    ]);
    var expected = NdArray.array([
      // Use static method
      [1, 2],
      [3, 4]
    ]);
    var result = a - b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testSubtractionWithViews() {
  test('Subtraction with Views (Slices)', () {
    var base = NdArray.arange(10); // Use static method
    var a = base[[Slice(5, 9)]];
    var b = base[[Slice(1, 5)]];
    var expected = NdArray.array([4, 4, 4, 4]); // Use static method
    var result = a - b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(result.toList(), equals(expected.toList()));
    expect(base.toList(), equals([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]));
  });
}

void testSubtractionOfEmptyArrays() {
  test('Subtraction of Empty Arrays', () {
    var a = NdArray.zeros([0]); // Use static method
    var b = NdArray.zeros([0]); // Use static method
    var expected = NdArray.zeros([0]); // Use static method
    var result = a - b;
    expect(result.shape, equals(expected.shape));
    expect(result.size, equals(0));
    expect(result.dtype, equals(double));
    expect(result.toList(), equals(expected.toList()));

    var c = NdArray.zeros([2, 0], dtype: Int32List); // Use static method
    var d = NdArray.zeros([2, 0], dtype: Int32List); // Use static method
    var expected2 =
        NdArray.zeros([2, 0], dtype: Int64List); // Use static method
    var result2 = c - d;
    expect(result2.shape, equals(expected2.shape));
    expect(result2.size, equals(0));
    expect(result2.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result2.toList(), expected2.toList()),
        isTrue);
  });
}

void testScalarSubtractionInt() {
  test('Scalar Subtraction (NdArray - int)', () {
    var a = NdArray.array([11, 12, 13]); // Use static method
    var scalar = 10;
    var expected = NdArray.array([1, 2, 3]); // Use static method
    var result = a - scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(result.toList(), equals(expected.toList()));
  });
}

void testScalarSubtractionDouble() {
  test('Scalar Subtraction (NdArray - double)', () {
    var a = NdArray.array([1.5, 3.0, 3.5]); // Use static method
    var scalar = 0.5;
    var expected = NdArray.array([1.0, 2.5, 3.0]); // Use static method
    var result = a - scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.toList(), equals(expected.toList()));
  });
}

void testScalarSubtractionWithTypePromotion() {
  test('Scalar Subtraction with Type Promotion (int Array - double scalar)',
      () {
    var a = NdArray.array([1, 2, 3]); // Use static method
    var scalar = 0.5;
    var expected =
        NdArray.array([0.5, 1.5, 2.5], dtype: Float64List); // Use static method
    var result = a - scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void testScalarSubtractionWith2DArray() {
  test('Scalar Subtraction with 2D Array', () {
    var a = NdArray.array([
      // Use static method
      [101, 102],
      [103, 104]
    ]);
    var scalar = 100;
    var expected = NdArray.array([
      // Use static method
      [1, 2],
      [3, 4]
    ]);
    var result = a - scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testScalarSubtractionWithView() {
  test('Scalar Subtraction with View', () {
    var base = NdArray.arange(6).reshape([2, 3]); // Use static method
    var view = base[[Slice(null, null), Slice(1, null)]];
    var scalar = 1;
    var expected = NdArray.array([
      // Use static method
      [0, 1],
      [3, 4]
    ]);
    var result = view - scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
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

void testScalarSubtractionWithEmptyArray() {
  test('Scalar Subtraction with Empty Array', () {
    var a = NdArray.zeros([0]); // Use static method
    var scalar = 5;
    var expected = NdArray.zeros([0]); // Use static method
    var result = a - scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.size, equals(0));
    expect(
        result.dtype, equals(double)); // Should now correctly promote to double
    expect(result.toList(), equals(expected.toList()));
  });
}

void testThrowsArgumentErrorForInvalidScalarTypeSubtraction() {
  test('Throws ArgumentError for invalid scalar type', () {
    var a = NdArray.array([1, 2, 3]); // Use static method
    expect(() => a - 'hello', throwsArgumentError);
    expect(() => a - true, throwsArgumentError);
    expect(() => a - null, throwsArgumentError);
  });
}

void testBroadcastingSubtractionRow() {
  test('Broadcasting Subtraction: 2D - 1D (Row)', () {
    var a = NdArray.array([
      // Use static method
      [11, 22, 33],
      [14, 25, 36]
    ]);
    var b = NdArray.array([10, 20, 30]); // Use static method
    var expected = NdArray.array([
      // Use static method
      [1, 2, 3],
      [4, 5, 6]
    ]);
    var result = a - b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testBroadcastingSubtractionColumn() {
  test('Broadcasting Subtraction: 2D - 1D (Column)', () {
    var a = NdArray.array([
      // Use static method
      [11, 12, 13],
      [24, 25, 26]
    ]);
    var b = NdArray.array([
      // Use static method
      [10],
      [20]
    ]);
    var expected = NdArray.array([
      // Use static method
      [1, 2, 3],
      [4, 5, 6]
    ]);
    var result = a - b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testThrowsArgumentErrorForIncompatibleBroadcastShapesSubtraction() {
  test('Throws ArgumentError for incompatible broadcast shapes', () {
    var a = NdArray.array([
      // Use static method
      [1, 2, 3],
      [4, 5, 6]
    ]);
    var b = NdArray.array([10, 20]); // Use static method
    expect(() => a - b, throwsArgumentError);
  });
}

void testTypePromotionSubtractionIntDouble() {
  test('Type Promotion Subtraction: int - double', () {
    var a = NdArray.array([1, 2, 3], dtype: Int32List); // Use static method
    var b =
        NdArray.array([0.5, 0.5, 0.5], dtype: Float64List); // Use static method
    var expected =
        NdArray.array([0.5, 1.5, 2.5], dtype: Float64List); // Use static method
    var result = a - b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void testTypePromotionSubtractionDoubleInt() {
  test('Type Promotion Subtraction: double - int', () {
    var a =
        NdArray.array([1.5, 2.5, 3.5], dtype: Float64List); // Use static method
    var b = NdArray.array([1, 1, 1], dtype: Int32List); // Use static method
    var expected =
        NdArray.array([0.5, 1.5, 2.5], dtype: Float64List); // Use static method
    var result = a - b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void testTypePromotionSubtractionWithBroadcastingIntDouble() {
  test('Type Promotion Subtraction with Broadcasting: int[2,3] - double[3]',
      () {
    var a = NdArray.array([
      // Use static method
      [1, 2, 3],
      [4, 5, 6]
    ], dtype: Int32List);
    var b =
        NdArray.array([0.1, 0.2, 0.3], dtype: Float64List); // Use static method
    var expected = NdArray.array([
      // Use static method
      [0.9, 1.8, 2.7],
      [3.9, 4.8, 5.7]
    ], dtype: Float64List);
    var result = a - b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    // Use closeTo for floating point comparisons
    expect(result.toList()[0][0], closeTo(0.9, 1e-9));
    expect(result.toList()[0][1], closeTo(1.8, 1e-9));
    expect(result.toList()[0][2], closeTo(2.7, 1e-9));
    expect(result.toList()[1][0], closeTo(3.9, 1e-9));
    expect(result.toList()[1][1], closeTo(4.8, 1e-9));
    expect(result.toList()[1][2], closeTo(5.7, 1e-9));
  });
}

void testTypePromotionSubtractionWithBroadcastingDoubleInt() {
  test('Type Promotion Subtraction with Broadcasting: double[2,3] - int[2,1]',
      () {
    var a = NdArray.array([
      // Use static method
      [10.1, 10.2, 10.3],
      [20.4, 20.5, 20.6]
    ], dtype: Float64List);
    var b = NdArray.array([
      // Use static method
      [10],
      [20]
    ], dtype: Int32List);
    var expected = NdArray.array([
      // Use static method
      [0.1, 0.2, 0.3],
      [0.4, 0.5, 0.6]
    ], dtype: Float64List);
    var result = a - b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    // Use closeTo for floating point comparisons
    expect(result.toList()[0][0], closeTo(0.1, 1e-9));
    expect(result.toList()[0][1], closeTo(0.2, 1e-9));
    expect(result.toList()[0][2], closeTo(0.3, 1e-9));
    expect(result.toList()[1][0], closeTo(0.4, 1e-9));
    expect(result.toList()[1][1], closeTo(0.5, 1e-9));
    expect(result.toList()[1][2], closeTo(0.6, 1e-9));
  });
}

// --- New Complex Broadcasting Tests ---

void testBroadcastingSubtraction3DWith2D() {
  test('Broadcasting Subtraction: 3D[2, 2, 3] - 2D[2, 3]', () {
    var a = NdArray.arange(12).reshape([2, 2, 3]);
    // [[[ 0,  1,  2], [ 3,  4,  5]],
    //  [[ 6,  7,  8], [ 9, 10, 11]]]
    var b = NdArray.array([
      [10, 20, 30],
      [40, 50, 60]
    ]); // Shape [2, 3]
    var expected = NdArray.array([
      [
        [-10, -19, -28], // a[0,0,:] - b[0,:]
        [-37, -46, -55] // a[0,1,:] - b[1,:]
      ],
      [
        [-4, -13, -22], // a[1,0,:] - b[0,:]
        [-31, -40, -49] // a[1,1,:] - b[1,:]
      ]
    ]);
    var result = a - b;
    expect(result.shape, equals([2, 2, 3]));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testBroadcastingSubtractionMultipleOnes() {
  test('Broadcasting Subtraction: Multiple Ones [4, 1, 3] - [1, 5, 1]', () {
    var a = NdArray.arange(12).reshape([4, 1, 3]);
    // [[ [0, 1, 2] ],
    //  [ [3, 4, 5] ],
    //  [ [6, 7, 8] ],
    //  [ [9, 10, 11] ]]
    var b = NdArray.arange(100, stop: 105).reshape([1, 5, 1]);
    // [[ [100], [101], [102], [103], [104] ]]

    // Expected shape is [4, 5, 3]
    // result[i, j, k] = a[i, 0, k] - b[0, j, 0]
    var expectedData = List.generate(4, (i) {
      return List.generate(5, (j) {
        return List.generate(3, (k) {
          int aVal = a[[i, 0, k]];
          int bVal = b[[0, j, 0]];
          return aVal - bVal;
        });
      });
    });
    var expected = NdArray.array(expectedData);

    var result = a - b;
    expect(result.shape, equals([4, 5, 3]));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testBroadcastingSubtractionWithSteppedView() {
  test('Broadcasting Subtraction: Array[2, 3] - SteppedView[3]', () {
    var a = NdArray.array([
      [10, 20, 30],
      [40, 50, 60]
    ]);
    var base = NdArray.arange(0, stop: 10, step: 2); // [0, 2, 4, 6, 8]
    var view = base[[Slice(1, 4)]]; // View [2, 4, 6]
    var expected = NdArray.array([
      [8, 16, 24],
      [38, 46, 54]
    ]);
    var result = a - view;
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

void testBroadcastingSubtractionArrayWithScalarArray() {
  test('Broadcasting Subtraction: Array[m, n] - ScalarArray[()]', () {
    var arr = NdArray.array([
      [101, 102],
      [103, 104]
    ]);
    var scalarArr = NdArray.scalar(100); // Use scalar constructor
    var expected = NdArray.array([
      [1, 2],
      [3, 4]
    ]);
    var result = arr - scalarArr;
    expect(result.shape, equals([2, 2]));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testBroadcastingSubtractionScalarArrayWithArray() {
  test('Broadcasting Subtraction: ScalarArray[()] - Array[m, n]', () {
    var scalarArr = NdArray.scalar(100); // Use scalar constructor
    var arr = NdArray.array([
      [1.0, 2.0],
      [3.0, 4.0]
    ]);
    var expected = NdArray.array([
      [99.0, 98.0],
      [97.0, 96.0]
    ], dtype: Float64List);
    var result = scalarArr - arr;
    expect(result.shape, equals([2, 2]));
    expect(result.dtype, equals(double)); // Type promotion
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testBroadcastingSubtractionViewWithScalarArray() {
  test('Broadcasting Subtraction: View[m, n] - ScalarArray[()]', () {
    var base = NdArray.arange(10, stop: 16)
        .reshape([2, 3]); // [[10, 11, 12], [13, 14, 15]]
    var view =
        base[[Slice(null, null), Slice(0, 2)]]; // View [[10, 11], [13, 14]]
    var scalarArr = NdArray.scalar(10); // Use scalar constructor
    var expected = NdArray.array([
      [0, 1],
      [3, 4]
    ]);
    var result = view - scalarArr;
    expect(result.shape, equals([2, 2]));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}
