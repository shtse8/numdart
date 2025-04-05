part of 'arithmetic_ops_test.dart';

void _testMultiplicationGroup() {
  group('NdArray Multiplication (operator*)', () {
    // --- Existing Tests ---
    _testMultiplication1DInteger();
    _testMultiplication1DDouble();
    _testMultiplicationWithZero();
    _testMultiplication2DInteger();
    _testMultiplicationWithViews();
    _testMultiplicationOfEmptyArrays();
    _testScalarMultiplicationInt();
    _testScalarMultiplicationDouble();
    _testScalarMultiplicationWithTypePromotion();
    _testScalarMultiplicationWith2DArray();
    _testScalarMultiplicationWithView();
    _testScalarMultiplicationWithEmptyArray();
    _testThrowsArgumentErrorForInvalidScalarTypeMultiplication();
    _testBroadcastingMultiplicationRow();
    _testBroadcastingMultiplicationColumn();
    _testThrowsArgumentErrorForIncompatibleBroadcastShapesMultiplication();
    _testTypePromotionMultiplicationIntDouble();
    _testTypePromotionMultiplicationDoubleInt();
    _testTypePromotionMultiplicationWithBroadcastingIntDouble();
    _testTypePromotionMultiplicationWithBroadcastingDoubleInt();
  });
}

void _testMultiplication1DInteger() {
  test('1D Integer Multiplication', () {
    var a = array([1, 2, 3]);
    var b = array([4, 5, 6]);
    var expected = array([4, 10, 18]);
    var result = a * b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(result.toList(), equals(expected.toList()));
  });
}

void _testMultiplication1DDouble() {
  test('1D Double Multiplication', () {
    var a = array([1.0, 2.5, 3.0]);
    var b = array([4.0, 0.5, 2.0]);
    var expected = array([4.0, 1.25, 6.0]);
    var result = a * b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.toList(), equals(expected.toList()));
  });
}

void _testMultiplicationWithZero() {
  test('Multiplication with zero', () {
    var a = array([1, 2, 3]);
    var b = zeros([3], dtype: Int64List);
    var expected = zeros([3], dtype: Int64List);
    var result = a * b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(result.toList(), equals(expected.toList()));

    var c = array([0.0, 5.0, 0.0]);
    var d = array([10.0, 0.0, 20.0]);
    var expected2 = array([0.0, 0.0, 0.0]);
    var result2 = c * d;
    expect(result2.shape, equals(expected2.shape));
    expect(result2.dtype, equals(double));
    expect(result2.toList(), equals(expected2.toList()));
  });
}

void _testMultiplication2DInteger() {
  test('2D Integer Multiplication', () {
    var a = array([
      [1, 2],
      [3, 4]
    ]);
    var b = array([
      [5, 6],
      [7, 8]
    ]);
    var expected = array([
      [5, 12],
      [21, 32]
    ]);
    var result = a * b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void _testMultiplicationWithViews() {
  test('Multiplication with Views (Slices)', () {
    var base = arange(10);
    var a = base[[Slice(1, 5)]];
    var b = base[[Slice(5, 9)]];
    var expected = array([5, 12, 21, 32]);
    var result = a * b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(result.toList(), equals(expected.toList()));
    expect(base.toList(), equals([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]));
  });
}

void _testMultiplicationOfEmptyArrays() {
  test('Multiplication of Empty Arrays', () {
    var a = zeros([0]);
    var b = zeros([0]);
    var expected = zeros([0]);
    var result = a * b;
    expect(result.shape, equals(expected.shape));
    expect(result.size, equals(0));
    expect(result.dtype, equals(double));
    expect(result.toList(), equals(expected.toList()));

    var c = zeros([2, 0], dtype: Int32List);
    var d = zeros([2, 0], dtype: Int32List);
    var expected2 = zeros([2, 0], dtype: Int64List);
    var result2 = c * d;
    expect(result2.shape, equals(expected2.shape));
    expect(result2.size, equals(0));
    expect(result2.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result2.toList(), expected2.toList()),
        isTrue);
  });
}

void _testScalarMultiplicationInt() {
  test('Scalar Multiplication (NdArray * int)', () {
    var a = array([1, 2, 3]);
    var scalar = 10;
    var expected = array([10, 20, 30]);
    var result = a * scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(result.toList(), equals(expected.toList()));
  });
}

void _testScalarMultiplicationDouble() {
  test('Scalar Multiplication (NdArray * double)', () {
    var a = array([1.0, 2.5, 3.0]);
    var scalar = 2.0;
    var expected = array([2.0, 5.0, 6.0]);
    var result = a * scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.toList(), equals(expected.toList()));
  });
}

void _testScalarMultiplicationWithTypePromotion() {
  test('Scalar Multiplication with Type Promotion (int Array * double scalar)',
      () {
    var a = array([1, 2, 3]);
    var scalar = 0.5;
    var expected = array([0.5, 1.0, 1.5], dtype: Float64List);
    var result = a * scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void _testScalarMultiplicationWith2DArray() {
  test('Scalar Multiplication with 2D Array', () {
    var a = array([
      [1, 2],
      [3, 4]
    ]);
    var scalar = 3;
    var expected = array([
      [3, 6],
      [9, 12]
    ]);
    var result = a * scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void _testScalarMultiplicationWithView() {
  test('Scalar Multiplication with View', () {
    var base = arange(6).reshape([2, 3]);
    var view = base[[Slice(null, null), Slice(1, null)]];
    var scalar = 2;
    var expected = array([
      [2, 4],
      [8, 10]
    ]);
    var result = view * scalar;
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

void _testScalarMultiplicationWithEmptyArray() {
  test('Scalar Multiplication with Empty Array', () {
    var a = zeros([0]);
    var scalar = 5;
    var expected = zeros([0]);
    var result = a * scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.size, equals(0));
    expect(
        result.dtype, equals(double)); // Should now correctly promote to double
    expect(result.toList(), equals(expected.toList()));
  });
}

void _testThrowsArgumentErrorForInvalidScalarTypeMultiplication() {
  test('Throws ArgumentError for invalid scalar type', () {
    var a = array([1, 2, 3]);
    expect(() => a * 'hello', throwsArgumentError);
    expect(() => a * true, throwsArgumentError);
    expect(() => a * null, throwsArgumentError);
  });
}

void _testBroadcastingMultiplicationRow() {
  test('Broadcasting Multiplication: 2D * 1D (Row)', () {
    var a = array([
      [1, 2, 3],
      [4, 5, 6]
    ]);
    var b = array([10, 20, 30]);
    var expected = array([
      [10, 40, 90],
      [40, 100, 180]
    ]);
    var result = a * b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void _testBroadcastingMultiplicationColumn() {
  test('Broadcasting Multiplication: 2D * 1D (Column)', () {
    var a = array([
      [1, 2, 3],
      [4, 5, 6]
    ]);
    var b = array([
      [10],
      [20]
    ]);
    var expected = array([
      [10, 20, 30],
      [80, 100, 120]
    ]);
    var result = a * b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(int));
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void _testThrowsArgumentErrorForIncompatibleBroadcastShapesMultiplication() {
  test('Throws ArgumentError for incompatible broadcast shapes', () {
    var a = array([
      [1, 2, 3],
      [4, 5, 6]
    ]);
    var b = array([10, 20]);
    expect(() => a * b, throwsArgumentError);
  });
}

void _testTypePromotionMultiplicationIntDouble() {
  test('Type Promotion Multiplication: int * double', () {
    var a = array([1, 2, 3], dtype: Int32List);
    var b = array([0.5, 2.0, 1.5], dtype: Float64List);
    var expected = array([0.5, 4.0, 4.5], dtype: Float64List);
    var result = a * b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void _testTypePromotionMultiplicationDoubleInt() {
  test('Type Promotion Multiplication: double * int', () {
    var a = array([0.5, 2.0, 1.5], dtype: Float64List);
    var b = array([2, 3, 4], dtype: Int32List);
    var expected = array([1.0, 6.0, 6.0], dtype: Float64List);
    var result = a * b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void _testTypePromotionMultiplicationWithBroadcastingIntDouble() {
  test('Type Promotion Multiplication with Broadcasting: int[2,3] * double[3]',
      () {
    var a = array([
      [1, 2, 3],
      [4, 5, 6]
    ], dtype: Int32List);
    var b = array([0.5, 2.0, 1.0], dtype: Float64List);
    var expected = array([
      [0.5, 4.0, 3.0],
      [2.0, 10.0, 6.0]
    ], dtype: Float64List);
    var result = a * b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void _testTypePromotionMultiplicationWithBroadcastingDoubleInt() {
  test(
      'Type Promotion Multiplication with Broadcasting: double[2,1] * int[2,3]',
      () {
    var a = array([
      [0.5],
      [2.0]
    ], dtype: Float64List);
    var b = array([
      [1, 2, 3],
      [4, 5, 6]
    ], dtype: Int32List);
    var expected = array([
      [0.5, 1.0, 1.5],
      [8.0, 10.0, 12.0]
    ], dtype: Float64List);
    var result = a * b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}
