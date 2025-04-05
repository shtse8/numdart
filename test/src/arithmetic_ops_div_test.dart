part of 'arithmetic_ops_test.dart';

void _testDivisionGroup() {
  group('NdArray Division (operator/)', () {
    // --- Scalar Division Tests ---
    _testScalarDivisionInt();
    _testScalarDivisionDouble();
    _testScalarDivisionWithTypePromotion();
    _testScalarDivisionWith2DArray();
    _testScalarDivisionWithView();
    _testScalarDivisionWithEmptyArray();
    _testScalarDivisionByZero();
    _testScalarDivisionByZeroIntArray();
    _testThrowsArgumentErrorForInvalidScalarTypeDivision();

    // --- Array-Array Division Tests ---
    _testArrayDivisionIntInt();
    _testArrayDivisionDoubleDouble();
    _testArrayDivisionIntDouble();
    _testArrayDivision2D();
    _testArrayDivisionWithViews();
    _testArrayDivisionByZero();
    _testArrayDivisionZerosByNonZeros();
    _testArrayDivisionEmptyArrays();
    _testTypePromotionDivisionIntDoubleArray(); // Already covered by Int/Int
    _testTypePromotionDivisionDoubleIntArray(); // Already covered by Double/Double
    _testBroadcastingDivisionRow();
    _testBroadcastingDivisionColumn();
    _testBroadcastingDivisionByZeroArray();
    _testThrowsArgumentErrorForIncompatibleBroadcastShapesDivision();
    _testTypePromotionDivisionWithBroadcastingIntDoubleArray();
    _testTypePromotionDivisionWithBroadcastingDoubleIntArray();
  });
}

void _testScalarDivisionInt() {
  test('Scalar Division (NdArray / int)', () {
    var a = array([10, 20, 30]);
    var scalar = 10;
    var expected = array([1.0, 2.0, 3.0], dtype: Float64List);
    var result = a / scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void _testScalarDivisionDouble() {
  test('Scalar Division (NdArray / double)', () {
    var a = array([2.0, 5.0, 6.0]);
    var scalar = 2.0;
    var expected = array([1.0, 2.5, 3.0], dtype: Float64List);
    var result = a / scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void _testScalarDivisionWithTypePromotion() {
  test('Scalar Division with Type Promotion (int Array / int scalar)', () {
    var a = array([5, 10, 15]);
    var scalar = 2;
    var expected = array([2.5, 5.0, 7.5], dtype: Float64List);
    var result = a / scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void _testScalarDivisionWith2DArray() {
  test('Scalar Division with 2D Array', () {
    var a = array([
      [3, 6],
      [9, 12]
    ]);
    var scalar = 3;
    var expected = array([
      [1.0, 2.0],
      [3.0, 4.0]
    ], dtype: Float64List);
    var result = a / scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void _testScalarDivisionWithView() {
  test('Scalar Division with View', () {
    var base = arange(6).reshape([2, 3]);
    var view = base[[Slice(null, null), Slice(1, null)]];
    var scalar = 2;
    var expected = array([
      [0.5, 1.0],
      [2.0, 2.5]
    ], dtype: Float64List);
    var result = view / scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
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

void _testScalarDivisionWithEmptyArray() {
  test('Scalar Division with Empty Array', () {
    var a = zeros([0]);
    var scalar = 5;
    var expected = zeros([0], dtype: Float64List);
    var result = a / scalar;
    expect(result.shape, equals(expected.shape));
    expect(result.size, equals(0));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void _testScalarDivisionByZero() {
  test('Scalar Division by Zero', () {
    var a = array([1.0, -2.0, 0.0, 5.0]);
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

void _testScalarDivisionByZeroIntArray() {
  test('Scalar Division by Zero (Int Array)', () {
    var a = array([1, -2, 0, 5]);
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

void _testThrowsArgumentErrorForInvalidScalarTypeDivision() {
  test('Throws ArgumentError for invalid scalar type', () {
    var a = array([1, 2, 3]);
    expect(() => a / 'hello', throwsArgumentError);
    expect(() => a / true, throwsArgumentError);
    expect(() => a / null, throwsArgumentError);
  });
}

void _testArrayDivisionIntInt() {
  test('1D Array Division (Int / Int)', () {
    var a = array([10, 20, 30]);
    var b = array([2, 5, 10]);
    var expected = array([5.0, 4.0, 3.0], dtype: Float64List);
    var result = a / b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void _testArrayDivisionDoubleDouble() {
  test('1D Array Division (Double / Double)', () {
    var a = array([10.0, 20.0, 30.0]);
    var b = array([2.0, 5.0, 10.0]);
    var expected = array([5.0, 4.0, 3.0], dtype: Float64List);
    var result = a / b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void _testArrayDivisionIntDouble() {
  test('1D Array Division (Int / Double)', () {
    // Already tests type promotion implicitly
    var a = array([10, 20, 30]);
    var b = array([2.0, 5.0, 10.0]);
    var expected = array([5.0, 4.0, 3.0], dtype: Float64List);
    var result = a / b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void _testArrayDivision2D() {
  test('2D Array Division', () {
    var a = array([
      [10, 20],
      [30, 40]
    ]);
    var b = array([
      [2, 5],
      [10, 8]
    ]);
    var expected = array([
      [5.0, 4.0],
      [3.0, 5.0]
    ], dtype: Float64List);
    var result = a / b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void _testArrayDivisionWithViews() {
  test('Array Division with Views', () {
    var baseA = arange(10, stop: 20);
    var baseB = arange(1, stop: 11);
    var a = baseA[[Slice(0, 4)]];
    var b = baseB[[Slice(1, 5)]];
    var expected =
        array([5.0, 11.0 / 3.0, 3.0, 13.0 / 5.0], dtype: Float64List);
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

void _testArrayDivisionByZero() {
  test('Array Division by Zero', () {
    var a = array([1.0, -2.0, 0.0, 5.0, 10]);
    var b = array([0.0, 0.0, 0.0, 0.0, 0]);
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

void _testArrayDivisionZerosByNonZeros() {
  test('Array Division of Zeros by Non-Zeros', () {
    var a = array([0.0, 0, 0.0]);
    var b = array([1.0, 2, -5.0]);
    var expected = array([0.0, 0.0, -0.0], dtype: Float64List);
    var result = a / b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
    expect(result.toList()[2].isNegative, isTrue);
  });
}

void _testArrayDivisionEmptyArrays() {
  test('Array Division of Empty Arrays', () {
    var a = zeros([0]);
    var b = zeros([0]);
    var expected = zeros([0], dtype: Float64List);
    var result = a / b;
    expect(result.shape, equals(expected.shape));
    expect(result.size, equals(0));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));

    var c = zeros([2, 0]);
    var d = zeros([2, 0]);
    var expected2 = zeros([2, 0], dtype: Float64List);
    var result2 = c / d;
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

void _testTypePromotionDivisionIntDoubleArray() {
  test('Type Promotion Division: int / double (already covered)', () {
    var a = array([10, 20, 30], dtype: Int32List);
    var b = array([2.0, 5.0, 10.0], dtype: Float64List);
    var expected = array([5.0, 4.0, 3.0], dtype: Float64List);
    var result = a / b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void _testTypePromotionDivisionDoubleIntArray() {
  test('Type Promotion Division: double / int', () {
    var a = array([10.0, 20.0, 30.0], dtype: Float64List);
    var b = array([2, 5, 10], dtype: Int32List);
    var expected = array([5.0, 4.0, 3.0], dtype: Float64List);
    var result = a / b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void _testBroadcastingDivisionRow() {
  test('Broadcasting Division: 2D / 1D (Row)', () {
    var a = array([
      [10, 40, 90],
      [40, 100, 180]
    ]); // Int64List default
    var b = array([10, 20, 30]); // Int64List default
    var expected = array([
      [1.0, 2.0, 3.0],
      [4.0, 5.0, 6.0]
    ], dtype: Float64List); // Shape [2, 3]
    var result = a / b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void _testBroadcastingDivisionColumn() {
  test('Broadcasting Division: 2D / 1D (Column)', () {
    var a = array([
      [10, 20, 30],
      [80, 100, 120]
    ]); // Int64List default
    var b = array([
      [10],
      [20]
    ]); // Int64List default
    var expected = array([
      [1.0, 2.0, 3.0],
      [4.0, 5.0, 6.0]
    ], dtype: Float64List); // Shape [2, 3]
    var result = a / b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void _testBroadcastingDivisionByZeroArray() {
  test('Broadcasting Division by Zero', () {
    var a = array([
      [1.0, -2.0],
      [0.0, 5.0]
    ]); // Float64List default
    var b = array([0.0, 1.0]); // Float64List default
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

void _testThrowsArgumentErrorForIncompatibleBroadcastShapesDivision() {
  test('Throws ArgumentError for incompatible broadcast shapes', () {
    var a = array([
      [1, 2, 3],
      [4, 5, 6]
    ]);
    var b = array([10, 20]);
    expect(() => a / b, throwsArgumentError);
  });
}

void _testTypePromotionDivisionWithBroadcastingIntDoubleArray() {
  test('Type Promotion Division with Broadcasting: int[2,3] / double[3]', () {
    var a = array([
      [10, 40, 90],
      [40, 100, 180]
    ], dtype: Int32List);
    var b = array([10.0, 20.0, 30.0], dtype: Float64List);
    var expected = array([
      [1.0, 2.0, 3.0],
      [4.0, 5.0, 6.0]
    ], dtype: Float64List); // Result always double
    var result = a / b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}

void _testTypePromotionDivisionWithBroadcastingDoubleIntArray() {
  test('Type Promotion Division with Broadcasting: double[2,1] / int[2,3]', () {
    var a = array([
      [10.0],
      [80.0]
    ], dtype: Float64List);
    var b = array([
      [1, 2, 4],
      [4, 5, 8]
    ], dtype: Int32List);
    var expected = array([
      [10.0, 5.0, 2.5],
      [20.0, 16.0, 10.0]
    ], dtype: Float64List); // Result always double
    var result = a / b;
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(
        const DeepCollectionEquality()
            .equals(result.toList(), expected.toList()),
        isTrue);
  });
}
