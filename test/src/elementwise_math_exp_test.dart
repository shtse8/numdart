part of 'elementwise_math_test.dart';

void _testExpGroup() {
  group('NdArray Exponential (exp)', () {
    _testExp1DInteger();
    _testExp1DDouble();
    _testExp2D();
    _testExpEmptyArray();
    _testExpView();
  });
}

void _testExp1DInteger() {
  test('exp of 1D Integer Array', () {
    var a = array([0, 1, 2, -1]);
    var expected = array([math.exp(0), math.exp(1), math.exp(2), math.exp(-1)],
        dtype: Float64List);
    var result = a.exp();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    // Use closeTo for floating point comparisons
    for (int i = 0; i < result.size; i++) {
      expect(result.toList()[i], closeTo(expected.toList()[i], 1e-9));
    }
  });
}

void _testExp1DDouble() {
  test('exp of 1D Double Array', () {
    var a = array([0.0, 1.0, -0.5, 2.5]);
    var expected = array(
        [math.exp(0.0), math.exp(1.0), math.exp(-0.5), math.exp(2.5)],
        dtype: Float64List);
    var result = a.exp();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    for (int i = 0; i < result.size; i++) {
      expect(result.toList()[i], closeTo(expected.toList()[i], 1e-9));
    }
  });
}

void _testExp2D() {
  test('exp of 2D Array', () {
    var a = array([
      [0, 1],
      [-1, 2]
    ]);
    var expected = array([
      [math.exp(0), math.exp(1)],
      [math.exp(-1), math.exp(2)]
    ], dtype: Float64List);
    var result = a.exp();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList()[0][0], closeTo(expected.toList()[0][0], 1e-9));
    expect(result.toList()[0][1], closeTo(expected.toList()[0][1], 1e-9));
    expect(result.toList()[1][0], closeTo(expected.toList()[1][0], 1e-9));
    expect(result.toList()[1][1], closeTo(expected.toList()[1][1], 1e-9));
  });
}

void _testExpEmptyArray() {
  test('exp of Empty Array', () {
    var a = zeros([0]);
    var expected = zeros([0], dtype: Float64List);
    var result = a.exp();
    expect(result.shape, equals(expected.shape));
    expect(result.size, equals(0));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));

    var c = zeros([2, 0], dtype: Int32List);
    var expected2 = zeros([2, 0], dtype: Float64List);
    var result2 = c.exp();
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

void _testExpView() {
  test('exp of View', () {
    var base = array([
      [0, 1, 2],
      [3, 4, 5]
    ]);
    var view = base[[Slice(null, null), Slice(1, null)]]; // [[1, 2], [4, 5]]
    var expected = array([
      [math.exp(1), math.exp(2)],
      [math.exp(4), math.exp(5)]
    ], dtype: Float64List);
    var result = view.exp();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList()[0][0], closeTo(expected.toList()[0][0], 1e-9));
    expect(result.toList()[0][1], closeTo(expected.toList()[0][1], 1e-9));
    expect(result.toList()[1][0], closeTo(expected.toList()[1][0], 1e-9));
    expect(result.toList()[1][1], closeTo(expected.toList()[1][1], 1e-9));
    // Ensure original base array is unchanged
    expect(
        base.toList(),
        equals([
          [0, 1, 2],
          [3, 4, 5]
        ]));
  });
}
