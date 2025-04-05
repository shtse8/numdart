part of 'arithmetic_ops_test.dart';

void _testAdditionGroup() {
  group('NdArray Addition (operator+)', () {
    // --- Existing Tests ---
    _testAddition1DInteger();
    _testAddition1DDouble();
    _testAddition2DInteger();
    _testAdditionWithViews();
    _testAdditionOfEmptyArrays();
    _testScalarAdditionInt();
    _testScalarAdditionDouble();
    _testScalarAdditionWithTypePromotion();
    _testScalarAdditionWith2DArray();
    _testScalarAdditionWithView();
    _testScalarAdditionWithEmptyArray();
    _testThrowsArgumentErrorForInvalidScalarTypeAddition();
    _testBroadcastingAdditionRow();
    _testBroadcastingAdditionColumn();
    _testBroadcastingAddition1DTo2DColumn();
    _testBroadcastingAdditionDifferentDimensions();
    _testBroadcastingAdditionScalarArray(); // Note: This is same as scalar test
    _testThrowsArgumentErrorForIncompatibleBroadcastShapesAddition();
    _testBroadcastingAdditionWithEmptyArrays();
    _testTypePromotionAdditionIntDouble();
    _testTypePromotionAdditionDoubleInt();
    _testTypePromotionAdditionWithBroadcastingIntDouble();
    _testTypePromotionAdditionWithBroadcastingDoubleInt();
    _testTypePromotionAdditionWithBroadcastingIntColDouble();
  });
}

void _testAddition1DInteger() {
  test('1D Integer Addition', () {
    var a = array([1, 2, 3]);
    var b = array([4, 5, 6]);
    var expected = array([5, 7, 9]);
    var result = a + b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int)); // Check primitive type
    expect(result.toList(), equals(expected.toList()));
  });
}

void _testAddition1DDouble() {
  test('1D Double Addition', () {
    var a = array([1.0, 2.5, 3.0]);
    var b = array([4.0, 0.5, 6.9]);
    var expected = array([5.0, 3.0, 9.9]);
    var result = a + b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double)); // Check primitive type
    expect(result.toList(), equals(expected.toList()));
  });
}

void _testAddition2DInteger() {
  test('2D Integer Addition', () {
    var a = array([
      [1, 2],
      [3, 4]
    ]);
    var b = array([
      [5, 6],
      [7, 8]
    ]);
    var expected = array([
      [6, 8],
      [10, 12]
    ]);
    var result = a + b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int)); // Check primitive type
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void _testAdditionWithViews() {
  test('Addition with Views (Slices)', () {
    var base = arange(10); // [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] dtype=Int64List
    var a = base[[Slice(1, 5)]]; // View [1, 2, 3, 4]
    var b = base[[Slice(5, 9)]]; // View [5, 6, 7, 8]
    var expected = array([6, 8, 10, 12]);
    var result = a + b;

    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int)); // Check primitive type
    expect(result.toList(), equals(expected.toList()));
    // Ensure original base array is unchanged
    expect(base.toList(), equals([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]));
  });
}

void _testAdditionOfEmptyArrays() {
  test('Addition of Empty Arrays', () {
    var a = zeros([0]); // Float64List default
    var b = zeros([0]); // Float64List default
    var expected = zeros([0]);
    var result = a + b;
    expect(result.shape, equals(expected.shape));
    expect(result.size, equals(0));
    expect(result.dtype, equals(double));
    expect(result.toList(), equals(expected.toList()));

    var c = zeros([2, 0], dtype: Int32List);
    var d = zeros([2, 0], dtype: Int32List);
    var expected2 =
        zeros([2, 0], dtype: Int64List); // Result promotes to Int64List
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

void _testScalarAdditionInt() {
  test('Scalar Addition (NdArray + int)', () {
    var a = array([1, 2, 3]); // Int64List default
    var scalar = 10;
    var expected = array([11, 12, 13]);
    var result = a + scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int)); // Stays int
    expect(result.toList(), equals(expected.toList()));
  });
}

void _testScalarAdditionDouble() {
  test('Scalar Addition (NdArray + double)', () {
    var a = array([1.0, 2.5, 3.0]); // Float64List default
    var scalar = 0.5;
    var expected = array([1.5, 3.0, 3.5]);
    var result = a + scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double)); // Stays double
    expect(result.toList(), equals(expected.toList()));
  });
}

void _testScalarAdditionWithTypePromotion() {
  test('Scalar Addition with Type Promotion (int Array + double scalar)', () {
    var a = array([1, 2, 3]); // Int64List default
    var scalar = 0.5;
    var expected = array([1.5, 2.5, 3.5], dtype: Float64List);
    var result = a + scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double)); // Promotes to double
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void _testScalarAdditionWith2DArray() {
  test('Scalar Addition with 2D Array', () {
    var a = array([
      [1, 2],
      [3, 4]
    ]); // Int64List default
    var scalar = 100;
    var expected = array([
      [101, 102],
      [103, 104]
    ]);
    var result = a + scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int)); // Stays int
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void _testScalarAdditionWithView() {
  test('Scalar Addition with View', () {
    var base = arange(6).reshape([2, 3]); // Int64List default
    var view = base[[Slice(null, null), Slice(1, null)]];
    var scalar = 10;
    var expected = array([
      [11, 12],
      [14, 15]
    ]);
    var result = view + scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int)); // Stays int
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

void _testScalarAdditionWithEmptyArray() {
  test('Scalar Addition with Empty Array', () {
    var a = zeros([0]); // Float64List default
    var scalar = 5;
    var expected = zeros([0]);
    var result = a + scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.size, equals(0));
    expect(
        result.dtype, equals(double)); // Should now correctly promote to double
    expect(result.toList(), equals(expected.toList()));
  });
}

void _testThrowsArgumentErrorForInvalidScalarTypeAddition() {
  test('Throws ArgumentError for invalid scalar type', () {
    var a = array([1, 2, 3]);
    expect(() => a + 'hello', throwsArgumentError);
    expect(() => a + true, throwsArgumentError);
    expect(() => a + null, throwsArgumentError);
  });
}

void _testBroadcastingAdditionRow() {
  test('Broadcasting Addition: 2D + 1D (Row)', () {
    var a = array([
      [1, 2, 3],
      [4, 5, 6]
    ]); // Int64List default
    var b = array([10, 20, 30]); // Int64List default
    var expected = array([
      [11, 22, 33],
      [14, 25, 36]
    ]);
    var result = a + b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int)); // Stays int
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void _testBroadcastingAdditionColumn() {
  test('Broadcasting Addition: 2D + 1D (Column)', () {
    var a = array([
      [1, 2, 3],
      [4, 5, 6]
    ]); // Int64List default
    var b = array([
      [10],
      [20]
    ]); // Int64List default
    var expected = array([
      [11, 12, 13],
      [24, 25, 26]
    ]);
    var result = a + b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int)); // Stays int
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void _testBroadcastingAddition1DTo2DColumn() {
  test('Broadcasting Addition: 1D + 2D (Column)', () {
    var a = array([10, 20]); // Int64List default
    var b = array([
      [1, 2, 3],
      [4, 5, 6]
    ]); // Int64List default
    var aCol = a.reshape([2, 1]);
    var expected = array([
      [11, 12, 13],
      [24, 25, 26]
    ]);
    var result = aCol + b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int)); // Stays int
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void _testBroadcastingAdditionDifferentDimensions() {
  test('Broadcasting Addition: Different Dimensions', () {
    var a = array([
      [
        [1, 2],
        [3, 4]
      ],
      [
        [5, 6],
        [7, 8]
      ]
    ]); // Int64List default
    var b = array([10, 20]); // Int64List default
    var expected = array([
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
    expect(result.dtype, equals(int)); // Stays int
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void _testBroadcastingAdditionScalarArray() {
  test('Broadcasting Addition: Scalar Array', () {
    var a = array([
      [1, 2],
      [3, 4]
    ]); // Int64List default
    var scalar = 10;
    var expected = array([
      [11, 12],
      [13, 14]
    ]);
    var result = a + scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int)); // Stays int
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void _testThrowsArgumentErrorForIncompatibleBroadcastShapesAddition() {
  test('Throws ArgumentError for incompatible broadcast shapes', () {
    var a = array([
      [1, 2, 3],
      [4, 5, 6]
    ]);
    var b = array([10, 20]);
    expect(() => a + b, throwsArgumentError);

    var c = zeros([2, 3, 4]);
    var d = zeros([2, 1, 5]);
    expect(() => c + d, throwsArgumentError);
  });
}

void _testBroadcastingAdditionWithEmptyArrays() {
  test('Broadcasting Addition with Empty Arrays', () {
    var a = zeros([2, 0]); // Float64List default
    var b = zeros([0]); // Float64List default
    var expected = zeros([2, 0]);
    var result = a + b;
    expect(result.shape, equals(expected.shape));
    expect(result.size, equals(0));
    expect(result.dtype, equals(double));

    var c = zeros([0, 3], dtype: Int32List);
    var d = zeros([1, 3], dtype: Int32List);
    var expected2 = zeros([0, 3], dtype: Int64List); // Promotes to Int64List
    var result2 = c + d;
    expect(result2.shape, equals(expected2.shape));
    expect(result2.size, equals(0));
    expect(result2.dtype, equals(int));

    var e = zeros([0, 0]); // Float64List default
    var f = zeros([1, 0]); // Float64List default
    var expected3 = zeros([0, 0]);
    var result3 = e + f;
    expect(result3.shape, equals(expected3.shape));
    expect(result3.size, equals(0));
    expect(result3.dtype, equals(double));

    var g = zeros([2, 0]);
    var h = zeros([3, 0]);
    expect(() => g + h, throwsArgumentError);
  });
}

void _testTypePromotionAdditionIntDouble() {
  test('Type Promotion Addition: int + double', () {
    var a = array([1, 2, 3], dtype: Int32List);
    var b = array([0.5, 1.5, 2.5], dtype: Float64List);
    var expected = array([1.5, 3.5, 5.5], dtype: Float64List);
    var result = a + b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double)); // Result should be double
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void _testTypePromotionAdditionDoubleInt() {
  test('Type Promotion Addition: double + int', () {
    var a = array([0.5, 1.5, 2.5], dtype: Float64List);
    var b = array([1, 2, 3], dtype: Int32List);
    var expected = array([1.5, 3.5, 5.5], dtype: Float64List);
    var result = a + b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double)); // Result should be double
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void _testTypePromotionAdditionWithBroadcastingIntDouble() {
  test('Type Promotion Addition with Broadcasting: int[2,3] + double[3]', () {
    var a = array([
      [1, 2, 3],
      [4, 5, 6]
    ], dtype: Int32List);
    var b = array([0.1, 0.2, 0.3], dtype: Float64List);
    var expected = array([
      [1.1, 2.2, 3.3],
      [4.1, 5.2, 6.3]
    ], dtype: Float64List);
    var result = a + b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double)); // Result should be double
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void _testTypePromotionAdditionWithBroadcastingDoubleInt() {
  test('Type Promotion Addition with Broadcasting: double[2,3] + int[3]', () {
    var a = array([
      [1.1, 2.2, 3.3],
      [4.1, 5.2, 6.3]
    ], dtype: Float64List);
    var b = array([1, 2, 3], dtype: Int32List);
    var expected = array([
      [2.1, 4.2, 6.3],
      [5.1, 7.2, 9.3]
    ], dtype: Float64List);
    var result = a + b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double)); // Result should be double
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void _testTypePromotionAdditionWithBroadcastingIntColDouble() {
  test('Type Promotion Addition with Broadcasting: int[2,1] + double[2,3]', () {
    var a = array([
      [10],
      [20]
    ], dtype: Int32List);
    var b = array([
      [0.1, 0.2, 0.3],
      [0.4, 0.5, 0.6]
    ], dtype: Float64List);
    var expected = array([
      [10.1, 10.2, 10.3],
      [20.4, 20.5, 20.6]
    ], dtype: Float64List);
    var result = a + b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double)); // Result should be double
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}
