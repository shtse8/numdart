import 'package:test/test.dart';
import 'package:numdart/numdart.dart';
import 'dart:typed_data';

void main() {
  group('NdArray reshape tests', () {
    test('Reshape 1D to 2D', () {
      var a = arange(6); // [0, 1, 2, 3, 4, 5]
      var b = a.reshape([2, 3]);

      expect(b.shape, equals([2, 3]));
      expect(b.ndim, equals(2));
      expect(b.size, equals(6));
      expect(identical(b.data, a.data), isTrue); // Should be a view
      expect(
          b.offsetInBytes, equals(a.offsetInBytes)); // Offset shouldn't change
      // Check strides: For shape [2, 3] and Int64List (8 bytes) -> [3*8, 8] = [24, 8]
      expect(b.strides, equals([24, 8]));
      // Check elements via new shape
      expect(b[[0, 0]], equals(0));
      expect(b[[0, 2]], equals(2));
      expect(b[[1, 0]], equals(3));
      expect(b[[1, 2]], equals(5));
    });

    test('Reshape 2D to 1D', () {
      var a = array([
        [0, 1, 2],
        [3, 4, 5]
      ]);
      var b = a.reshape([6]);

      expect(b.shape, equals([6]));
      expect(b.ndim, equals(1));
      expect(b.size, equals(6));
      expect(identical(b.data, a.data), isTrue);
      expect(b.offsetInBytes, equals(a.offsetInBytes));
      // Check strides: For shape [6] and Int64List -> [8]
      expect(b.strides, equals([8]));
      // Check elements
      expect(b[[0]], equals(0));
      expect(b[[5]], equals(5));
    });

    test('Reshape with -1 dimension inference', () {
      var a = arange(12); // Size 12
      var b = a.reshape([3, -1]); // Infer as [3, 4]
      expect(b.shape, equals([3, 4]));
      expect(b.ndim, equals(2));
      expect(b[[0, 3]], equals(3));
      expect(b[[2, 3]], equals(11));

      var c = a.reshape([-1, 6]); // Infer as [2, 6]
      expect(c.shape, equals([2, 6]));
      expect(c.ndim, equals(2));
      expect(c[[0, 5]], equals(5));
      expect(c[[1, 5]], equals(11));

      var d = a.reshape([2, -1, 3]); // Infer as [2, 2, 3]
      expect(d.shape, equals([2, 2, 3]));
      expect(d.ndim, equals(3));
      expect(d[[0, 0, 0]], equals(0));
      expect(d[[1, 1, 2]], equals(11));
    });

    test('Reshape scalar (size 1)', () {
      var a = array([5]); // Shape [1]
      var b = a.reshape([]); // Reshape to scalar shape []
      expect(b.shape, equals([]));
      expect(b.ndim, equals(0));
      expect(b.size, equals(1));
      // Accessing scalar requires special handling or a dedicated method,
      // operator [] expects List<int>. We can check the first element of data.
      expect((b.data as Int64List)[0], equals(5));

      var c = zeros([]); // Create scalar directly
      var d = c.reshape([1]); // Reshape scalar to [1]
      expect(d.shape, equals([1]));
      expect(d.ndim, equals(1));
      expect(d.size, equals(1));
      expect(d[[0]], equals(0));
    });

    test('Reshape empty array (size 0)', () {
      var a = array([]); // Shape [0]
      var b = a.reshape([0, 5]);
      expect(b.shape, equals([0, 5]));
      expect(b.ndim, equals(2));
      expect(b.size, equals(0));

      var c = zeros([5, 0]);
      var d = c.reshape([0]);
      expect(d.shape, equals([0]));
      expect(d.ndim, equals(1));
      expect(d.size, equals(0));

      var e = c.reshape([-1]); // Infer shape [0]
      expect(e.shape, equals([0]));
      expect(e.ndim, equals(1));
      expect(e.size, equals(0));
    });

    test('Reshape incompatible size throws error', () {
      var a = arange(6);
      expect(() => a.reshape([2, 2]), throwsArgumentError); // Size 4 != 6
      expect(() => a.reshape([7]), throwsArgumentError); // Size 7 != 6
    });

    test('Reshape with multiple -1 throws error', () {
      var a = arange(12);
      expect(() => a.reshape([-1, -1]), throwsArgumentError);
    });

    test('Reshape with invalid dimension size throws error', () {
      var a = arange(12);
      expect(() => a.reshape([3, 0]), throwsArgumentError); // Size becomes 0
      expect(() => a.reshape([3, -2]),
          throwsArgumentError); // Invalid negative dim
    });

    test('Reshape view modifies original', () {
      var a = arange(4); // [0, 1, 2, 3]
      var b = a.reshape([2, 2]); // [[0, 1], [2, 3]]
      b[[0, 1]] = 99; // Modify view
      expect(a[[1]], equals(99)); // Original should be modified
    });
  });
}
