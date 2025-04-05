part of 'elementwise_math_test.dart';

void _testTanGroup() {
  group('NdArray Tangent (tan)', () {
    _testTan1DInteger();
    _testTan1DDouble();
    _testTan2D();
    _testTanEmptyArray();
    _testTanView();
    _testTanNearAsymptotes();
  });
}

void _testTan1DInteger() {
  test('tan of 1D Integer Array (as radians)', () {
    var a = array([0, 1]); // Interpreted as radians
    var expected = array([math.tan(0), math.tan(1)], dtype: Float64List);
    var result = a.tan();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    for (int i = 0; i < result.size; i++) {
      expect(result.toList()[i], closeTo(expected.toList()[i], 1e-9));
    }
  });
}

void _testTan1DDouble() {
  test('tan of 1D Double Array (radians)', () {
    var a = array([0.0, math.pi / 4, math.pi]);
    var expected = array([0.0, 1.0, 0.0], dtype: Float64List);
    var result = a.tan();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    for (int i = 0; i < result.size; i++) {
      expect(result.toList()[i], closeTo(expected.toList()[i], 1e-9));
    }
  });
}

void _testTan2D() {
  test('tan of 2D Array (radians)', () {
    var a = array([
      [0, math.pi / 4],
      [math.pi, 3 * math.pi / 4]
    ]);
    var expected = array([
      [0.0, 1.0],
      [0.0, -1.0]
    ], dtype: Float64List);
    var result = a.tan();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList()[0][0], closeTo(expected.toList()[0][0], 1e-9));
    expect(result.toList()[0][1], closeTo(expected.toList()[0][1], 1e-9));
    expect(result.toList()[1][0], closeTo(expected.toList()[1][0], 1e-9));
    expect(result.toList()[1][1], closeTo(expected.toList()[1][1], 1e-9));
  });
}

void _testTanEmptyArray() {
  test('tan of Empty Array', () {
    var a = zeros([0]);
    var expected = zeros([0], dtype: Float64List);
    var result = a.tan();
    expect(result.shape, equals(expected.shape));
    expect(result.size, equals(0));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList(), equals(expected.toList()));

    var c = zeros([2, 0], dtype: Int32List);
    var expected2 = zeros([2, 0], dtype: Float64List);
    var result2 = c.tan();
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

void _testTanView() {
  test('tan of View', () {
    var base = array([
      [0, math.pi / 4, math.pi],
      [math.pi, 3 * math.pi / 4, 2 * math.pi]
    ]);
    var view =
        base[[Slice(null, null), Slice(1, null)]]; // [[pi/4, pi], [3pi/4, 2pi]]
    var expected = array([
      [1.0, 0.0],
      [-1.0, 0.0]
    ], dtype: Float64List);
    var result = view.tan();
    expect(result.shape, equals(expected.shape));
    expect(result.dtype, equals(double));
    expect(result.data, isA<Float64List>());
    expect(result.toList()[0][0], closeTo(expected.toList()[0][0], 1e-9));
    expect(result.toList()[0][1], closeTo(expected.toList()[0][1], 1e-9));
    expect(result.toList()[1][0], closeTo(expected.toList()[1][0], 1e-9));
    expect(result.toList()[1][1], closeTo(expected.toList()[1][1], 1e-9));
    // Ensure original base array is unchanged
    expect(base.toList()[0][1], closeTo(math.pi / 4, 1e-9)); // Check a value
  });
}

void _testTanNearAsymptotes() {
  // Test tan at asymptotes (pi/2, 3pi/2, etc.) - should approach infinity
  test('tan near asymptotes', () {
    // Values very close to pi/2 and 3pi/2
    var a =
        array([math.pi / 2 - 1e-9, math.pi / 2 + 1e-9, 3 * math.pi / 2 - 1e-9]);
    var result = a.tan();
    expect(result.dtype, equals(double));
    // Expect very large positive or negative values
    expect(result.toList()[0], greaterThan(1e8));
    expect(result.toList()[1], lessThan(-1e8)); // Should be very large negative
    expect(result.toList()[2], greaterThan(1e8));
  });
}
