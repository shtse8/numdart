part of 'elementwise_math_test.dart';

void _testSinGroup() {
  group('NdArray Sine (sin)', () {
    _testSin1DInteger();
    _testSin1DDouble();
    _testSin2D();
    _testSinEmptyArray();
    _testSinView();
  });
}

void _testSin1DInteger() {
  test('sin of 1D Integer Array (as radians)', () {
    var a = array([0, 1, 2]); // Interpreted as radians
    var expected =
        array([math.sin(0), math.sin(1), math.sin(2)], dtype: Float64List);
    var result = a.sin();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    for (int i = 0; i < result.size; i++) {
      expect(result.toList()[i], closeTo(expected.toList()[i], 1e-9));
    }
  });
}

void _testSin1DDouble() {
  test('sin of 1D Double Array (radians)', () {
    var a = array([0.0, math.pi / 2, math.pi, 3 * math.pi / 2, 2 * math.pi]);
    var expected = array([0.0, 1.0, 0.0, -1.0, 0.0], dtype: Float64List);
    var result = a.sin();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    for (int i = 0; i < result.size; i++) {
      expect(result.toList()[i], closeTo(expected.toList()[i], 1e-9));
    }
  });
}

void _testSin2D() {
  test('sin of 2D Array (radians)', () {
    var a = array([
      [0, math.pi / 2],
      [math.pi, 3 * math.pi / 2]
    ]);
    var expected = array([
      [0.0, 1.0],
      [0.0, -1.0]
    ], dtype: Float64List);
    var result = a.sin();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList()[0][0], closeTo(expected.toList()[0][0], 1e-9));
    expect(result.toList()[0][1], closeTo(expected.toList()[0][1], 1e-9));
    expect(result.toList()[1][0], closeTo(expected.toList()[1][0], 1e-9));
    expect(result.toList()[1][1], closeTo(expected.toList()[1][1], 1e-9));
  });
}

void _testSinEmptyArray() {
  test('sin of Empty Array', () {
    var a = zeros([0]);
    var expected = zeros([0], dtype: Float64List);
    var result = a.sin();
    expect(result.shape, equals(expected.shape));
    expect(result.size, equals(0));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));

    var c = zeros([2, 0], dtype: Int32List);
    var expected2 = zeros([2, 0], dtype: Float64List);
    var result2 = c.sin();
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

void _testSinView() {
  test('sin of View', () {
    var base = array([
      [0, math.pi / 2, math.pi],
      [math.pi, 3 * math.pi / 2, 2 * math.pi]
    ]);
    var view =
        base[[Slice(null, null), Slice(1, null)]]; // [[pi/2, pi], [3pi/2, 2pi]]
    var expected = array([
      [1.0, 0.0],
      [-1.0, 0.0]
    ], dtype: Float64List);
    var result = view.sin();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList()[0][0], closeTo(expected.toList()[0][0], 1e-9));
    expect(result.toList()[0][1], closeTo(expected.toList()[0][1], 1e-9));
    expect(result.toList()[1][0], closeTo(expected.toList()[1][0], 1e-9));
    expect(result.toList()[1][1], closeTo(expected.toList()[1][1], 1e-9));
    // Ensure original base array is unchanged
    expect(base.toList()[0][1], closeTo(math.pi / 2, 1e-9)); // Check a value
  });
}
