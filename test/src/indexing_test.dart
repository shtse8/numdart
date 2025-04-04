import 'package:test/test.dart';
import 'dart:typed_data';
import 'package:numdart/numdart.dart'; // Import the main library
import 'package:collection/collection.dart'; // For deep equality checks

// Temporary minimal reshape for testing purposes ONLY.
extension ReshapeForTest on NdArray {
  NdArray reshape(List<int> newShape) {
    final newSize = newShape.isEmpty ? 1 : newShape.reduce((a, b) => a * b);
    if (newSize != size) {
      throw ArgumentError(
          'Cannot reshape array of size $size into shape $newShape');
    }
    final newStrides = _calculateStrides(newShape, data.elementSizeInBytes);
    return NdArray.internalCreateView(data, newShape, newStrides, dtype, size,
        newShape.length, offsetInBytes);
  }
}

// Need access to top-level helpers for the reshape extension
List<int> _calculateStrides(List<int> shape, int elementSizeInBytes) {
  if (shape.isEmpty) return [];
  final ndim = shape.length;
  final strides = List<int>.filled(ndim, 0);
  if (ndim == 1) {
    strides[0] = elementSizeInBytes;
    return strides;
  }
  strides[ndim - 1] = elementSizeInBytes;
  for (int i = ndim - 2; i >= 0; i--) {
    strides[i] = (shape[i + 1] == 0)
        ? elementSizeInBytes
        : strides[i + 1] * shape[i + 1];
  }
  return strides;
}

void main() {
  group('NdArray Basic Indexing (operator [])', () {
    test('1D array indexing', () {
      var a = NdArray.arange(5);
      expect(a[[0]], equals(0));
      expect(a[[2]], equals(2));
      expect(a[[4]], equals(4));
      expect(a[[-1]], equals(4));
      expect(a[[-3]], equals(2));
    });

    test('2D array indexing', () {
      var a = NdArray.array([
        [1, 2, 3],
        [4, 5, 6]
      ]);
      expect(a[[0, 0]], equals(1));
      expect(a[[0, 2]], equals(3));
      expect(a[[1, 1]], equals(5));
      expect(a[[-1, -1]], equals(6));
      expect(a[[0, -1]], equals(3));
      expect(a[[-1, 0]], equals(4));
    });

    test('3D array indexing', () {
      var a = NdArray.array([
        [
          [0, 1],
          [2, 3]
        ],
        [
          [4, 5],
          [6, 7]
        ]
      ]);
      expect(a.shape, equals([2, 2, 2]));
      expect(a[[0, 0, 0]], equals(0));
      expect(a[[0, 0, 1]], equals(1));
      expect(a[[0, 1, 0]], equals(2));
      expect(a[[0, 1, 1]], equals(3));
      expect(a[[1, 0, 0]], equals(4));
      expect(a[[1, 0, 1]], equals(5));
      expect(a[[1, 1, 0]], equals(6));
      expect(a[[1, 1, 1]], equals(7));
      expect(a[[-1, -1, -1]], equals(7));
      expect(a[[0, -1, 0]], equals(2));
      expect(a[[-1, 0, -1]], equals(5));
    });

    test('Index out of bounds', () {
      var a = NdArray.arange(5);
      expect(() => a[[5]], throwsRangeError);
      expect(() => a[[-6]], throwsRangeError);
      var b = NdArray.array([
        [1, 2],
        [3, 4]
      ]);
      expect(() => b[[2, 0]], throwsRangeError);
      expect(() => b[[0, 2]], throwsRangeError);
      expect(() => b[[-3, 0]], throwsRangeError);
      expect(() => b[[0, -3]], throwsRangeError);
    });

    test('Incorrect number of indices', () {
      var a = NdArray.arange(5);
      expect(() => a[[]], throwsRangeError);
      expect(() => a[[1, 2]], throwsRangeError);
      var b = NdArray.array([
        [1, 2],
        [3, 4]
      ]);
      expect(() => b[[0]], throwsRangeError);
      expect(() => b[[0, 0, 0]], throwsRangeError);
    });
  }); // End of Basic Indexing group

  group('NdArray Slicing (operator [] returning view)', () {
    test('1D slicing - basic', () {
      var a = NdArray.arange(10);
      var s = a[[Slice(2, 7)]];
      expect(s, isA<NdArray>());
      expect(s.shape, equals([5]));
      expect(s.ndim, equals(1));
      expect(s.size, equals(5));
      expect(s[[0]], equals(2));
      expect(s[[4]], equals(6));
      expect(s[[-1]], equals(6));
      expect(identical(s.data, a.data), isTrue);
      expect(s.offsetInBytes,
          equals(a.offsetInBytes + 2 * a.data.elementSizeInBytes));
      expect(s.strides, equals(a.strides));
    });

    test('1D slicing - with step', () {
      var a = NdArray.arange(10);
      var s = a[[Slice(1, 8, 2)]];
      expect(s.shape, equals([4]));
      expect(s.ndim, equals(1));
      expect(s.size, equals(4));
      expect(s[[0]], equals(1));
      expect(s[[1]], equals(3));
      expect(s[[3]], equals(7));
      expect(s[[-1]], equals(7));
      expect(identical(s.data, a.data), isTrue);
      expect(s.offsetInBytes,
          equals(a.offsetInBytes + 1 * a.data.elementSizeInBytes));
      expect(s.strides, equals([a.strides[0] * 2]));
    });

    test('1D slicing - negative step', () {
      var a = NdArray.arange(5);
      var s = a[[Slice(null, null, -1)]];
      expect(s.shape, equals([5]));
      expect(s.ndim, equals(1));
      expect(s[[0]], equals(4));
      expect(s[[4]], equals(0));
      expect(identical(s.data, a.data), isTrue);
      expect(s.offsetInBytes,
          equals(a.offsetInBytes + 4 * a.data.elementSizeInBytes));
      expect(s.strides, equals([a.strides[0] * -1]));
    });

    test('1D slicing - Slice.all', () {
      var a = NdArray.arange(5);
      var s = a[[Slice.all]];
      expect(s.shape, equals(a.shape));
      expect(s.ndim, equals(a.ndim));
      expect(s.size, equals(a.size));
      expect(s[[0]], equals(a[[0]]));
      expect(s[[-1]], equals(a[[-1]]));
      expect(identical(s.data, a.data), isTrue);
      expect(s.offsetInBytes, equals(a.offsetInBytes));
      expect(s.strides, equals(a.strides));
    });

    test('2D slicing - row slice', () {
      var a = NdArray.arange(6).reshape([2, 3]);
      var row1 = a[[1, Slice.all]];
      expect(row1.shape, equals([3]));
      expect(row1.ndim, equals(1));
      expect(row1.size, equals(3));
      expect(row1[[0]], equals(3));
      expect(row1[[2]], equals(5));
      expect(identical(row1.data, a.data), isTrue);
      expect(row1.offsetInBytes, equals(a.offsetInBytes + 1 * a.strides[0]));
      expect(row1.strides, equals([a.strides[1]]));
    });

    test('2D slicing - column slice', () {
      var a = NdArray.arange(6).reshape([2, 3]);
      var col1 = a[[Slice.all, 1]];
      expect(col1.shape, equals([2]));
      expect(col1.ndim, equals(1));
      expect(col1.size, equals(2));
      expect(col1[[0]], equals(1));
      expect(col1[[1]], equals(4));
      expect(identical(col1.data, a.data), isTrue);
      expect(col1.offsetInBytes, equals(a.offsetInBytes + 1 * a.strides[1]));
      expect(col1.strides, equals([a.strides[0]]));
    });

    test('2D slicing - sub-matrix view', () {
      var a = NdArray.arange(12).reshape([3, 4]);
      var sub = a[[Slice(1, 3), Slice(0, 2)]];
      expect(sub.shape, equals([2, 2]));
      expect(sub.ndim, equals(2));
      expect(sub.size, equals(4));
      expect(sub[[0, 0]], equals(4));
      expect(sub[[0, 1]], equals(5));
      expect(sub[[1, 0]], equals(8));
      expect(sub[[1, 1]], equals(9));
      expect(identical(sub.data, a.data), isTrue);
      expect(sub.offsetInBytes,
          equals(a.offsetInBytes + 1 * a.strides[0] + 0 * a.strides[1]));
      expect(sub.strides, equals(a.strides));
    });

    test('2D slicing - with steps', () {
      var a = NdArray.arange(12).reshape([3, 4]);
      var sub = a[[Slice(0, 3, 2), Slice(0, 4, 2)]];
      expect(sub.shape, equals([2, 2]));
      expect(sub.ndim, equals(2));
      expect(sub.size, equals(4));
      expect(sub[[0, 0]], equals(0));
      expect(sub[[0, 1]], equals(2));
      expect(sub[[1, 0]], equals(8));
      expect(sub[[1, 1]], equals(10));
      expect(identical(sub.data, a.data), isTrue);
      expect(sub.offsetInBytes,
          equals(a.offsetInBytes + 0 * a.strides[0] + 0 * a.strides[1]));
      expect(sub.strides, equals([a.strides[0] * 2, a.strides[1] * 2]));
    });

    test('Slicing results in empty array', () {
      var a = NdArray.arange(10);
      var s = a[[Slice(5, 5)]];
      expect(s.shape, equals([0]));
      expect(s.size, equals(0));
      var b = NdArray.arange(12).reshape([3, 4]);
      var s2 = b[[Slice(1, 1), Slice.all]];
      expect(s2.shape, equals([0, 4]));
      expect(s2.size, equals(0));
      var s3 = b[[Slice.all, Slice(2, 1)]];
      expect(s3.shape, equals([3, 0]));
      expect(s3.size, equals(0));
    });
  }); // End of Slicing group

  group('NdArray Basic Assignment (operator []=)', () {
    test('1D array assignment', () {
      var a = NdArray.zeros([5]);
      a[[0]] = 10;
      a[[2]] = -5;
      a[[-1]] = 99; // Assign last element
      expect(a[[0]], equals(10));
      expect(a[[1]], equals(0)); // Should remain zero
      expect(a[[2]], equals(-5));
      expect(a[[4]], equals(99));
    });

    test('2D array assignment', () {
      var a = NdArray.ones([2, 3], dtype: Int32List); // [[1, 1, 1], [1, 1, 1]]
      a[[0, 0]] = 0;
      a[[1, 2]] = 7;
      a[[-1, -1]] = 8; // Assign bottom-right (should overwrite 7)
      a[[0, -2]] = 5; // Assign middle element of first row
      expect(a[[0, 0]], equals(0));
      expect(a[[0, 1]], equals(5));
      expect(a[[0, 2]], equals(1)); // Should remain one
      expect(a[[1, 0]], equals(1)); // Should remain one
      expect(a[[1, 1]], equals(1)); // Should remain one
      expect(a[[1, 2]],
          equals(8)); // Check the final value after negative index assignment
    });

    test('Assignment with type conversion (double to int)', () {
      var a = NdArray.zeros([3], dtype: Int64List);
      a[[1]] = 123.7;
      expect(a[[1]], equals(123)); // Should truncate
    });

    test('Assignment with type conversion (int to double)', () {
      var a = NdArray.zeros([3], dtype: Float32List);
      a[[1]] = 123;
      expect(a[[1]], equals(123.0)); // Should convert
    });

    test('Assignment out of bounds throws error', () {
      var a = NdArray.zeros([4]);
      expect(() => a[[4]] = 1, throwsRangeError);
      expect(() => a[[-5]] = 1, throwsRangeError);
      var b = NdArray.zeros([2, 2]);
      expect(() => b[[2, 0]] = 1, throwsRangeError);
      expect(() => b[[0, -3]] = 1, throwsRangeError);
    });

    test('Assignment with incorrect number of indices throws error', () {
      var a = NdArray.zeros([4]);
      expect(() => a[[]] = 1, throwsRangeError);
      expect(() => a[[1, 1]] = 1, throwsRangeError);
    });

    test('Assignment with non-numeric value throws error', () {
      var a = NdArray.zeros([4]);
      expect(() => a[[0]] = 'hello', throwsArgumentError);
      expect(() => a[[0]] = true, throwsArgumentError);
      expect(() => a[[0]] = null, throwsArgumentError);
    });
  }); // End of Basic Assignment group

  group('NdArray Slice Assignment (operator []= with scalar)', () {
    test('1D slice assignment with scalar', () {
      var a = NdArray.zeros([10]);
      a[[Slice(2, 7)]] = 5.0;
      expect(a[[0]], equals(0));
      expect(a[[1]], equals(0));
      expect(a[[2]], equals(5));
      expect(a[[3]], equals(5));
      expect(a[[4]], equals(5));
      expect(a[[5]], equals(5));
      expect(a[[6]], equals(5));
      expect(a[[7]], equals(0));
      expect(a[[8]], equals(0));
      expect(a[[9]], equals(0));

      a[[Slice(null, 3)]] = -1;
      expect(a[[0]], equals(-1));
      expect(a[[1]], equals(-1));
      expect(a[[2]], equals(-1));
      expect(a[[3]], equals(5)); // Should remain 5

      a[[Slice(8, null)]] = 99;
      expect(a[[7]], equals(0));
      expect(a[[8]], equals(99));
      expect(a[[9]], equals(99));
    });

    test('1D slice assignment with step', () {
      var a = NdArray.arange(10);
      a[[Slice(1, 8, 2)]] = 100;
      expect(a[[0]], equals(0));
      expect(a[[1]], equals(100));
      expect(a[[2]], equals(2));
      expect(a[[3]], equals(100));
      expect(a[[4]], equals(4));
      expect(a[[5]], equals(100));
      expect(a[[6]], equals(6));
      expect(a[[7]], equals(100));
      expect(a[[8]], equals(8));
      expect(a[[9]], equals(9));
    });

    test('1D slice assignment with negative step', () {
      var a = NdArray.arange(5);
      a[[Slice(null, null, -1)]] = 7;
      expect(a[[0]], equals(7));
      expect(a[[1]], equals(7));
      expect(a[[2]], equals(7));
      expect(a[[3]], equals(7));
      expect(a[[4]], equals(7));

      var b = NdArray.arange(6);
      b[[Slice(4, 1, -2)]] = -5; // Indices 4, 2
      expect(b[[0]], equals(0));
      expect(b[[1]], equals(1));
      expect(b[[2]], equals(-5));
      expect(b[[3]], equals(3));
      expect(b[[4]], equals(-5));
      expect(b[[5]], equals(5));
    });

    test('2D slice assignment - row', () {
      var a = NdArray.zeros([3, 4]);
      a[[1, Slice.all]] = 10;
      expect(a[[0, 0]], equals(0));
      expect(a[[1, 0]], equals(10));
      expect(a[[1, 1]], equals(10));
      expect(a[[1, 2]], equals(10));
      expect(a[[1, 3]], equals(10));
      expect(a[[2, 0]], equals(0));
    });

    test('2D slice assignment - column', () {
      var a = NdArray.zeros([3, 4]);
      a[[Slice.all, 2]] = 20;
      expect(a[[0, 1]], equals(0));
      expect(a[[0, 2]], equals(20));
      expect(a[[1, 2]], equals(20));
      expect(a[[2, 2]], equals(20));
      expect(a[[0, 3]], equals(0));
    });

    test('2D slice assignment - submatrix', () {
      var a = NdArray.ones([4, 4]);
      a[[Slice(1, 3), Slice(1, 3)]] = 30; // Assign to the 2x2 center
      expect(a[[0, 0]], equals(1));
      expect(a[[0, 1]], equals(1));
      expect(a[[1, 0]], equals(1));
      expect(a[[1, 1]], equals(30));
      expect(a[[1, 2]], equals(30));
      expect(a[[2, 1]], equals(30));
      expect(a[[2, 2]], equals(30));
      expect(a[[3, 3]], equals(1));
      expect(a[[0, 3]], equals(1));
      expect(a[[3, 0]], equals(1));
    });

    test('Slice assignment with type conversion', () {
      var a = NdArray.zeros([5], dtype: Int32List);
      a[[Slice(1, 4)]] = 12.7;
      expect(a[[0]], equals(0));
      expect(a[[1]], equals(12));
      expect(a[[2]], equals(12));
      expect(a[[3]], equals(12));
      expect(a[[4]], equals(0));
    });

    test('Slice assignment to empty slice does nothing', () {
      var a = NdArray.arange(5);
      var originalData = List.from(a.data.buffer.asInt64List());
      a[[Slice(2, 2)]] = 99;
      expect(a.data.buffer.asInt64List(), equals(originalData));
      a[[Slice(4, 1)]] = 99;
      expect(a.data.buffer.asInt64List(), equals(originalData));
    });

    test('Slice assignment with invalid value throws error', () {
      var a = NdArray.zeros([5]);
      expect(() => a[[Slice(0, 2)]] = 'hello', throwsArgumentError);
      expect(() => a[[Slice(0, 2)]] = true, throwsArgumentError);
      expect(() => a[[Slice(0, 2)]] = null, throwsArgumentError);
      // Test assigning NdArray (should now throw shape/dtype error if incompatible, or work if compatible)
      // expect(() => a[[Slice(0, 2)]] = NdArray.zeros([3]), throwsArgumentError); // Shape mismatch
      // expect(() => a[[Slice(0, 2)]] = NdArray.zeros([2], dtype: Float64List), throwsArgumentError); // Dtype mismatch
    });
  }); // End of Slice Assignment group

  group('NdArray Slice Assignment (operator []= with NdArray)', () {
    test('Assign 1D array to 1D slice (same shape)', () {
      var a = NdArray.zeros([10]);
      var b = NdArray.array([1.0, 2.0, 3.0, 4.0, 5.0], dtype: Float64List);
      a[[Slice(2, 7)]] = b;
      expect(a.toList(), equals([0, 0, 1, 2, 3, 4, 5, 0, 0, 0]));
    });

    test('Assign 1D array to 1D slice with step', () {
      var a = NdArray.zeros([10]);
      var b = NdArray.array([10.0, 20.0, 30.0, 40.0],
          dtype: Float64List); // Needs 4 elements
      a[[Slice(1, 8, 2)]] = b; // Assign to indices 1, 3, 5, 7
      expect(a.toList(), equals([0, 10, 0, 20, 0, 30, 0, 40, 0, 0]));
    });

    test('Assign 1D array to 2D slice (row broadcasting)', () {
      var a = NdArray.zeros([3, 4]);
      var b =
          NdArray.array([1.0, 2.0, 3.0, 4.0], dtype: Float64List); // Shape [4]
      a[[1, Slice.all]] = b; // Assign b to the second row
      expect(
          a.toList(),
          equals([
            [0, 0, 0, 0],
            [1, 2, 3, 4],
            [0, 0, 0, 0]
          ]));

      a[[Slice(0, 2), Slice.all]] = b; // Assign b broadcasted to first two rows
      expect(
          a.toList(),
          equals([
            [1, 2, 3, 4],
            [1, 2, 3, 4],
            [0, 0, 0, 0]
          ]));
    });

    test('Assign 1D array (column) to 2D slice (column broadcasting)', () {
      var a = NdArray.zeros([3, 4]);
      // First assignment: Assign a [3] shape array to the [3] shape slice
      var b1 =
          NdArray.array([10.0, 20.0, 30.0], dtype: Float64List); // Shape [3]
      a[[Slice.all, 1]] =
          b1; // Assign b1 to the second column. Target slice shape is [3]
      expect(
          a.toList(),
          equals([
            [0, 10, 0, 0],
            [0, 20, 0, 0],
            [0, 30, 0, 0]
          ]));

      // Second assignment: Assign a [3, 1] shape array to the [3, 2] shape slice (broadcasting)
      var b2 = NdArray.array([100.0, 200.0, 300.0], dtype: Float64List)
          .reshape([3, 1]); // Shape [3, 1]
      a[[Slice.all, Slice(2, 4)]] =
          b2; // Assign b2 broadcasted to last two columns [:, 2:] Target slice shape is [3, 2]
      expect(
          a.toList(),
          equals([
            // Column 1 remains from b1, Columns 2 & 3 get b2 broadcasted
            [0, 10, 100, 100],
            [0, 20, 200, 200],
            [0, 30, 300, 300]
          ]));
    });

    test('Assign 2D array to 2D slice (same shape)', () {
      var a = NdArray.zeros([4, 4]);
      var b = NdArray.array([
        [1.0, 2.0],
        [3.0, 4.0]
      ], dtype: Float64List); // Shape [2, 2]
      a[[Slice(1, 3), Slice(1, 3)]] = b; // Assign to the center 2x2
      expect(
          a.toList(),
          equals([
            [0, 0, 0, 0],
            [0, 1, 2, 0],
            [0, 3, 4, 0],
            [0, 0, 0, 0]
          ]));
    });

    test('Assign 2D array to 2D slice (broadcasting)', () {
      var a = NdArray.zeros([4, 4]);
      var b = NdArray.array([
        [10.0, 20.0]
      ], dtype: Float64List); // Shape [1, 2]
      a[[Slice(1, 3), Slice(1, 3)]] = b; // Assign b broadcasted to center 2x2
      expect(
          a.toList(),
          equals([
            [0, 0, 0, 0],
            [0, 10, 20, 0], // Row 1 broadcasted
            [0, 10, 20, 0], // Row 2 broadcasted
            [0, 0, 0, 0]
          ]));
    });

    test('Assign array to a view', () {
      var base = NdArray.zeros([5, 5]);
      var view = base[[Slice(1, 4), Slice(1, 4)]]; // Center 3x3 view
      var b = NdArray.ones([3, 1],
          dtype: Float64List); // Column vector [1.0], [1.0], [1.0]
      view[[Slice.all, Slice.all]] =
          b; // Assign b broadcasted to the whole view

      expect(
          base.toList(),
          equals([
            // Check the original array
            [0, 0, 0, 0, 0],
            [0, 1, 1, 1, 0],
            [0, 1, 1, 1, 0],
            [0, 1, 1, 1, 0],
            [0, 0, 0, 0, 0]
          ]));
    });

    test('Assign empty array to slice', () {
      var a = NdArray.ones([5]);
      var b = NdArray.zeros([0]);
      a[[Slice(1, 1)]] = b; // Assign empty to empty slice
      expect(a.toList(), equals([1, 1, 1, 1, 1])); // Should be unchanged

      var c = NdArray.ones([2, 3]);
      var d = NdArray.zeros([2, 0]);
      c[[Slice.all, Slice(1, 1)]] =
          d; // Assign empty [2,0] to empty slice [2,0]
      expect(
          c.toList(),
          equals([
            [1, 1, 1],
            [1, 1, 1]
          ])); // Should be unchanged
    });

    test('Throws ArgumentError for incompatible broadcast shapes', () {
      var a = NdArray.zeros([4, 4]);
      var b = NdArray.ones([2, 3]); // Incompatible shape
      expect(() => a[[Slice(1, 3), Slice(1, 3)]] = b, throwsArgumentError);

      var c = NdArray.zeros([5]);
      var d = NdArray.ones([4]); // Incompatible shape
      expect(() => c[[Slice(0, 3)]] = d, throwsArgumentError);
    });

    test('Throws ArgumentError for different dtypes (currently)', () {
      var a = NdArray.zeros([4], dtype: Int64List);
      var b = NdArray.ones([2], dtype: Float64List);
      expect(() => a[[Slice(1, 3)]] = b, throwsArgumentError);
    });
  }); // End of NdArray Slice Assignment group
} // End of main
