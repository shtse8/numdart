import 'dart:typed_data';
import 'dart:math' as math; // Import math library with prefix
import 'dart:math'; // For isNaN checks

import 'package:test/test.dart';
import 'package:numdart/numdart.dart';
import 'package:collection/collection.dart'; // For deep equality checks

void main() {
  group('NdArray Square Root (sqrt)', () {
    test('sqrt of 1D Integer Array', () {
      var a = NdArray.array([0, 1, 4, 9, 16, 25]);
      var expected =
          NdArray.array([0.0, 1.0, 2.0, 3.0, 4.0, 5.0], dtype: Float64List);
      var result = a.sqrt();
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      expect(result.toList(), equals(expected.toList()));
    });

    test('sqrt of 1D Double Array', () {
      var a = NdArray.array([0.0, 1.0, 2.25, 6.25]);
      var expected = NdArray.array([0.0, 1.0, 1.5, 2.5], dtype: Float64List);
      var result = a.sqrt();
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      expect(result.toList(), equals(expected.toList()));
    });

    test('sqrt of 2D Array', () {
      var a = NdArray.array([
        [4, 9],
        [1, 16]
      ]);
      var expected = NdArray.array([
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

    test('sqrt with Negative Numbers (results in NaN)', () {
      var a = NdArray.array([4.0, -9.0, 16.0, -1.0]);
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

    test('sqrt of Empty Array', () {
      var a = NdArray.zeros([0]);
      var expected = NdArray.zeros([0], dtype: Float64List);
      var result = a.sqrt();

      expect(result.shape, equals(expected.shape));
      expect(result.size, equals(0));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      expect(result.toList(), equals(expected.toList()));

      var c = NdArray.zeros([2, 0], dtype: Int32List);
      var expected2 = NdArray.zeros([2, 0], dtype: Float64List);
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

    test('sqrt of View', () {
      var base = NdArray.array([
        [1, 4, 9],
        [16, 25, 36]
      ]);
      var view =
          base[[Slice(null, null), Slice(1, null)]]; // [[4, 9], [25, 36]]
      var expected = NdArray.array([
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
  }); // End of sqrt group

  group('NdArray Exponential (exp)', () {
    test('exp of 1D Integer Array', () {
      var a = NdArray.array([0, 1, 2, -1]);
      var expected = NdArray.array(
          [math.exp(0), math.exp(1), math.exp(2), math.exp(-1)],
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

    test('exp of 1D Double Array', () {
      var a = NdArray.array([0.0, 1.0, -0.5, 2.5]);
      var expected = NdArray.array(
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

    test('exp of 2D Array', () {
      var a = NdArray.array([
        [0, 1],
        [-1, 2]
      ]);
      var expected = NdArray.array([
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

    test('exp of Empty Array', () {
      var a = NdArray.zeros([0]);
      var expected = NdArray.zeros([0], dtype: Float64List);
      var result = a.exp();
      expect(result.shape, equals(expected.shape));
      expect(result.size, equals(0));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      expect(result.toList(), equals(expected.toList()));

      var c = NdArray.zeros([2, 0], dtype: Int32List);
      var expected2 = NdArray.zeros([2, 0], dtype: Float64List);
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

    test('exp of View', () {
      var base = NdArray.array([
        [0, 1, 2],
        [3, 4, 5]
      ]);
      var view = base[[Slice(null, null), Slice(1, null)]]; // [[1, 2], [4, 5]]
      var expected = NdArray.array([
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
  }); // End of exp group

  group('NdArray Sine (sin)', () {
    test('sin of 1D Integer Array (as radians)', () {
      var a = NdArray.array([0, 1, 2]); // Interpreted as radians
      var expected = NdArray.array([math.sin(0), math.sin(1), math.sin(2)],
          dtype: Float64List);
      var result = a.sin();
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      for (int i = 0; i < result.size; i++) {
        expect(result.toList()[i], closeTo(expected.toList()[i], 1e-9));
      }
    });

    test('sin of 1D Double Array (radians)', () {
      var a = NdArray.array(
          [0.0, math.pi / 2, math.pi, 3 * math.pi / 2, 2 * math.pi]);
      var expected =
          NdArray.array([0.0, 1.0, 0.0, -1.0, 0.0], dtype: Float64List);
      var result = a.sin();
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      for (int i = 0; i < result.size; i++) {
        expect(result.toList()[i], closeTo(expected.toList()[i], 1e-9));
      }
    });

    test('sin of 2D Array (radians)', () {
      var a = NdArray.array([
        [0, math.pi / 2],
        [math.pi, 3 * math.pi / 2]
      ]);
      var expected = NdArray.array([
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

    test('sin of Empty Array', () {
      var a = NdArray.zeros([0]);
      var expected = NdArray.zeros([0], dtype: Float64List);
      var result = a.sin();
      expect(result.shape, equals(expected.shape));
      expect(result.size, equals(0));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      expect(result.toList(), equals(expected.toList()));

      var c = NdArray.zeros([2, 0], dtype: Int32List);
      var expected2 = NdArray.zeros([2, 0], dtype: Float64List);
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

    test('sin of View', () {
      var base = NdArray.array([
        [0, math.pi / 2, math.pi],
        [math.pi, 3 * math.pi / 2, 2 * math.pi]
      ]);
      var view = base[[
        Slice(null, null),
        Slice(1, null)
      ]]; // [[pi/2, pi], [3pi/2, 2pi]]
      var expected = NdArray.array([
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
  }); // End of sin group

  group('NdArray Cosine (cos)', () {
    test('cos of 1D Integer Array (as radians)', () {
      var a = NdArray.array([0, 1, 2]); // Interpreted as radians
      var expected = NdArray.array([math.cos(0), math.cos(1), math.cos(2)],
          dtype: Float64List);
      var result = a.cos();
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      for (int i = 0; i < result.size; i++) {
        expect(result.toList()[i], closeTo(expected.toList()[i], 1e-9));
      }
    });

    test('cos of 1D Double Array (radians)', () {
      var a = NdArray.array(
          [0.0, math.pi / 2, math.pi, 3 * math.pi / 2, 2 * math.pi]);
      var expected =
          NdArray.array([1.0, 0.0, -1.0, 0.0, 1.0], dtype: Float64List);
      var result = a.cos();
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      for (int i = 0; i < result.size; i++) {
        expect(result.toList()[i], closeTo(expected.toList()[i], 1e-9));
      }
    });

    test('cos of 2D Array (radians)', () {
      var a = NdArray.array([
        [0, math.pi / 2],
        [math.pi, 3 * math.pi / 2]
      ]);
      var expected = NdArray.array([
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

    test('cos of Empty Array', () {
      var a = NdArray.zeros([0]);
      var expected = NdArray.zeros([0], dtype: Float64List);
      var result = a.cos();
      expect(result.shape, equals(expected.shape));
      expect(result.size, equals(0));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      expect(result.toList(), equals(expected.toList()));

      var c = NdArray.zeros([2, 0], dtype: Int32List);
      var expected2 = NdArray.zeros([2, 0], dtype: Float64List);
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

    test('cos of View', () {
      var base = NdArray.array([
        [0, math.pi / 2, math.pi],
        [math.pi, 3 * math.pi / 2, 2 * math.pi]
      ]);
      var view = base[[
        Slice(null, null),
        Slice(1, null)
      ]]; // [[pi/2, pi], [3pi/2, 2pi]]
      var expected = NdArray.array([
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
  }); // End of cos group

  group('NdArray Tangent (tan)', () {
    test('tan of 1D Integer Array (as radians)', () {
      var a = NdArray.array([0, 1]); // Interpreted as radians
      var expected =
          NdArray.array([math.tan(0), math.tan(1)], dtype: Float64List);
      var result = a.tan();
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      for (int i = 0; i < result.size; i++) {
        expect(result.toList()[i], closeTo(expected.toList()[i], 1e-9));
      }
    });

    test('tan of 1D Double Array (radians)', () {
      var a = NdArray.array([0.0, math.pi / 4, math.pi]);
      var expected = NdArray.array([0.0, 1.0, 0.0], dtype: Float64List);
      var result = a.tan();
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      for (int i = 0; i < result.size; i++) {
        expect(result.toList()[i], closeTo(expected.toList()[i], 1e-9));
      }
    });

    test('tan of 2D Array (radians)', () {
      var a = NdArray.array([
        [0, math.pi / 4],
        [math.pi, 3 * math.pi / 4]
      ]);
      var expected = NdArray.array([
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

    test('tan of Empty Array', () {
      var a = NdArray.zeros([0]);
      var expected = NdArray.zeros([0], dtype: Float64List);
      var result = a.tan();
      expect(result.shape, equals(expected.shape));
      expect(result.size, equals(0));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      expect(result.toList(), equals(expected.toList()));

      var c = NdArray.zeros([2, 0], dtype: Int32List);
      var expected2 = NdArray.zeros([2, 0], dtype: Float64List);
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

    test('tan of View', () {
      var base = NdArray.array([
        [0, math.pi / 4, math.pi],
        [math.pi, 3 * math.pi / 4, 2 * math.pi]
      ]);
      var view = base[[
        Slice(null, null),
        Slice(1, null)
      ]]; // [[pi/4, pi], [3pi/4, 2pi]]
      var expected = NdArray.array([
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

    // Test tan at asymptotes (pi/2, 3pi/2, etc.) - should approach infinity
    test('tan near asymptotes', () {
      // Values very close to pi/2 and 3pi/2
      var a = NdArray.array(
          [math.pi / 2 - 1e-9, math.pi / 2 + 1e-9, 3 * math.pi / 2 - 1e-9]);
      var result = a.tan();
      expect(result.dtype, equals(double));
      // Expect very large positive or negative values
      expect(result.toList()[0], greaterThan(1e8));
      expect(
          result.toList()[1], lessThan(-1e8)); // Should be very large negative
      expect(result.toList()[2], greaterThan(1e8));
    });
  }); // End of tan group

  group('NdArray Natural Logarithm (log)', () {
    test('log of 1D Integer Array', () {
      var a = NdArray.array([1, 2, 10]);
      var expected = NdArray.array([math.log(1), math.log(2), math.log(10)],
          dtype: Float64List);
      var result = a.log();
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      for (int i = 0; i < result.size; i++) {
        expect(result.toList()[i], closeTo(expected.toList()[i], 1e-9));
      }
    });

    test('log of 1D Double Array', () {
      var a = NdArray.array([1.0, math.e, 10.0, 0.5]);
      var expected = NdArray.array([0.0, 1.0, math.log(10.0), math.log(0.5)],
          dtype: Float64List);
      var result = a.log();
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      for (int i = 0; i < result.size; i++) {
        expect(result.toList()[i], closeTo(expected.toList()[i], 1e-9));
      }
    });

    test('log of 2D Array', () {
      var a = NdArray.array([
        [1, math.e],
        [10, 100]
      ]);
      var expected = NdArray.array([
        [0.0, 1.0],
        [math.log(10), math.log(100)]
      ], dtype: Float64List);
      var result = a.log();
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      expect(result.toList()[0][0], closeTo(expected.toList()[0][0], 1e-9));
      expect(result.toList()[0][1], closeTo(expected.toList()[0][1], 1e-9));
      expect(result.toList()[1][0], closeTo(expected.toList()[1][0], 1e-9));
      expect(result.toList()[1][1], closeTo(expected.toList()[1][1], 1e-9));
    });

    test('log of Zero and Negative Numbers', () {
      var a = NdArray.array([1.0, 0.0, -1.0, -math.e]);
      var result = a.log();
      expect(result.shape, equals([4]));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      var listResult = result.toList();
      expect(listResult[0], closeTo(0.0, 1e-9));
      expect(listResult[1], equals(double.negativeInfinity));
      expect(listResult[2].isNaN, isTrue);
      expect(listResult[3].isNaN, isTrue);
    });

    test('log of Empty Array', () {
      var a = NdArray.zeros([0]);
      var expected = NdArray.zeros([0], dtype: Float64List);
      var result = a.log();
      expect(result.shape, equals(expected.shape));
      expect(result.size, equals(0));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      expect(result.toList(), equals(expected.toList()));

      var c = NdArray.zeros([2, 0], dtype: Int32List);
      var expected2 = NdArray.zeros([2, 0], dtype: Float64List);
      var result2 = c.log();
      expect(result2.shape, equals(expected2.shape));
      expect(result2.size, equals(0));
      expect(result2.dtype, equals(double));
      expect(result2.data, isA<Float64List>());
      expect(
          const DeepCollectionEquality()
              .equals(result2.toList(), expected2.toList()),
          isTrue);
    });

    test('log of View', () {
      var base = NdArray.array([
        [1, math.e, 10],
        [100, 0, -5]
      ]);
      var view =
          base[[Slice(null, null), Slice(1, null)]]; // [[e, 10], [0, -5]]
      var result = view.log();
      expect(result.shape, equals([2, 2]));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      var listResult = result.toList();
      expect(listResult[0][0], closeTo(1.0, 1e-9));
      expect(listResult[0][1], closeTo(math.log(10), 1e-9));
      expect(listResult[1][0], equals(double.negativeInfinity));
      expect(listResult[1][1].isNaN, isTrue);
      // Ensure original base array is unchanged
      expect(base.toList()[1][2], equals(-5)); // Check a value
    });
  }); // End of log group
}
