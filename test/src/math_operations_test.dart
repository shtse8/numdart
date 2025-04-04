import 'dart:typed_data';

import 'package:test/test.dart';
import 'package:numdart/numdart.dart';
import 'package:collection/collection.dart'; // For deep equality checks

void main() {
  group('NdArray Addition (operator+)', () {
    test('1D Integer Addition', () {
      var a = NdArray.array([1, 2, 3]);
      var b = NdArray.array([4, 5, 6]);
      var expected = NdArray.array([5, 7, 9]);
      var result = a + b;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(expected.dtype));
      expect(result.toList(), equals(expected.toList()));
    });

    test('1D Double Addition', () {
      var a = NdArray.array([1.0, 2.5, 3.0]);
      var b = NdArray.array([4.0, 0.5, 6.9]);
      var expected = NdArray.array([5.0, 3.0, 9.9]);
      var result = a + b;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(expected.dtype));
      // Use ListEquality for potential floating point inaccuracies if needed,
      // but direct comparison should work for these simple values.
      expect(result.toList(), equals(expected.toList()));
    });

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
      expect(result.dtype, equals(expected.dtype));
      // Use DeepCollectionEquality for nested lists
      expect(
          const DeepCollectionEquality()
              .equals(result.toList(), expected.toList()),
          isTrue);
    });

    test('Addition with Views (Slices)', () {
      var base = NdArray.arange(10); // [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
      var a = base[[Slice(1, 5)]]; // View [1, 2, 3, 4]
      var b = base[[Slice(5, 9)]]; // View [5, 6, 7, 8]
      var expected = NdArray.array([6, 8, 10, 12]);
      var result = a + b;

      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(expected.dtype));
      expect(result.toList(), equals(expected.toList()));
      // Ensure original base array is unchanged
      expect(base.toList(), equals([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]));
    });

    test('Addition of Empty Arrays', () {
      var a = NdArray.zeros([0]);
      var b = NdArray.zeros([0]);
      var expected = NdArray.zeros([0]);
      var result = a + b;
      expect(result.shape, equals(expected.shape));
      expect(result.size, equals(0));
      expect(result.toList(), equals(expected.toList()));

      var c = NdArray.zeros([2, 0]);
      var d = NdArray.zeros([2, 0]);
      var expected2 = NdArray.zeros([2, 0]);
      var result2 = c + d;
      expect(result2.shape, equals(expected2.shape));
      expect(result2.size, equals(0));
      expect(
          const DeepCollectionEquality()
              .equals(result2.toList(), expected2.toList()),
          isTrue);
    });

    test('Throws ArgumentError for different shapes', () {
      var a = NdArray.array([1, 2, 3]);
      var b = NdArray.array([4, 5]);
      expect(() => a + b, throwsArgumentError);

      var c = NdArray.zeros([2, 3]);
      var d = NdArray.zeros([3, 2]);
      expect(() => c + d, throwsArgumentError);
    });

    test('Throws ArgumentError for different dtypes (currently)', () {
      var a = NdArray.array([1, 2, 3], dtype: Int32List);
      var b = NdArray.array([4.0, 5.0, 6.0], dtype: Float64List);
      // Expect error because current implementation requires same dtype
      expect(() => a + b, throwsArgumentError);
    });

    group('NdArray Subtraction (operator-)', () {
      test('1D Integer Subtraction', () {
        var a = NdArray.array([5, 7, 9]);
        var b = NdArray.array([1, 2, 3]);
        var expected = NdArray.array([4, 5, 6]);
        var result = a - b;
        expect(result.shape, equals(expected.shape));
        expect(result.dtype, equals(expected.dtype));
        expect(result.toList(), equals(expected.toList()));
      });

      test('1D Double Subtraction', () {
        var a = NdArray.array([5.0, 3.0, 9.9]);
        var b = NdArray.array([1.0, 0.5, 6.9]);
        var expected = NdArray.array([4.0, 2.5, 3.0]);
        var result = a - b;
        expect(result.shape, equals(expected.shape));
        expect(result.dtype, equals(expected.dtype));
        expect(result.toList(), equals(expected.toList()));
      });

      test('2D Integer Subtraction', () {
        var a = NdArray.array([
          [6, 8],
          [10, 12]
        ]);
        var b = NdArray.array([
          [5, 6],
          [7, 8]
        ]);
        var expected = NdArray.array([
          [1, 2],
          [3, 4]
        ]);
        var result = a - b;
        expect(result.shape, equals(expected.shape));
        expect(result.dtype, equals(expected.dtype));
        expect(
            const DeepCollectionEquality()
                .equals(result.toList(), expected.toList()),
            isTrue);
      });

      test('Subtraction with Views (Slices)', () {
        var base = NdArray.arange(10); // [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        var a = base[[Slice(5, 9)]]; // View [5, 6, 7, 8]
        var b = base[[Slice(1, 5)]]; // View [1, 2, 3, 4]
        var expected = NdArray.array([4, 4, 4, 4]);
        var result = a - b;

        expect(result.shape, equals(expected.shape));
        expect(result.dtype, equals(expected.dtype));
        expect(result.toList(), equals(expected.toList()));
        // Ensure original base array is unchanged
        expect(base.toList(), equals([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]));
      });

      test('Subtraction of Empty Arrays', () {
        var a = NdArray.zeros([0]);
        var b = NdArray.zeros([0]);
        var expected = NdArray.zeros([0]);
        var result = a - b;
        expect(result.shape, equals(expected.shape));
        expect(result.size, equals(0));
        expect(result.toList(), equals(expected.toList()));

        var c = NdArray.zeros([2, 0]);
        var d = NdArray.zeros([2, 0]);
        var expected2 = NdArray.zeros([2, 0]);
        var result2 = c - d;
        expect(result2.shape, equals(expected2.shape));
        expect(result2.size, equals(0));
        expect(
            const DeepCollectionEquality()
                .equals(result2.toList(), expected2.toList()),
            isTrue);
      });

      test('Throws ArgumentError for different shapes', () {
        var a = NdArray.array([1, 2, 3]);
        var b = NdArray.array([4, 5]);
        expect(() => a - b, throwsArgumentError);

        var c = NdArray.zeros([2, 3]);
        var d = NdArray.zeros([3, 2]);
        expect(() => c - d, throwsArgumentError);
      });

      test('Throws ArgumentError for different dtypes (currently)', () {
        var a = NdArray.array([1, 2, 3], dtype: Int32List);
        var b = NdArray.array([4.0, 5.0, 6.0], dtype: Float64List);
        // Expect error because current implementation requires same dtype
        expect(() => a - b, throwsArgumentError);
      });

      group('NdArray Multiplication (operator*)', () {
        test('1D Integer Multiplication', () {
          var a = NdArray.array([1, 2, 3]);
          var b = NdArray.array([4, 5, 6]);
          var expected = NdArray.array([4, 10, 18]);
          var result = a * b;
          expect(result.shape, equals(expected.shape));
          expect(result.dtype, equals(expected.dtype));
          expect(result.toList(), equals(expected.toList()));
        });

        test('1D Double Multiplication', () {
          var a = NdArray.array([1.0, 2.5, 3.0]);
          var b = NdArray.array([4.0, 0.5, 2.0]);
          var expected = NdArray.array([4.0, 1.25, 6.0]);
          var result = a * b;
          expect(result.shape, equals(expected.shape));
          expect(result.dtype, equals(expected.dtype));
          expect(result.toList(), equals(expected.toList()));
        });

        test('Multiplication with zero', () {
          var a = NdArray.array([1, 2, 3]);
          var b = NdArray.zeros([3], dtype: Int64List);
          var expected = NdArray.zeros([3], dtype: Int64List);
          var result = a * b;
          expect(result.shape, equals(expected.shape));
          expect(result.dtype, equals(expected.dtype));
          expect(result.toList(), equals(expected.toList()));

          var c = NdArray.array([0.0, 5.0, 0.0]);
          var d = NdArray.array([10.0, 0.0, 20.0]);
          var expected2 = NdArray.array([0.0, 0.0, 0.0]);
          var result2 = c * d;
          expect(result2.shape, equals(expected2.shape));
          expect(result2.dtype, equals(expected2.dtype));
          expect(result2.toList(), equals(expected2.toList()));
        });

        test('2D Integer Multiplication', () {
          var a = NdArray.array([
            [1, 2],
            [3, 4]
          ]);
          var b = NdArray.array([
            [5, 6],
            [7, 8]
          ]);
          var expected = NdArray.array([
            [5, 12],
            [21, 32]
          ]);
          var result = a * b;
          expect(result.shape, equals(expected.shape));
          expect(result.dtype, equals(expected.dtype));
          expect(
              const DeepCollectionEquality()
                  .equals(result.toList(), expected.toList()),
              isTrue);
        });

        test('Multiplication with Views (Slices)', () {
          var base = NdArray.arange(10); // [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
          var a = base[[Slice(1, 5)]]; // View [1, 2, 3, 4]
          var b = base[[Slice(5, 9)]]; // View [5, 6, 7, 8]
          var expected = NdArray.array([5, 12, 21, 32]);
          var result = a * b;

          expect(result.shape, equals(expected.shape));
          expect(result.dtype, equals(expected.dtype));
          expect(result.toList(), equals(expected.toList()));
          // Ensure original base array is unchanged
          expect(base.toList(), equals([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]));
        });

        test('Multiplication of Empty Arrays', () {
          var a = NdArray.zeros([0]);
          var b = NdArray.zeros([0]);
          var expected = NdArray.zeros([0]);
          var result = a * b;
          expect(result.shape, equals(expected.shape));
          expect(result.size, equals(0));
          expect(result.toList(), equals(expected.toList()));

          var c = NdArray.zeros([2, 0]);
          var d = NdArray.zeros([2, 0]);
          var expected2 = NdArray.zeros([2, 0]);
          var result2 = c * d;
          expect(result2.shape, equals(expected2.shape));
          expect(result2.size, equals(0));
          expect(
              const DeepCollectionEquality()
                  .equals(result2.toList(), expected2.toList()),
              isTrue);
        });

        test('Throws ArgumentError for different shapes', () {
          var a = NdArray.array([1, 2, 3]);
          var b = NdArray.array([4, 5]);
          expect(() => a * b, throwsArgumentError);

          var c = NdArray.zeros([2, 3]);
          var d = NdArray.zeros([3, 2]);
          expect(() => c * d, throwsArgumentError);
        });

        test('Throws ArgumentError for different dtypes (currently)', () {
          var a = NdArray.array([1, 2, 3], dtype: Int32List);
          var b = NdArray.array([4.0, 5.0, 6.0], dtype: Float64List);
          // Expect error because current implementation requires same dtype
          expect(() => a * b, throwsArgumentError);
        });
      }); // End of Multiplication group
    }); // End of Subtraction group
  });
}
