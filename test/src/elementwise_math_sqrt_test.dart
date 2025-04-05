part of 'elementwise_math_test.dart';

void _testSqrtGroup() {
  group('NdArray Square Root (sqrt)', () {
    _testSqrt1DInteger();
    _testSqrt1DDouble();
    _testSqrt2D();
    _testSqrtWithNegativeNumbers();
    _testSqrtEmptyArray();
    _testSqrtView();
  });
}

void _testSqrt1DInteger() {
  test('sqrt of 1D Integer Array', () {
    var a = array([0, 1, 4, 9, 16, 25]);
    var expected = array([0.0, 1.0, 2.0, 3.0, 4.0, 5.0], dtype: Float64List);
    var result = a.sqrt();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void _testSqrt1DDouble() {
  test('sqrt of 1D Double Array', () {
    var a = array([0.0, 1.0, 2.25, 6.25]);
    var expected = array([0.0, 1.0, 1.5, 2.5], dtype: Float64List);
    var result = a.sqrt();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));
  });
}

void _testSqrt2D() {
  test('sqrt of 2D Array', () {
    var a = array([
      [4, 9],
      [1, 16]
    ]);
    var expected = array([
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

void _testSqrtWithNegativeNumbers() {
  test('sqrt with Negative Numbers (results in NaN)', () {
    var a = array([4.0, -9.0, 16.0, -1.0]);
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

void _testSqrtEmptyArray() {
  test('sqrt of Empty Array', () {
    var a = zeros([0]);
    var expected = zeros([0], dtype: Float64List);
    var result = a.sqrt();

    expect(result.shape, equals(expected.shape));
    expect(result.size, equals(0));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));

    var c = zeros([2, 0], dtype: Int32List);
    var expected2 = zeros([2, 0], dtype: Float64List);
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

void _testSqrtView() {
  test('sqrt of View', () {
    var base = array([
      [1, 4, 9],
      [16, 25, 36]
    ]);
    var view = base[[Slice(null, null), Slice(1, null)]]; // [[4, 9], [25, 36]]
    var expected = array([
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
