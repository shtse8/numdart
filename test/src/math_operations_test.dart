import 'dart:typed_data';
import 'dart:math' as math; // Import math library with prefix
import 'dart:math'; // For isNaN checks

import 'package:test/test.dart';
import 'package:numdart/numdart.dart';
import 'package:collection/collection.dart'; // For deep equality checks

void main() {
  group('NdArray Addition (operator+)', () {
    // --- Existing Tests ---
    test('1D Integer Addition', () {
      var a = NdArray.array([1, 2, 3]);
      var b = NdArray.array([4, 5, 6]);
      var expected = NdArray.array([5, 7, 9]);
      var result = a + b;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(int)); // Check primitive type
      expect(result.toList(), equals(expected.toList()));
    });

    test('1D Double Addition', () {
      var a = NdArray.array([1.0, 2.5, 3.0]);
      var b = NdArray.array([4.0, 0.5, 6.9]);
      var expected = NdArray.array([5.0, 3.0, 9.9]);
      var result = a + b;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double)); // Check primitive type
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
      expect(result.dtype, equals(int)); // Check primitive type
      // Use DeepCollectionEquality for nested lists
      expect(
          const DeepCollectionEquality()
              .equals(result.toList(), expected.toList()),
          isTrue);
    });

    test('Addition with Views (Slices)', () {
      var base =
          NdArray.arange(10); // [0, 1, 2, 3, 4, 5, 6, 7, 8, 9] dtype=Int64List
      var a = base[[Slice(1, 5)]]; // View [1, 2, 3, 4]
      var b = base[[Slice(5, 9)]]; // View [5, 6, 7, 8]
      var expected = NdArray.array([6, 8, 10, 12]);
      var result = a + b;

      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(int)); // Check primitive type
      expect(result.toList(), equals(expected.toList()));
      // Ensure original base array is unchanged
      expect(base.toList(), equals([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]));
    });

    test('Addition of Empty Arrays', () {
      var a = NdArray.zeros([0]); // Float64List default
      var b = NdArray.zeros([0]); // Float64List default
      var expected = NdArray.zeros([0]);
      var result = a + b;
      expect(result.shape, equals(expected.shape));
      expect(result.size, equals(0));
      expect(result.dtype, equals(double));
      expect(result.toList(), equals(expected.toList()));

      var c = NdArray.zeros([2, 0], dtype: Int32List);
      var d = NdArray.zeros([2, 0], dtype: Int32List);
      var expected2 = NdArray.zeros([2, 0],
          dtype: Int64List); // Result promotes to Int64List
      var result2 = c + d;
      expect(result2.shape, equals(expected2.shape));
      expect(result2.size, equals(0));
      expect(result2.dtype, equals(int));
      expect(
          const DeepCollectionEquality()
              .equals(result2.toList(), expected2.toList()),
          isTrue);
    });

    // REMOVED: test('Throws ArgumentError for different dtypes (currently)', () { /* ... */ }); // Now supported

    test('Scalar Addition (NdArray + int)', () {
      var a = NdArray.array([1, 2, 3]); // Int64List default
      var scalar = 10;
      var expected = NdArray.array([11, 12, 13]);
      var result = a + scalar;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(int)); // Stays int
      expect(result.toList(), equals(expected.toList()));
    });

    test('Scalar Addition (NdArray + double)', () {
      var a = NdArray.array([1.0, 2.5, 3.0]); // Float64List default
      var scalar = 0.5;
      var expected = NdArray.array([1.5, 3.0, 3.5]);
      var result = a + scalar;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double)); // Stays double
      expect(result.toList(), equals(expected.toList()));
    });

    test('Scalar Addition with Type Promotion (int Array + double scalar)', () {
      var a = NdArray.array([1, 2, 3]); // Int64List default
      var scalar = 0.5;
      var expected = NdArray.array([1.5, 2.5, 3.5], dtype: Float64List);
      var result = a + scalar;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double)); // Promotes to double
      expect(result.data, isA<Float64List>());
      expect(result.toList(), equals(expected.toList()));
    });

    test('Scalar Addition with 2D Array', () {
      var a = NdArray.array([
        [1, 2],
        [3, 4]
      ]); // Int64List default
      var scalar = 100;
      var expected = NdArray.array([
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

    test('Scalar Addition with View', () {
      var base = NdArray.arange(6).reshape([2, 3]); // Int64List default
      var view = base[[Slice(null, null), Slice(1, null)]];
      var scalar = 10;
      var expected = NdArray.array([
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

    test('Scalar Addition with Empty Array', () {
      var a = NdArray.zeros([0]); // Float64List default
      var scalar = 5;
      var expected = NdArray.zeros([0]);
      var result = a + scalar;
      expect(result.shape, equals(expected.shape));
      expect(result.size, equals(0));
      expect(result.dtype,
          equals(double)); // Should now correctly promote to double
      expect(result.toList(), equals(expected.toList()));
    });

    test('Throws ArgumentError for invalid scalar type', () {
      var a = NdArray.array([1, 2, 3]);
      expect(() => a + 'hello', throwsArgumentError);
      expect(() => a + true, throwsArgumentError);
      expect(() => a + null, throwsArgumentError);
    });

    // --- Broadcasting Tests ---
    test('Broadcasting Addition: 2D + 1D (Row)', () {
      var a = NdArray.array([
        [1, 2, 3],
        [4, 5, 6]
      ]); // Int64List default
      var b = NdArray.array([10, 20, 30]); // Int64List default
      var expected = NdArray.array([
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

    test('Broadcasting Addition: 2D + 1D (Column)', () {
      var a = NdArray.array([
        [1, 2, 3],
        [4, 5, 6]
      ]); // Int64List default
      var b = NdArray.array([
        [10],
        [20]
      ]); // Int64List default
      var expected = NdArray.array([
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

    test('Broadcasting Addition: 1D + 2D (Column)', () {
      var a = NdArray.array([10, 20]); // Int64List default
      var b = NdArray.array([
        [1, 2, 3],
        [4, 5, 6]
      ]); // Int64List default
      var aCol = a.reshape([2, 1]);
      var expected = NdArray.array([
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

    test('Broadcasting Addition: Different Dimensions', () {
      var a = NdArray.array([
        [
          [1, 2],
          [3, 4]
        ],
        [
          [5, 6],
          [7, 8]
        ]
      ]); // Int64List default
      var b = NdArray.array([10, 20]); // Int64List default
      var expected = NdArray.array([
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

    test('Broadcasting Addition: Scalar Array', () {
      var a = NdArray.array([
        [1, 2],
        [3, 4]
      ]); // Int64List default
      var scalar = 10;
      var expected = NdArray.array([
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

    test('Throws ArgumentError for incompatible broadcast shapes', () {
      var a = NdArray.array([
        [1, 2, 3],
        [4, 5, 6]
      ]);
      var b = NdArray.array([10, 20]);
      expect(() => a + b, throwsArgumentError);

      var c = NdArray.zeros([2, 3, 4]);
      var d = NdArray.zeros([2, 1, 5]);
      expect(() => c + d, throwsArgumentError);
    });

    test('Broadcasting Addition with Empty Arrays', () {
      var a = NdArray.zeros([2, 0]); // Float64List default
      var b = NdArray.zeros([0]); // Float64List default
      var expected = NdArray.zeros([2, 0]);
      var result = a + b;
      expect(result.shape, equals(expected.shape));
      expect(result.size, equals(0));
      expect(result.dtype, equals(double));

      var c = NdArray.zeros([0, 3], dtype: Int32List);
      var d = NdArray.zeros([1, 3], dtype: Int32List);
      var expected2 =
          NdArray.zeros([0, 3], dtype: Int64List); // Promotes to Int64List
      var result2 = c + d;
      expect(result2.shape, equals(expected2.shape));
      expect(result2.size, equals(0));
      expect(result2.dtype, equals(int));

      var e = NdArray.zeros([0, 0]); // Float64List default
      var f = NdArray.zeros([1, 0]); // Float64List default
      var expected3 = NdArray.zeros([0, 0]);
      var result3 = e + f;
      expect(result3.shape, equals(expected3.shape));
      expect(result3.size, equals(0));
      expect(result3.dtype, equals(double));

      var g = NdArray.zeros([2, 0]);
      var h = NdArray.zeros([3, 0]);
      expect(() => g + h, throwsArgumentError);
    });

    // --- Type Promotion Tests ---
    test('Type Promotion Addition: int + double', () {
      var a = NdArray.array([1, 2, 3], dtype: Int32List);
      var b = NdArray.array([0.5, 1.5, 2.5], dtype: Float64List);
      var expected = NdArray.array([1.5, 3.5, 5.5], dtype: Float64List);
      var result = a + b;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double)); // Result should be double
      expect(result.data, isA<Float64List>());
      expect(result.toList(), equals(expected.toList()));
    });

    test('Type Promotion Addition: double + int', () {
      var a = NdArray.array([0.5, 1.5, 2.5], dtype: Float64List);
      var b = NdArray.array([1, 2, 3], dtype: Int32List);
      var expected = NdArray.array([1.5, 3.5, 5.5], dtype: Float64List);
      var result = a + b;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double)); // Result should be double
      expect(result.data, isA<Float64List>());
      expect(result.toList(), equals(expected.toList()));
    });

    test('Type Promotion Addition with Broadcasting: int[2,3] + double[3]', () {
      var a = NdArray.array([
        [1, 2, 3],
        [4, 5, 6]
      ], dtype: Int32List);
      var b = NdArray.array([0.1, 0.2, 0.3], dtype: Float64List);
      var expected = NdArray.array([
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

    test('Type Promotion Addition with Broadcasting: double[2,3] + int[3]', () {
      var a = NdArray.array([
        [1.1, 2.2, 3.3],
        [4.1, 5.2, 6.3]
      ], dtype: Float64List);
      var b = NdArray.array([1, 2, 3], dtype: Int32List);
      var expected = NdArray.array([
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

    test('Type Promotion Addition with Broadcasting: int[2,1] + double[2,3]',
        () {
      var a = NdArray.array([
        [10],
        [20]
      ], dtype: Int32List);
      var b = NdArray.array([
        [0.1, 0.2, 0.3],
        [0.4, 0.5, 0.6]
      ], dtype: Float64List);
      var expected = NdArray.array([
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
  }); // End of Addition group

  group('NdArray Subtraction (operator-)', () {
    // --- Existing Tests ---
    test('1D Integer Subtraction', () {
      var a = NdArray.array([5, 7, 9]);
      var b = NdArray.array([1, 2, 3]);
      var expected = NdArray.array([4, 5, 6]);
      var result = a - b;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(int));
      expect(result.toList(), equals(expected.toList()));
    });

    test('1D Double Subtraction', () {
      var a = NdArray.array([5.0, 3.0, 9.9]);
      var b = NdArray.array([1.0, 0.5, 6.9]);
      var expected = NdArray.array([4.0, 2.5, 3.0]);
      var result = a - b;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
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
      expect(result.dtype, equals(int));
      expect(
          const DeepCollectionEquality()
              .equals(result.toList(), expected.toList()),
          isTrue);
    });

    test('Subtraction with Views (Slices)', () {
      var base = NdArray.arange(10);
      var a = base[[Slice(5, 9)]];
      var b = base[[Slice(1, 5)]];
      var expected = NdArray.array([4, 4, 4, 4]);
      var result = a - b;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(int));
      expect(result.toList(), equals(expected.toList()));
      expect(base.toList(), equals([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]));
    });

    test('Subtraction of Empty Arrays', () {
      var a = NdArray.zeros([0]);
      var b = NdArray.zeros([0]);
      var expected = NdArray.zeros([0]);
      var result = a - b;
      expect(result.shape, equals(expected.shape));
      expect(result.size, equals(0));
      expect(result.dtype, equals(double));
      expect(result.toList(), equals(expected.toList()));

      var c = NdArray.zeros([2, 0], dtype: Int32List);
      var d = NdArray.zeros([2, 0], dtype: Int32List);
      var expected2 = NdArray.zeros([2, 0], dtype: Int64List);
      var result2 = c - d;
      expect(result2.shape, equals(expected2.shape));
      expect(result2.size, equals(0));
      expect(result2.dtype, equals(int));
      expect(
          const DeepCollectionEquality()
              .equals(result2.toList(), expected2.toList()),
          isTrue);
    });

    // REMOVED: test('Throws ArgumentError for different dtypes (currently)', () { /* ... */ }); // Now supported

    test('Scalar Subtraction (NdArray - int)', () {
      var a = NdArray.array([11, 12, 13]);
      var scalar = 10;
      var expected = NdArray.array([1, 2, 3]);
      var result = a - scalar;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(int));
      expect(result.toList(), equals(expected.toList()));
    });

    test('Scalar Subtraction (NdArray - double)', () {
      var a = NdArray.array([1.5, 3.0, 3.5]);
      var scalar = 0.5;
      var expected = NdArray.array([1.0, 2.5, 3.0]);
      var result = a - scalar;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.toList(), equals(expected.toList()));
    });

    test('Scalar Subtraction with Type Promotion (int Array - double scalar)',
        () {
      var a = NdArray.array([1, 2, 3]);
      var scalar = 0.5;
      var expected = NdArray.array([0.5, 1.5, 2.5], dtype: Float64List);
      var result = a - scalar;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      expect(result.toList(), equals(expected.toList()));
    });

    test('Scalar Subtraction with 2D Array', () {
      var a = NdArray.array([
        [101, 102],
        [103, 104]
      ]);
      var scalar = 100;
      var expected = NdArray.array([
        [1, 2],
        [3, 4]
      ]);
      var result = a - scalar;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(int));
      expect(
          const DeepCollectionEquality()
              .equals(result.toList(), expected.toList()),
          isTrue);
    });

    test('Scalar Subtraction with View', () {
      var base = NdArray.arange(6).reshape([2, 3]);
      var view = base[[Slice(null, null), Slice(1, null)]];
      var scalar = 1;
      var expected = NdArray.array([
        [0, 1],
        [3, 4]
      ]);
      var result = view - scalar;
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

    test('Scalar Subtraction with Empty Array', () {
      var a = NdArray.zeros([0]);
      var scalar = 5;
      var expected = NdArray.zeros([0]);
      var result = a - scalar;
      expect(result.shape, equals(expected.shape));
      expect(result.size, equals(0));
      expect(result.dtype,
          equals(double)); // Should now correctly promote to double
      expect(result.toList(), equals(expected.toList()));
    });

    test('Throws ArgumentError for invalid scalar type', () {
      var a = NdArray.array([1, 2, 3]);
      expect(() => a - 'hello', throwsArgumentError);
      expect(() => a - true, throwsArgumentError);
      expect(() => a - null, throwsArgumentError);
    });

    // --- Broadcasting Tests ---
    test('Broadcasting Subtraction: 2D - 1D (Row)', () {
      var a = NdArray.array([
        [11, 22, 33],
        [14, 25, 36]
      ]);
      var b = NdArray.array([10, 20, 30]);
      var expected = NdArray.array([
        [1, 2, 3],
        [4, 5, 6]
      ]);
      var result = a - b;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(int));
      expect(
          const DeepCollectionEquality()
              .equals(result.toList(), expected.toList()),
          isTrue);
    });

    test('Broadcasting Subtraction: 2D - 1D (Column)', () {
      var a = NdArray.array([
        [11, 12, 13],
        [24, 25, 26]
      ]);
      var b = NdArray.array([
        [10],
        [20]
      ]);
      var expected = NdArray.array([
        [1, 2, 3],
        [4, 5, 6]
      ]);
      var result = a - b;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(int));
      expect(
          const DeepCollectionEquality()
              .equals(result.toList(), expected.toList()),
          isTrue);
    });

    test('Throws ArgumentError for incompatible broadcast shapes', () {
      var a = NdArray.array([
        [1, 2, 3],
        [4, 5, 6]
      ]);
      var b = NdArray.array([10, 20]);
      expect(() => a - b, throwsArgumentError);
    });

    // --- Type Promotion Tests ---
    test('Type Promotion Subtraction: int - double', () {
      var a = NdArray.array([1, 2, 3], dtype: Int32List);
      var b = NdArray.array([0.5, 0.5, 0.5], dtype: Float64List);
      var expected = NdArray.array([0.5, 1.5, 2.5], dtype: Float64List);
      var result = a - b;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      expect(result.toList(), equals(expected.toList()));
    });

    test('Type Promotion Subtraction: double - int', () {
      var a = NdArray.array([1.5, 2.5, 3.5], dtype: Float64List);
      var b = NdArray.array([1, 1, 1], dtype: Int32List);
      var expected = NdArray.array([0.5, 1.5, 2.5], dtype: Float64List);
      var result = a - b;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      expect(result.toList(), equals(expected.toList()));
    });

    test('Type Promotion Subtraction with Broadcasting: int[2,3] - double[3]',
        () {
      var a = NdArray.array([
        [1, 2, 3],
        [4, 5, 6]
      ], dtype: Int32List);
      var b = NdArray.array([0.1, 0.2, 0.3], dtype: Float64List);
      var expected = NdArray.array([
        [0.9, 1.8, 2.7],
        [3.9, 4.8, 5.7]
      ], dtype: Float64List);
      var result = a - b;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      // Use closeTo for floating point comparisons
      expect(result.toList()[0][0], closeTo(0.9, 1e-9));
      expect(result.toList()[0][1], closeTo(1.8, 1e-9));
      expect(result.toList()[0][2], closeTo(2.7, 1e-9));
      expect(result.toList()[1][0], closeTo(3.9, 1e-9));
      expect(result.toList()[1][1], closeTo(4.8, 1e-9));
      expect(result.toList()[1][2], closeTo(5.7, 1e-9));
    });

    test('Type Promotion Subtraction with Broadcasting: double[2,3] - int[2,1]',
        () {
      var a = NdArray.array([
        [10.1, 10.2, 10.3],
        [20.4, 20.5, 20.6]
      ], dtype: Float64List);
      var b = NdArray.array([
        [10],
        [20]
      ], dtype: Int32List);
      var expected = NdArray.array([
        [0.1, 0.2, 0.3],
        [0.4, 0.5, 0.6]
      ], dtype: Float64List);
      var result = a - b;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      // Use closeTo for floating point comparisons
      expect(result.toList()[0][0], closeTo(0.1, 1e-9));
      expect(result.toList()[0][1], closeTo(0.2, 1e-9));
      expect(result.toList()[0][2], closeTo(0.3, 1e-9));
      expect(result.toList()[1][0], closeTo(0.4, 1e-9));
      expect(result.toList()[1][1], closeTo(0.5, 1e-9));
      expect(result.toList()[1][2], closeTo(0.6, 1e-9));
    });
  }); // End of Subtraction group

  group('NdArray Multiplication (operator*)', () {
    // --- Existing Tests ---
    test('1D Integer Multiplication', () {
      var a = NdArray.array([1, 2, 3]);
      var b = NdArray.array([4, 5, 6]);
      var expected = NdArray.array([4, 10, 18]);
      var result = a * b;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(int));
      expect(result.toList(), equals(expected.toList()));
    });

    test('1D Double Multiplication', () {
      var a = NdArray.array([1.0, 2.5, 3.0]);
      var b = NdArray.array([4.0, 0.5, 2.0]);
      var expected = NdArray.array([4.0, 1.25, 6.0]);
      var result = a * b;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.toList(), equals(expected.toList()));
    });

    test('Multiplication with zero', () {
      var a = NdArray.array([1, 2, 3]);
      var b = NdArray.zeros([3], dtype: Int64List);
      var expected = NdArray.zeros([3], dtype: Int64List);
      var result = a * b;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(int));
      expect(result.toList(), equals(expected.toList()));

      var c = NdArray.array([0.0, 5.0, 0.0]);
      var d = NdArray.array([10.0, 0.0, 20.0]);
      var expected2 = NdArray.array([0.0, 0.0, 0.0]);
      var result2 = c * d;
      expect(result2.shape, equals(expected2.shape));
      expect(result2.dtype, equals(double));
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
      expect(result.dtype, equals(int));
      expect(
          const DeepCollectionEquality()
              .equals(result.toList(), expected.toList()),
          isTrue);
    });

    test('Multiplication with Views (Slices)', () {
      var base = NdArray.arange(10);
      var a = base[[Slice(1, 5)]];
      var b = base[[Slice(5, 9)]];
      var expected = NdArray.array([5, 12, 21, 32]);
      var result = a * b;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(int));
      expect(result.toList(), equals(expected.toList()));
      expect(base.toList(), equals([0, 1, 2, 3, 4, 5, 6, 7, 8, 9]));
    });

    test('Multiplication of Empty Arrays', () {
      var a = NdArray.zeros([0]);
      var b = NdArray.zeros([0]);
      var expected = NdArray.zeros([0]);
      var result = a * b;
      expect(result.shape, equals(expected.shape));
      expect(result.size, equals(0));
      expect(result.dtype, equals(double));
      expect(result.toList(), equals(expected.toList()));

      var c = NdArray.zeros([2, 0], dtype: Int32List);
      var d = NdArray.zeros([2, 0], dtype: Int32List);
      var expected2 = NdArray.zeros([2, 0], dtype: Int64List);
      var result2 = c * d;
      expect(result2.shape, equals(expected2.shape));
      expect(result2.size, equals(0));
      expect(result2.dtype, equals(int));
      expect(
          const DeepCollectionEquality()
              .equals(result2.toList(), expected2.toList()),
          isTrue);
    });

    // REMOVED: test('Throws ArgumentError for different dtypes (currently)', () { /* ... */ }); // Now supported

    test('Scalar Multiplication (NdArray * int)', () {
      var a = NdArray.array([1, 2, 3]);
      var scalar = 10;
      var expected = NdArray.array([10, 20, 30]);
      var result = a * scalar;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(int));
      expect(result.toList(), equals(expected.toList()));
    });

    test('Scalar Multiplication (NdArray * double)', () {
      var a = NdArray.array([1.0, 2.5, 3.0]);
      var scalar = 2.0;
      var expected = NdArray.array([2.0, 5.0, 6.0]);
      var result = a * scalar;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.toList(), equals(expected.toList()));
    });

    test(
        'Scalar Multiplication with Type Promotion (int Array * double scalar)',
        () {
      var a = NdArray.array([1, 2, 3]);
      var scalar = 0.5;
      var expected = NdArray.array([0.5, 1.0, 1.5], dtype: Float64List);
      var result = a * scalar;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      expect(result.toList(), equals(expected.toList()));
    });

    test('Scalar Multiplication with 2D Array', () {
      var a = NdArray.array([
        [1, 2],
        [3, 4]
      ]);
      var scalar = 3;
      var expected = NdArray.array([
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

    test('Scalar Multiplication with View', () {
      var base = NdArray.arange(6).reshape([2, 3]);
      var view = base[[Slice(null, null), Slice(1, null)]];
      var scalar = 2;
      var expected = NdArray.array([
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

    test('Scalar Multiplication with Empty Array', () {
      var a = NdArray.zeros([0]);
      var scalar = 5;
      var expected = NdArray.zeros([0]);
      var result = a * scalar;
      expect(result.shape, equals(expected.shape));
      expect(result.size, equals(0));
      expect(result.dtype,
          equals(double)); // Should now correctly promote to double
      expect(result.toList(), equals(expected.toList()));
    });

    test('Throws ArgumentError for invalid scalar type', () {
      var a = NdArray.array([1, 2, 3]);
      expect(() => a * 'hello', throwsArgumentError);
      expect(() => a * true, throwsArgumentError);
      expect(() => a * null, throwsArgumentError);
    });

    // --- Broadcasting Tests ---
    test('Broadcasting Multiplication: 2D * 1D (Row)', () {
      var a = NdArray.array([
        [1, 2, 3],
        [4, 5, 6]
      ]);
      var b = NdArray.array([10, 20, 30]);
      var expected = NdArray.array([
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

    test('Broadcasting Multiplication: 2D * 1D (Column)', () {
      var a = NdArray.array([
        [1, 2, 3],
        [4, 5, 6]
      ]);
      var b = NdArray.array([
        [10],
        [20]
      ]);
      var expected = NdArray.array([
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

    test('Throws ArgumentError for incompatible broadcast shapes', () {
      var a = NdArray.array([
        [1, 2, 3],
        [4, 5, 6]
      ]);
      var b = NdArray.array([10, 20]);
      expect(() => a * b, throwsArgumentError);
    });

    // --- Type Promotion Tests ---
    test('Type Promotion Multiplication: int * double', () {
      var a = NdArray.array([1, 2, 3], dtype: Int32List);
      var b = NdArray.array([0.5, 2.0, 1.5], dtype: Float64List);
      var expected = NdArray.array([0.5, 4.0, 4.5], dtype: Float64List);
      var result = a * b;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      expect(result.toList(), equals(expected.toList()));
    });

    test('Type Promotion Multiplication: double * int', () {
      var a = NdArray.array([0.5, 2.0, 1.5], dtype: Float64List);
      var b = NdArray.array([2, 3, 4], dtype: Int32List);
      var expected = NdArray.array([1.0, 6.0, 6.0], dtype: Float64List);
      var result = a * b;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      expect(result.toList(), equals(expected.toList()));
    });

    test(
        'Type Promotion Multiplication with Broadcasting: int[2,3] * double[3]',
        () {
      var a = NdArray.array([
        [1, 2, 3],
        [4, 5, 6]
      ], dtype: Int32List);
      var b = NdArray.array([0.5, 2.0, 1.0], dtype: Float64List);
      var expected = NdArray.array([
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

    test(
        'Type Promotion Multiplication with Broadcasting: double[2,1] * int[2,3]',
        () {
      var a = NdArray.array([
        [0.5],
        [2.0]
      ], dtype: Float64List);
      var b = NdArray.array([
        [1, 2, 3],
        [4, 5, 6]
      ], dtype: Int32List);
      var expected = NdArray.array([
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
  }); // End of Multiplication group

  group('NdArray Division (operator/)', () {
    // --- Scalar Division Tests ---
    test('Scalar Division (NdArray / int)', () {
      var a = NdArray.array([10, 20, 30]);
      var scalar = 10;
      var expected = NdArray.array([1.0, 2.0, 3.0], dtype: Float64List);
      var result = a / scalar;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      expect(result.toList(), equals(expected.toList()));
    });

    test('Scalar Division (NdArray / double)', () {
      var a = NdArray.array([2.0, 5.0, 6.0]);
      var scalar = 2.0;
      var expected = NdArray.array([1.0, 2.5, 3.0], dtype: Float64List);
      var result = a / scalar;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      expect(result.toList(), equals(expected.toList()));
    });

    test('Scalar Division with Type Promotion (int Array / int scalar)', () {
      var a = NdArray.array([5, 10, 15]);
      var scalar = 2;
      var expected = NdArray.array([2.5, 5.0, 7.5], dtype: Float64List);
      var result = a / scalar;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      expect(result.toList(), equals(expected.toList()));
    });

    test('Scalar Division with 2D Array', () {
      var a = NdArray.array([
        [3, 6],
        [9, 12]
      ]);
      var scalar = 3;
      var expected = NdArray.array([
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

    test('Scalar Division with View', () {
      var base = NdArray.arange(6).reshape([2, 3]);
      var view = base[[Slice(null, null), Slice(1, null)]];
      var scalar = 2;
      var expected = NdArray.array([
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

    test('Scalar Division with Empty Array', () {
      var a = NdArray.zeros([0]);
      var scalar = 5;
      var expected = NdArray.zeros([0], dtype: Float64List);
      var result = a / scalar;
      expect(result.shape, equals(expected.shape));
      expect(result.size, equals(0));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      expect(result.toList(), equals(expected.toList()));
    });

    test('Scalar Division by Zero', () {
      var a = NdArray.array([1.0, -2.0, 0.0, 5.0]);
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

    test('Scalar Division by Zero (Int Array)', () {
      var a = NdArray.array([1, -2, 0, 5]);
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

    test('Throws ArgumentError for invalid scalar type', () {
      var a = NdArray.array([1, 2, 3]);
      expect(() => a / 'hello', throwsArgumentError);
      expect(() => a / true, throwsArgumentError);
      expect(() => a / null, throwsArgumentError);
    });

    // --- Array-Array Division Tests ---
    test('1D Array Division (Int / Int)', () {
      var a = NdArray.array([10, 20, 30]);
      var b = NdArray.array([2, 5, 10]);
      var expected = NdArray.array([5.0, 4.0, 3.0], dtype: Float64List);
      var result = a / b;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      expect(result.toList(), equals(expected.toList()));
    });

    test('1D Array Division (Double / Double)', () {
      var a = NdArray.array([10.0, 20.0, 30.0]);
      var b = NdArray.array([2.0, 5.0, 10.0]);
      var expected = NdArray.array([5.0, 4.0, 3.0], dtype: Float64List);
      var result = a / b;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      expect(result.toList(), equals(expected.toList()));
    });

    test('1D Array Division (Int / Double)', () {
      // Already tests type promotion implicitly
      var a = NdArray.array([10, 20, 30]);
      var b = NdArray.array([2.0, 5.0, 10.0]);
      var expected = NdArray.array([5.0, 4.0, 3.0], dtype: Float64List);
      var result = a / b;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      expect(result.toList(), equals(expected.toList()));
    });

    test('2D Array Division', () {
      var a = NdArray.array([
        [10, 20],
        [30, 40]
      ]);
      var b = NdArray.array([
        [2, 5],
        [10, 8]
      ]);
      var expected = NdArray.array([
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

    test('Array Division with Views', () {
      var baseA = NdArray.arange(10, stop: 20);
      var baseB = NdArray.arange(1, stop: 11);
      var a = baseA[[Slice(0, 4)]];
      var b = baseB[[Slice(1, 5)]];
      var expected =
          NdArray.array([5.0, 11.0 / 3.0, 3.0, 13.0 / 5.0], dtype: Float64List);
      var result = a / b;
      expect(result.shape, equals(expected.shape));
      expect(result.dtype, equals(double));
      expect(result.data, isA<Float64List>());
      expect(result.toList()[0], closeTo(5.0, 1e-9));
      expect(result.toList()[1], closeTo(11.0 / 3.0, 1e-9));
      expect(result.toList()[2], closeTo(3.0, 1e-9));
      expect(result.toList()[3], closeTo(13.0 / 5.0, 1e-9));
    });

    test('Array Division by Zero', () {
      var a = NdArray.array([1.0, -2.0, 0.0, 5.0, 10]);
      var b = NdArray.array([0.0, 0.0, 0.0, 0.0, 0]);
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
        // Ensure original base array is unchanged
        expect(
            base.toList(),
            equals([
              [1, 4, 9],
              [16, 25, 36]
            ]));
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
        var view =
            base[[Slice(null, null), Slice(1, null)]]; // [[1, 2], [4, 5]]
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
  }); // End of Division group
}
