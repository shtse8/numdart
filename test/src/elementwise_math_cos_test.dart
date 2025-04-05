part of 'elementwise_math_test.dart';

void _testCosGroup() {
  group('NdArray Cosine (cos)', () {
    _testCos1DInteger();
    _testCos1DDouble();
    _testCos2D();
    _testCosEmptyArray();
    _testCosView();
  });
}

void _testCos1DInteger() {
  test('cos of 1D Integer Array (as radians)', () {
    var a = array([0, 1, 2]); // Interpreted as radians
    var expected =
        array([math.cos(0), math.cos(1), math.cos(2)], dtype: Float64List);
    var result = a.cos();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    for (int i = 0; i < result.size; i++) {
      expect(result.toList()[i], closeTo(expected.toList()[i], 1e-9));
    }
  });
}

void _testCos1DDouble() {
  test('cos of 1D Double Array (radians)', () {
    var a = array([0.0, math.pi / 2, math.pi, 3 * math.pi / 2, 2 * math.pi]);
    var expected = array([1.0, 0.0, -1.0, 0.0, 1.0], dtype: Float64List);
    var result = a.cos();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    for (int i = 0; i < result.size; i++) {
      expect(result.toList()[i], closeTo(expected.toList()[i], 1e-9));
    }
  });
}

void _testCos2D() {
  test('cos of 2D Array (radians)', () {
    var a = array([
      [0, math.pi / 2],
      [math.pi, 3 * math.pi / 2]
    ]);
    var expected = array([
      [1.0, 0.0],
      [-1.0, 0.0]
    ], dtype: Float64List);
    var result = a.cos();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList()[0][0], closeTo(expected.toList()[0][0], 1e-9));
    expect(result.toList()[0][1], closeTo(expected.toList()[0][1], 1e-9));
    expect(result.toList()[1][0], closeTo(expected.toList()[1][0], 1e-9));
    expect(result.toList()[1][1], closeTo(expected.toList()[1][1], 1e-9));
  });
}

void _testCosEmptyArray() {
  test('cos of Empty Array', () {
    var a = zeros([0]);
    // cos(0) is 1, but for empty array...
    // Let's refine: expected should be empty float array
    var expected = array([], dtype: Float64List);
    var result = a.cos();
    expect(result.shape, equals(expected.shape));
    expect(result.size, equals(0));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));

    var c = zeros([2, 0], dtype: Int32List);
    var expected2 = zeros([2, 0], dtype: Float64List);
    var result2 = c.cos();
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

void _testCosView() {
  test('cos of View', () {
    var base = array([
      [0, math.pi / 2, math.pi],
      [math.pi, 3 * math.pi / 2, 2 * math.pi]
    ]);
    var view =
        base[[Slice(null, null), Slice(1, null)]]; // [[pi/2, pi], [3pi/2, 2pi]]
    var expected = array([
      [0.0, -1.0],
      [0.0, 1.0]
    ], dtype: Float64List);
    var result = view.cos();
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
