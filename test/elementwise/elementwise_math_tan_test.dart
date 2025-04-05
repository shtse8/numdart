// <!-- Version: 1.0 | Last Updated: 2025-04-05 | Updated By: Cline -->

// Imports moved to elementwise_math_test.dart
part of 'elementwise_math_test.dart'; // Add part of directive

void _testTanGroup() {
  // Wrap in a function
  group('NdArray tan', () {
    test('simple tan calculation', () {
      var a = NdArray.array([0, math.pi / 4, math.pi]);
      var expected = NdArray.array([
        math.tan(0),
        math.tan(math.pi / 4),
        math.tan(math.pi)
      ]); // Result dtype should be double
      var result = a.tan();

      expect(
          result.dtype, equals(double)); // Compare with primitive type double
      expect(result.shape, equals(expected.shape));
      // Use closeTo for floating point comparisons and correct indexing
      for (int i = 0; i < result.size; i++) {
        expect(result[[i]], closeTo(expected[[i]], 1e-10));
      }
    });

    test('tan of integers', () {
      var a = NdArray.array([0, 1]); // Integers
      var expected = NdArray.array([math.tan(0), math.tan(1)]);
      var result = a.tan();

      expect(result.dtype, equals(double)); // Result always double
      expect(result.shape, equals(expected.shape));
      expect(result[[0]], closeTo(expected[[0]], 1e-10));
      expect(result[[1]], closeTo(expected[[1]], 1e-10));
    });

    test('tan of doubles', () {
      var a = NdArray.array([0.0, math.pi / 3, -math.pi / 4]); // Doubles
      var expected = NdArray.array(
          [math.tan(0.0), math.tan(math.pi / 3), math.tan(-math.pi / 4)]);
      var result = a.tan();

      expect(result.dtype, equals(double));
      expect(result.shape, equals(expected.shape));
      expect(result[[0]], closeTo(expected[[0]], 1e-10));
      expect(result[[1]], closeTo(expected[[1]], 1e-10));
      expect(result[[2]], closeTo(expected[[2]], 1e-10));
    });

    test('tan of multi-dimensional array', () {
      var a = NdArray.array([
        [0, math.pi / 4],
        [math.pi, -math.pi / 4]
      ]);
      var expected = NdArray.array([
        [math.tan(0), math.tan(math.pi / 4)],
        [math.tan(math.pi), math.tan(-math.pi / 4)]
      ]);
      var result = a.tan();

      expect(result.dtype, equals(double));
      expect(result.shape, equals(expected.shape));
      expect(result[[0, 0]], closeTo(expected[[0, 0]], 1e-10));
      expect(result[[0, 1]], closeTo(expected[[0, 1]], 1e-10));
      expect(result[[1, 0]], closeTo(expected[[1, 0]], 1e-10));
      expect(result[[1, 1]], closeTo(expected[[1, 1]], 1e-10));
    });

    test('tan of empty array', () {
      var a = NdArray.array([]);
      var result = a.tan();
      expect(result.dtype, equals(double)); // Should still be double
      expect(result.shape, equals([0]));
      expect(result.size == 0, isTrue); // Use size check

      var b = NdArray.zeros([2, 0]); // Empty array with shape
      var resultB = b.tan();
      expect(resultB.dtype, equals(double));
      expect(resultB.shape, equals([2, 0]));
      expect(resultB.size == 0, isTrue); // Use size check
    });

    // Add more tests for edge cases if necessary (e.g., values close to pi/2)
    test('tan near pi/2 (expect large values or infinity)', () {
      // Note: tan(pi/2) is mathematically undefined (infinity).
      // Dart's math.tan might return a very large number or double.infinity.
      var a = NdArray.array([math.pi / 2, -math.pi / 2]);
      var result = a.tan();

      expect(result.dtype, equals(double));
      // Check if the results are infinite or very large, depending on precision
      // Corrected element access using [[index]] and cast to double
      expect(
          (result[[0]] as double).isInfinite ||
              (result[[0]] as double).abs() > 1e15,
          isTrue);
      expect(
          (result[[1]] as double).isInfinite ||
              (result[[1]] as double).abs() > 1e15,
          isTrue);
    });
  });
}
