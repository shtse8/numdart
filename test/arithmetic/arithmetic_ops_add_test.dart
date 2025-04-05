import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:numdart/numdart.dart'; // Import main library
import 'package:collection/collection.dart';
import 'dart:math' as math;

// No 'part of' needed

void main() {
  group('NdArray Addition (operator+)', () {
    testAddition1DInteger();
    testAddition1DDouble();
    testAddition2DInteger();
    testAdditionWithViews();
    testAdditionOfEmptyArrays();
    testScalarAdditionInt();
    testScalarAdditionDouble();
    testScalarAdditionWithTypePromotion();
    testScalarAdditionWith2DArray();
    testScalarAdditionWithView();
    testScalarAdditionWithEmptyArray();
    testThrowsArgumentErrorForInvalidScalarTypeAddition();
    testBroadcastingAdditionRow();
    testBroadcastingAdditionColumn();
    testBroadcastingAddition1DTo2DColumn();
    testBroadcastingAdditionDifferentDimensions();
    testBroadcastingAdditionScalarArray();
    testThrowsArgumentErrorForIncompatibleBroadcastShapesAddition();
    testBroadcastingAdditionWithEmptyArrays();
    testTypePromotionAdditionIntDouble();
    testTypePromotionAdditionDoubleInt();
    testTypePromotionAdditionWithBroadcastingIntDouble();
    testTypePromotionAdditionWithBroadcastingDoubleInt();
    testTypePromotionAdditionWithBroadcastingIntColDouble();
    testBroadcastingAdditionViewColumnWithRow();
    testBroadcastingAdditionArrayWithViewRow();
    testBroadcastingAdditionViewColumnWithViewRow();
    testBroadcastingAdditionArrayWithScalarArray();
    testBroadcastingAdditionScalarArrayWithArray();
    testBroadcastingAdditionViewWithScalarArray();
    testBroadcastingAdditionComplexDims();
  });
}

void testAddition1DInteger() {
  test('1D Integer Addition', () {
    var a = NdArray.array([1, 2, 3]); // Use static method
    var b = NdArray.array([4, 5, 6]);
    var expected = NdArray.array([5, 7, 9]);
    var result = a + b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(result.toList(), equals(expected.toList()));
  });
}

void testAddition1DDouble() {
  test('1D Double Addition', () {
    var a = NdArray.array([1.0, 2.5, 3.0]);
    var b = NdArray.array([4.0, 0.5, 6.9]);
    var expected = NdArray.array([5.0, 3.0, 9.9]);
    var result = a + b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.toList(), equals(expected.toList()));
  });
}

void testAddition2DInteger() {
  test('2D Integer Addition', () {
    var a = NdArray.array([
      [1, 2],
      [3, 4]
    ]);
    var b = NdArray.array([
      [5, 6],
      [7, 8]
    ]);
    var expected = NdArray.array([
      [6, 8],
      [10, 12]
    ]);
    var result = a + b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testAdditionWithViews() {
  test('Addition with Views (Slices)', () {
    var base = NdArray.arange(10); // Use static method
    var a = base[[Slice(1, 5)]];
    var b = base[[Slice(5, 9)]];
    var expected = NdArray.array([6, 8, 10, 12]);
    var result = a + b;

    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(result.toList(), equals(expected.toList()));
    expect(base.toList(), equals([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]));
  });
}

void testAdditionOfEmptyArrays() {
  test('Addition of Empty Arrays', () {
    var a = NdArray.zeros([0]); // Use static method
    var b = NdArray.zeros([0]);
    var expected = NdArray.zeros([0]);
    var result = a + b;
    expect(result.shape, equals(expected.shape));
    expect(result.size, equals(0));
    expect(result.dtype, equals(double));
    expect(result.toList(), equals(expected.toList()));

    var c = NdArray.zeros([2, 0], dtype: Int32List);
    var d = NdArray.zeros([2, 0], dtype: Int32List);
    var expected2 = NdArray.zeros([2, 0], dtype: Int64List);
    var result2 = c + d;
    expect(result2.shape, equals(expected2.shape));
    expect(result2.size, equals(0));
    expect(result2.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result2.toList(), expected2.toList()),
        isTrue);
  });
}

void testScalarAdditionInt() {
  test('Scalar Addition (NdArray + int)', () {
    var a = NdArray.array([1, 2, 3]);
    var scalar = 10;
    var expected = NdArray.array([11, 12, 13]);
    var result = a + scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(result.toList(), equals(expected.toList()));
  });
}

void testScalarAdditionDouble() {
  test('Scalar Addition (NdArray + double)', () {
    var a = NdArray.array([1.0, 2.5, 3.0]);
    var scalar = 0.5;
    var expected = NdArray.array([1.5, 3.0, 3.5]);
    var result = a + scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.toList(), equals(expected.toList()));
  });
}

void testScalarAdditionWithTypePromotion() {
  test('Scalar Addition with Type Promotion (int Array + double scalar)', () {
    var a = NdArray.array([1, 2, 3]);
    var scalar = 0.5;
    var expected = NdArray.array([1.5, 2.5, 3.5], dtype: Float64List);
    var result = a + scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void testScalarAdditionWith2DArray() {
  test('Scalar Addition with 2D Array', () {
    var a = NdArray.array([
      [1, 2],
      [3, 4]
    ]);
    var scalar = 100;
    var expected = NdArray.array([
      [101, 102],
      [103, 104]
    ]);
    var result = a + scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testScalarAdditionWithView() {
  test('Scalar Addition with View', () {
    var base = NdArray.arange(6).reshape([2, 3]);
    var view = base[[Slice(null, null), Slice(1, null)]];
    var scalar = 10;
    var expected = NdArray.array([
      [11, 12],
      [14, 15]
    ]);
    var result = view + scalar;
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

void testScalarAdditionWithEmptyArray() {
  test('Scalar Addition with Empty Array', () {
    var a = NdArray.zeros([0]);
    var scalar = 5;
    var expected = NdArray.zeros([0]);
    var result = a + scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.size, equals(0));
    expect(result.dtype, equals(double));
    expect(result.toList(), equals(expected.toList()));
  });
}

void testThrowsArgumentErrorForInvalidScalarTypeAddition() {
  test('Throws ArgumentError for invalid scalar type', () {
    var a = NdArray.array([1, 2, 3]);
    expect(() => a + 'hello', throwsArgumentError);
    expect(() => a + true, throwsArgumentError);
    expect(() => a + null, throwsArgumentError);
  });
}

void testBroadcastingAdditionRow() {
  test('Broadcasting Addition: 2D + 1D (Row)', () {
    var a = NdArray.array([
      [1, 2, 3],
      [4, 5, 6]
    ]);
    var b = NdArray.array([10, 20, 30]);
    var expected = NdArray.array([
      [11, 22, 33],
      [14, 25, 36]
    ]);
    var result = a + b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testBroadcastingAdditionColumn() {
  test('Broadcasting Addition: 2D + 1D (Column)', () {
    var a = NdArray.array([
      [1, 2, 3],
      [4, 5, 6]
    ]);
    var b = NdArray.array([
      [10],
      [20]
    ]);
    var expected = NdArray.array([
      [11, 12, 13],
      [24, 25, 26]
    ]);
    var result = a + b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testBroadcastingAddition1DTo2DColumn() {
  test('Broadcasting Addition: 1D + 2D (Column)', () {
    var a = NdArray.array([10, 20]);
    var b = NdArray.array([
      [1, 2, 3],
      [4, 5, 6]
    ]);
    var aCol = a.reshape([2, 1]);
    var expected = NdArray.array([
      [11, 12, 13],
      [24, 25, 26]
    ]);
    var result = aCol + b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testBroadcastingAdditionDifferentDimensions() {
  test('Broadcasting Addition: Different Dimensions', () {
    var a = NdArray.array([
      [
        [1, 2],
        [3, 4]
      ],
      [
        [5, 6],
        [7, 8]
      ]
    ]);
    var b = NdArray.array([10, 20]);
    var expected = NdArray.array([
      [
        [11, 22],
        [13, 24]
      ],
      [
        [15, 26],
        [17, 28]
      ]
    ]);
    var result = a + b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testBroadcastingAdditionScalarArray() {
  test('Broadcasting Addition: Scalar Array (using num)', () {
    // Clarified test name
    var a = NdArray.array([
      [1, 2],
      [3, 4]
    ]);
    var scalar = 10; // This test uses a num scalar, not a 0-D NdArray
    var expected = NdArray.array([
      [11, 12],
      [13, 14]
    ]);
    var result = a + scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testThrowsArgumentErrorForIncompatibleBroadcastShapesAddition() {
  test('Throws ArgumentError for incompatible broadcast shapes', () {
    var a = NdArray.array([
      [1, 2, 3],
      [4, 5, 6]
    ]);
    var b = NdArray.array([10, 20]);
    expect(() => a + b, throwsArgumentError);

    var c = NdArray.zeros([2, 3, 4]);
    var d = NdArray.zeros([2, 1, 5]);
    expect(() => c + d, throwsArgumentError);
  });
}

void testBroadcastingAdditionWithEmptyArrays() {
  test('Broadcasting Addition with Empty Arrays', () {
    var a = NdArray.zeros([2, 0]);
    var b = NdArray.zeros([0]);
    var expected = NdArray.zeros([2, 0]);
    var result = a + b;
    expect(result.shape, equals(expected.shape));
    expect(result.size, equals(0));
    expect(result.dtype, equals(double));

    var c = NdArray.zeros([0, 3], dtype: Int32List);
    var d = NdArray.zeros([1, 3], dtype: Int32List);
    var expected2 = NdArray.zeros([0, 3], dtype: Int64List);
    var result2 = c + d;
    expect(result2.shape, equals(expected2.shape));
    expect(result2.size, equals(0));
    expect(result2.dtype, equals(int));

    var e = NdArray.zeros([0, 0]);
    var f = NdArray.zeros([1, 0]);
    var expected3 = NdArray.zeros([0, 0]);
    var result3 = e + f;
    expect(result3.shape, equals(expected3.shape));
    expect(result3.size, equals(0));
    expect(result3.dtype, equals(double));

    var g = NdArray.zeros([2, 0]);
    var h = NdArray.zeros([3, 0]);
    expect(() => g + h, throwsArgumentError);
  });
}

void testTypePromotionAdditionIntDouble() {
  test('Type Promotion Addition: int + double', () {
    var a = NdArray.array([1, 2, 3], dtype: Int32List);
    var b = NdArray.array([0.5, 1.5, 2.5], dtype: Float64List);
    var expected = NdArray.array([1.5, 3.5, 5.5], dtype: Float64List);
    var result = a + b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void testTypePromotionAdditionDoubleInt() {
  test('Type Promotion Addition: double + int', () {
    var a = NdArray.array([0.5, 1.5, 2.5], dtype: Float64List);
    var b = NdArray.array([1, 2, 3], dtype: Int32List);
    var expected = NdArray.array([1.5, 3.5, 5.5], dtype: Float64List);
    var result = a + b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void testTypePromotionAdditionWithBroadcastingIntDouble() {
  test('Type Promotion Addition with Broadcasting: int[2,3] + double[3]', () {
    var a = NdArray.array([
      [1, 2, 3],
      [4, 5, 6]
    ], dtype: Int32List);
    var b = NdArray.array([0.1, 0.2, 0.3], dtype: Float64List);
    var expected = NdArray.array([
      [1.1, 2.2, 3.3],
      [4.1, 5.2, 6.3]
    ], dtype: Float64List);
    var result = a + b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testTypePromotionAdditionWithBroadcastingDoubleInt() {
  test('Type Promotion Addition with Broadcasting: double[2,3] + int[3]', () {
    var a = NdArray.array([
      [1.1, 2.2, 3.3],
      [4.1, 5.2, 6.3]
    ], dtype: Float64List);
    var b = NdArray.array([1, 2, 3], dtype: Int32List);
    var expected = NdArray.array([
      [2.1, 4.2, 6.3],
      [5.1, 7.2, 9.3]
    ], dtype: Float64List);
    var result = a + b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testTypePromotionAdditionWithBroadcastingIntColDouble() {
  test('Type Promotion Addition with Broadcasting: int[2,1] + double[2,3]', () {
    var a = NdArray.array([
      [10],
      [20]
    ], dtype: Int32List);
    var b = NdArray.array([
      [0.1, 0.2, 0.3],
      [0.4, 0.5, 0.6]
    ], dtype: Float64List);
    var expected = NdArray.array([
      [10.1, 10.2, 10.3],
      [20.4, 20.5, 20.6]
    ], dtype: Float64List);
    var result = a + b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

// --- New Complex Broadcasting Tests ---

void testBroadcastingAdditionViewColumnWithRow() {
  test('Broadcasting Addition: View[m, 1] + Array[n]', () {
    var base = NdArray.arange(6).reshape([3, 2]); // [[0, 1], [2, 3], [4, 5]]
    var viewCol = base[[
      Slice(null, null),
      Slice(0, 1)
    ]]; // View [[0], [2], [4]] shape [3, 1]
    var rowArr = NdArray.array([10, 100]); // shape [2]
    var expected = NdArray.array([
      [10, 100],
      [12, 102],
      [14, 104]
    ]);
    var result = viewCol + rowArr;
    expect(result.shape, equals([3, 2]));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
    // Ensure base is unchanged
    expect(
        base.toList(),
        equals([
          [0, 1],
          [2, 3],
          [4, 5]
        ]));
  });
}

void testBroadcastingAdditionArrayWithViewRow() {
  test('Broadcasting Addition: Array[m, n] + View[n]', () {
    var arr = NdArray.array([
      [1, 2, 3],
      [4, 5, 6]
    ]); // shape [2, 3]
    var baseRow = NdArray.arange(10, stop: 13); // [10, 11, 12]
    var viewRow = baseRow[[Slice(null, null)]]; // View [10, 11, 12] shape [3]
    var expected = NdArray.array([
      [11, 13, 15],
      [14, 16, 18]
    ]);
    var result = arr + viewRow;
    expect(result.shape, equals([2, 3]));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
    // Ensure base is unchanged
    expect(baseRow.toList(), equals([10, 11, 12]));
  });
}

void testBroadcastingAdditionViewColumnWithViewRow() {
  test('Broadcasting Addition: View[m, 1] + View[n]', () {
    var baseCol = NdArray.arange(0, stop: 6, step: 2)
        .reshape([3, 1]); // View [[0], [2], [4]] shape [3, 1]
    var baseRow = NdArray.arange(10, stop: 12); // [10, 11]
    var viewCol = baseCol[[Slice(null, null), Slice(null, null)]];
    var viewRow = baseRow[[Slice(null, null)]]; // View [10, 11] shape [2]
    var expected = NdArray.array([
      [10, 11],
      [12, 13],
      [14, 15]
    ]);
    var result = viewCol + viewRow;
    expect(result.shape, equals([3, 2]));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testBroadcastingAdditionArrayWithScalarArray() {
  test('Broadcasting Addition: Array[m, n] + ScalarArray[()]', () {
    var arr = NdArray.array([
      [1, 2],
      [3, 4]
    ]);
    var scalarArr = NdArray.array([100]).reshape([]); // Create 0-D array
    var expected = NdArray.array([
      [101, 102],
      [103, 104]
    ]);
    var result = arr + scalarArr;
    expect(result.shape, equals([2, 2]));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testBroadcastingAdditionScalarArrayWithArray() {
  test('Broadcasting Addition: ScalarArray[()] + Array[m, n]', () {
    var scalarArr = NdArray.array([100]).reshape([]); // Create 0-D array
    var arr = NdArray.array([
      [1.0, 2.0],
      [3.0, 4.0]
    ]);
    var expected = NdArray.array([
      [101.0, 102.0],
      [103.0, 104.0]
    ], dtype: Float64List);
    var result = scalarArr + arr;
    expect(result.shape, equals([2, 2]));
    expect(result.dtype, equals(double)); // Type promotion
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testBroadcastingAdditionViewWithScalarArray() {
  test('Broadcasting Addition: View[m, n] + ScalarArray[()]', () {
    var base = NdArray.arange(6).reshape([2, 3]);
    var view = base[[Slice(null, null), Slice(0, 2)]]; // View [[0, 1], [3, 4]]
    var scalarArr = NdArray.array([10]).reshape([]); // Create 0-D array
    var expected = NdArray.array([
      [10, 11],
      [13, 14]
    ]);
    var result = view + scalarArr;
    expect(result.shape, equals([2, 2]));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void testBroadcastingAdditionComplexDims() {
  test('Broadcasting Addition: Complex Dims [a, 1, c] + [b, c]', () {
    var a = NdArray.arange(6).reshape([2, 1, 3]); // [[[0, 1, 2]], [[3, 4, 5]]]
    var b = NdArray.arange(10, stop: 16)
        .reshape([2, 3]); // [[10, 11, 12], [13, 14, 15]]
    var expected = NdArray.array([
      [
        [10, 12, 14],
        [13, 15, 17]
      ], // a[0,0,:] + b[0,:], a[0,0,:] + b[1,:]
      [
        [13, 15, 17],
        [16, 18, 20]
      ] // a[1,0,:] + b[0,:], a[1,0,:] + b[1,:]
    ]).reshape([2, 2, 3]);
    var result = a + b;
    expect(result.shape, equals([2, 2, 3]));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}
