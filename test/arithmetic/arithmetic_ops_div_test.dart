import 'dart:typed_data';
import 'dart:math' as math; // Import math library with prefix
import 'dart:math'; // For isNaN checks
import 'package:test/test.dart';
import 'package:numdart/numdart.dart'; // Import main library
import 'package:collection/collection.dart';

// No 'part of' needed

void main() {
  // Main entry point for this test file
  group('NdArray Division (operator/)', () {
    // Call individual test functions directly within the group
    // --- Scalar Division Tests ---
    testScalarDivisionInt();
    testScalarDivisionDouble();
    testScalarDivisionWithTypePromotion();
    testScalarDivisionWith2DArray();
    testScalarDivisionWithView();
    testScalarDivisionWithEmptyArray();
    testScalarDivisionByZero();
    testScalarDivisionByZeroIntArray();
    testThrowsArgumentErrorForInvalidScalarTypeDivision();

    // --- Array-Array Division Tests ---
    testArrayDivisionIntInt();
    testArrayDivisionDoubleDouble();
    testArrayDivisionIntDouble();
    testArrayDivision2D();
    testArrayDivisionWithViews();
    testArrayDivisionByZero();
    testArrayDivisionZerosByNonZeros();
    testArrayDivisionEmptyArrays();
    testTypePromotionDivisionIntDoubleArray();
    testTypePromotionDivisionDoubleIntArray();
    testBroadcastingDivisionRow();
    testBroadcastingDivisionColumn();
    testBroadcastingDivisionByZeroArray();
    testThrowsArgumentErrorForIncompatibleBroadcastShapesDivision();
    testTypePromotionDivisionWithBroadcastingIntDoubleArray();
    testTypePromotionDivisionWithBroadcastingDoubleIntArray();
    testBroadcastingDivision3DWith2D();
    testBroadcastingDivisionMultipleOnes();
    testBroadcastingDivisionWithSteppedView();
    testBroadcastingDivisionArrayWithScalarArray();
    testBroadcastingDivisionScalarArrayWithArray();
    testBroadcastingDivisionViewWithScalarArray();
  });
}

void testScalarDivisionInt() {
  test('Scalar Division (NdArray / int)', () {
    var a = NdArray.array([10, 20, 30]); // Use static method
    var scalar = 10;
    var expected = NdArray.array([1.0, 2.0, 3.0], dtype: Float64List);
    var result = a / scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void testScalarDivisionDouble() {
  test('Scalar Division (NdArray / double)', () {
    var a = NdArray.array([2.0, 5.0, 6.0]);
    var scalar = 2.0;
    var expected = NdArray.array([1.0, 2.5, 3.0], dtype: Float64List);
    var result = a / scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void testScalarDivisionWithTypePromotion() {
  test('Scalar Division with Type Promotion (int Array / int scalar)', () {
    var a = NdArray.array([5, 10, 15]);
    var scalar = 2;
    var expected = NdArray.array([2.5, 5.0, 7.5], dtype: Float64List);
    var result = a / scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void testScalarDivisionWith2DArray() {
  test('Scalar Division with 2D Array', () {
    var a = NdArray.array([
      [3, 6],
      [9, 12]
    ]);
    var scalar = 3;
    var expected = NdArray.array([
      [1.0, 2.0],
      [3.0, 4.0]
    ], dtype: Float64List);
    var result = a / scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality() // Corrected typo
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testScalarDivisionWithView() {
  test('Scalar Division with View', () {
    var base = NdArray.arange(6).reshape([2, 3]); // Use static method
    var view = base[[Slice(null, null), Slice(1, null)]];
    var scalar = 2;
    var expected = NdArray.array([
      [0.5, 1.0],
      [2.0, 2.5]
    ], dtype: Float64List);
    var result = view / scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
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

void testScalarDivisionWithEmptyArray() {
  test('Scalar Division with Empty Array', () {
    var a = NdArray.zeros([0]); // Use static method
    var scalar = 5;
    var expected = NdArray.zeros([0], dtype: Float64List);
    var result = a / scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.size, equals(0));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void testScalarDivisionByZero() {
  test('Scalar Division by Zero', () {
    var a = NdArray.array([1.0, -2.0, 0.0, 5.0]);
    var scalar = 0;
    var result = a / scalar;
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    var listResult = result.toList();
    expect(listResult[0], equals(double.infinity));
    expect(listResult[1], equals(double.negativeInfinity));
    expect(listResult[2].isNaN, isTrue);
    expect(listResult[3], equals(double.infinity));
  });
}

void testScalarDivisionByZeroIntArray() {
  test('Scalar Division by Zero (Int Array)', () {
    var a = NdArray.array([1, -2, 0, 5]);
    var scalar = 0;
    var result = a / scalar;
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    var listResult = result.toList();
    expect(listResult[0], equals(double.infinity));
    expect(listResult[1], equals(double.negativeInfinity));
    expect(listResult[2].isNaN, isTrue);
    expect(listResult[3], equals(double.infinity));
  });
}

void testThrowsArgumentErrorForInvalidScalarTypeDivision() {
  test('Throws ArgumentError for invalid scalar type', () {
    var a = NdArray.array([1, 2, 3]);
    expect(() => a / 'hello', throwsArgumentError);
    expect(() => a / true, throwsArgumentError);
    expect(() => a / null, throwsArgumentError);
  });
}

void testArrayDivisionIntInt() {
  test('1D Array Division (Int / Int)', () {
    var a = NdArray.array([10, 20, 30]);
    var b = NdArray.array([2, 5, 10]);
    var expected = NdArray.array([5.0, 4.0, 3.0], dtype: Float64List);
    var result = a / b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void testArrayDivisionDoubleDouble() {
  test('1D Array Division (Double / Double)', () {
    var a = NdArray.array([10.0, 20.0, 30.0]);
    var b = NdArray.array([2.0, 5.0, 10.0]);
    var expected = NdArray.array([5.0, 4.0, 3.0], dtype: Float64List);
    var result = a / b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void testArrayDivisionIntDouble() {
  test('1D Array Division (Int / Double)', () {
    // Already tests type promotion implicitly
    var a = NdArray.array([10, 20, 30]);
    var b = NdArray.array([2.0, 5.0, 10.0]);
    var expected = NdArray.array([5.0, 4.0, 3.0], dtype: Float64List);
    var result = a / b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void testArrayDivision2D() {
  test('2D Array Division', () {
    var a = NdArray.array([
      [10, 20],
      [30, 40]
    ]);
    var b = NdArray.array([
      [2, 5],
      [10, 8]
    ]);
    var expected = NdArray.array([
      [5.0, 4.0],
      [3.0, 5.0]
    ], dtype: Float64List);
    var result = a / b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality() // Corrected typo
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testArrayDivisionWithViews() {
  test('Array Division with Views', () {
    var baseA = NdArray.arange(10, stop: 20); // Use static method
    var baseB = NdArray.arange(1, stop: 11);
    var a = baseA[[Slice(0, 4)]];
    var b = baseB[[Slice(1, 5)]];
    var expected =
        NdArray.array([5.0, 11.0 / 3.0, 3.0, 13.0 / 5.0], dtype: Float64List);
    var result = a / b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList()[0], closeTo(5.0, 1e-9));
    expect(result.toList()[1], closeTo(11.0 / 3.0, 1e-9));
    expect(result.toList()[2], closeTo(3.0, 1e-9));
    expect(result.toList()[3], closeTo(13.0 / 5.0, 1e-9));
  });
}

void testArrayDivisionByZero() {
  test('Array Division by Zero', () {
    var a = NdArray.array([1.0, -2.0, 0.0, 5.0, 10]);
    var b = NdArray.array([0.0, 0.0, 0.0, 0.0, 0]);
    var result = a / b;
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    var listResult = result.toList();
    expect(listResult[0], equals(double.infinity));
    expect(listResult[1], equals(double.negativeInfinity));
    expect(listResult[2].isNaN, isTrue);
    expect(listResult[3], equals(double.infinity));
    expect(listResult[4], equals(double.infinity));
  });
}

void testArrayDivisionZerosByNonZeros() {
  test('Array Division of Zeros by Non-Zeros', () {
    var a = NdArray.array([0.0, 0, 0.0]);
    var b = NdArray.array([1.0, 2, -5.0]);
    var expected = NdArray.array([0.0, 0.0, -0.0], dtype: Float64List);
    var result = a / b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
    expect(result.toList()[2].isNegative, isTrue);
  });
}

void testArrayDivisionEmptyArrays() {
  test('Array Division of Empty Arrays', () {
    var a = NdArray.zeros([0]);
    var b = NdArray.zeros([0]);
    var expected = NdArray.zeros([0], dtype: Float64List);
    var result = a / b;
    expect(result.shape, equals(expected.shape));
    expect(result.size, equals(0));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));

    var c = NdArray.zeros([2, 0]);
    var d = NdArray.zeros([2, 0]);
    var expected2 = NdArray.zeros([2, 0], dtype: Float64List);
    var result2 = c / d;
    expect(result2.shape, equals(expected2.shape));
    expect(result2.size, equals(0));
    expect(result2.dtype, equals(double));
    expect(result2.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality() // Corrected typo
            .equals(result2.toList(), expected2.toList()),
        isTrue);
  });
}

void testTypePromotionDivisionIntDoubleArray() {
  test('Type Promotion Division: int / double (already covered)', () {
    var a = NdArray.array([10, 20, 30], dtype: Int32List);
    var b = NdArray.array([2.0, 5.0, 10.0], dtype: Float64List);
    var expected = NdArray.array([5.0, 4.0, 3.0], dtype: Float64List);
    var result = a / b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void testTypePromotionDivisionDoubleIntArray() {
  test('Type Promotion Division: double / int', () {
    var a = NdArray.array([10.0, 20.0, 30.0], dtype: Float64List);
    var b = NdArray.array([2, 5, 10], dtype: Int32List);
    var expected = NdArray.array([5.0, 4.0, 3.0], dtype: Float64List);
    var result = a / b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void testBroadcastingDivisionRow() {
  test('Broadcasting Division: 2D / 1D (Row)', () {
    var a = NdArray.array([
      [10, 40, 90],
      [40, 100, 180]
    ]);
    var b = NdArray.array([10, 20, 30]);
    var expected = NdArray.array([
      [1.0, 2.0, 3.0],
      [4.0, 5.0, 6.0]
    ], dtype: Float64List);
    var result = a / b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality() // Corrected typo
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testBroadcastingDivisionColumn() {
  test('Broadcasting Division: 2D / 1D (Column)', () {
    var a = NdArray.array([
      [10, 20, 30],
      [80, 100, 120]
    ]);
    var b = NdArray.array([
      [10],
      [20]
    ]);
    var expected = NdArray.array([
      [1.0, 2.0, 3.0],
      [4.0, 5.0, 6.0]
    ], dtype: Float64List);
    var result = a / b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality() // Corrected typo
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testBroadcastingDivisionByZeroArray() {
  test('Broadcasting Division by Zero', () {
    var a = NdArray.array([
      [1.0, -2.0],
      [0.0, 5.0]
    ]);
    var b = NdArray.array([0.0, 1.0]);
    var result = a / b; // [[1/0, -2/1], [0/0, 5/1]]
    expect(result.shape, equals([2, 2]));
    expect(result.dtype, equals(double));
    var listResult = result.toList();
    expect(listResult[0][0], equals(double.infinity));
    expect(listResult[0][1], equals(-2.0));
    expect(listResult[1][0].isNaN, isTrue);
    expect(listResult[1][1], equals(5.0));
  });
}

void testThrowsArgumentErrorForIncompatibleBroadcastShapesDivision() {
  test('Throws ArgumentError for incompatible broadcast shapes', () {
    var a = NdArray.array([
      [1, 2, 3],
      [4, 5, 6]
    ]);
    var b = NdArray.array([10, 20]);
    expect(() => a / b, throwsArgumentError);
  });
}

void testTypePromotionDivisionWithBroadcastingIntDoubleArray() {
  test('Type Promotion Division with Broadcasting: int[2,3] / double[3]', () {
    var a = NdArray.array([
      [10, 40, 90],
      [40, 100, 180]
    ], dtype: Int32List);
    var b = NdArray.array([10.0, 20.0, 30.0], dtype: Float64List);
    var expected = NdArray.array([
      [1.0, 2.0, 3.0],
      [4.0, 5.0, 6.0]
    ], dtype: Float64List);
    var result = a / b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality() // Corrected typo
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testTypePromotionDivisionWithBroadcastingDoubleIntArray() {
  test('Type Promotion Division with Broadcasting: double[2,1] / int[2,3]', () {
    var a = NdArray.array([
      [10.0],
      [80.0]
    ], dtype: Float64List);
    var b = NdArray.array([
      [1, 2, 4],
      [4, 5, 8]
    ], dtype: Int32List);
    var expected = NdArray.array([
      [10.0, 5.0, 2.5],
      [20.0, 16.0, 10.0]
    ], dtype: Float64List);
    var result = a / b;
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

void testBroadcastingDivision3DWith2D() {
  test('Broadcasting Division: 3D[2, 2, 3] / 2D[2, 3]', () {
    var a = NdArray.arange(12).reshape([2, 2, 3]);
    // [[[ 0,  1,  2], [ 3,  4,  5]],
    //  [[ 6,  7,  8], [ 9, 10, 11]]]
    var b = NdArray.array([
      [10, 20, 30],
      [40, 50, 60]
    ]); // Shape [2, 3]
    var expected = NdArray.array([
      [
        [0.0, 1.0 / 20.0, 2.0 / 30.0], // a[0,0,:] / b[0,:]
        [3.0 / 40.0, 4.0 / 50.0, 5.0 / 60.0] // a[0,1,:] / b[1,:]
      ],
      [
        [6.0 / 10.0, 7.0 / 20.0, 8.0 / 30.0], // a[1,0,:] / b[0,:]
        [9.0 / 40.0, 10.0 / 50.0, 11.0 / 60.0] // a[1,1,:] / b[1,:]
      ]
    ], dtype: Float64List);
    var result = a / b;
    expect(result.shape, equals([2, 2, 3]));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    // Compare element-wise due to floating point
    for (int i = 0; i < 2; i++) {
      for (int j = 0; j < 2; j++) {
        for (int k = 0; k < 3; k++) {
          expect(result[[i, j, k]], closeTo(expected[[i, j, k]], 1e-9));
        }
      }
    }
  });
}

void testBroadcastingDivisionMultipleOnes() {
  test('Broadcasting Division: Multiple Ones [4, 1, 3] / [1, 5, 1]', () {
    var a = NdArray.arange(12).reshape([4, 1, 3]);
    // [[ [0, 1, 2] ],
    //  [ [3, 4, 5] ],
    //  [ [6, 7, 8] ],
    //  [ [9, 10, 11] ]]
    var b = NdArray.arange(100, stop: 105).reshape([1, 5, 1]);
    // [[ [100], [101], [102], [103], [104] ]]

    // Expected shape is [4, 5, 3]
    // result[i, j, k] = a[i, 0, k] / b[0, j, 0]
    var expectedData = List.generate(4, (i) {
      return List.generate(5, (j) {
        return List.generate(3, (k) {
          double aVal = a[[i, 0, k]].toDouble();
          double bVal = b[[0, j, 0]].toDouble();
          return aVal / bVal;
        });
      });
    });
    var expected = NdArray.array(expectedData, dtype: Float64List);

    var result = a / b;
    expect(result.shape, equals([4, 5, 3]));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    // Compare element-wise
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 5; j++) {
        for (int k = 0; k < 3; k++) {
          expect(result[[i, j, k]], closeTo(expected[[i, j, k]], 1e-9));
        }
      }
    }
  });
}

void testBroadcastingDivisionWithSteppedView() {
  test('Broadcasting Division: Array[2, 3] / SteppedView[3]', () {
    var a = NdArray.array([
      [10, 20, 30],
      [40, 50, 60]
    ]);
    var base = NdArray.arange(0, stop: 10, step: 2); // [0, 2, 4, 6, 8]
    var view = base[[Slice(1, 4)]]; // View [2, 4, 6]
    var expected = NdArray.array([
      [5.0, 5.0, 5.0],
      [20.0, 12.5, 10.0]
    ], dtype: Float64List);
    var result = a / view;
    expect(result.shape, equals([2, 3]));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
    // Ensure base is unchanged
    expect(base.toList(), equals([0, 2, 4, 6, 8]));
  });
}

void testBroadcastingDivisionArrayWithScalarArray() {
  test('Broadcasting Division: Array[m, n] / ScalarArray[()]', () {
    var arr = NdArray.array([
      [10, 20],
      [30, 40]
    ]);
    var scalarArr = NdArray.scalar(10); // Use scalar constructor
    var expected = NdArray.array([
      [1.0, 2.0],
      [3.0, 4.0]
    ], dtype: Float64List);
    var result = arr / scalarArr;
    expect(result.shape, equals([2, 2]));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testBroadcastingDivisionScalarArrayWithArray() {
  test('Broadcasting Division: ScalarArray[()] / Array[m, n]', () {
    var scalarArr = NdArray.scalar(100); // Use scalar constructor
    var arr = NdArray.array([
      [1.0, 2.0],
      [4.0, 5.0]
    ]);
    var expected = NdArray.array([
      [100.0, 50.0],
      [25.0, 20.0]
    ], dtype: Float64List);
    var result = scalarArr / arr;
    expect(result.shape, equals([2, 2]));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testBroadcastingDivisionViewWithScalarArray() {
  test('Broadcasting Division: View[m, n] / ScalarArray[()]', () {
    var base = NdArray.arange(10, stop: 16)
        .reshape([2, 3]); // [[10, 11, 12], [13, 14, 15]]
    var view =
        base[[Slice(null, null), Slice(0, 2)]]; // View [[10, 11], [13, 14]]
    var scalarArr = NdArray.scalar(2); // Use scalar constructor
    var expected = NdArray.array([
      [5.0, 5.5],
      [6.5, 7.0]
    ], dtype: Float64List);
    var result = view / scalarArr;
    expect(result.shape, equals([2, 2]));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}
