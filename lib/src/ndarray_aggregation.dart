import 'ndarray.dart'; // Import the main NdArray class

/// Extension methods for aggregation operations on NdArray.
extension NdArrayAggregation on NdArray {
  /// Calculates the sum of all elements in the array.
  ///
  /// Returns an `int` if the array's dtype is `int`, otherwise returns a `double`.
  /// Returns 0 or 0.0 for an empty array.
  ///
  /// Example:
  /// ```dart
  /// var a = NdArray.array([1, 2, 3]);
  /// print(a.sum()); // Output: 6
  ///
  /// var b = NdArray.array([1.5, 2.5, 3.5]);
  /// print(b.sum()); // Output: 7.5
  ///
  /// var c = NdArray.zeros([2, 0]); // Empty array
  /// print(c.sum()); // Output: 0
  /// ```
  num sum() {
    if (size == 0) {
      return (dtype == int) ? 0 : 0.0;
    }

    if (dtype == int) {
      int total = 0;
      for (final element in elements) {
        total += element as int; // Cast is safe due to dtype check
      }
      return total;
    } else {
      double total = 0.0;
      for (final element in elements) {
        total += element.toDouble(); // Ensure double addition
      }
      return total;
    }
  }

  /// Calculates the arithmetic mean of all elements in the array.
  ///
  /// Returns a `double` representing the mean.
  /// Returns `double.nan` if the array is empty.
  ///
  /// Example:
  /// ```dart
  /// var a = NdArray.array([1, 2, 3, 4]);
  /// print(a.mean()); // Output: 2.5
  ///
  /// var b = NdArray.array([[1.0, 2.0], [3.0, 4.0]]);
  /// print(b.mean()); // Output: 2.5
  ///
  /// var c = NdArray.zeros([0]);
  /// print(c.mean()); // Output: NaN
  /// ```
  double mean() {
    if (size == 0) {
      /// Finds the maximum element in the array.
      ///
      /// Returns the maximum value.
      /// Throws a [StateError] if the array is empty.
      ///
      /// Example:
      /// ```dart
      /// var a = NdArray.array([1, 5, 2, 4]);
      /// print(a.max()); // Output: 5
      ///
      /// var b = NdArray.array([[1.5, 2.5], [-1.0, 0.5]]);
      /// print(b.max()); // Output: 2.5
      /// ```
      num max() {
        if (size == 0) {
          throw StateError('Cannot find the maximum value of an empty array.');
        }

        num maxValue = elements.first;

        /// Finds the minimum element in the array.
        ///
        /// Returns the minimum value.
        /// Throws a [StateError] if the array is empty.
        ///
        /// Example:
        /// ```dart
        /// var a = NdArray.array([1, 5, 2, 4]);
        /// print(a.min()); // Output: 1
        ///
        /// var b = NdArray.array([[1.5, 2.5], [-1.0, 0.5]]);
        /// print(b.min()); // Output: -1.0
        /// ```
        num min() {
          if (size == 0) {
            throw StateError(
                'Cannot find the minimum value of an empty array.');
          }

          num minValue = elements.first;
          for (final element in elements.skip(1)) {
            if (element < minValue) {
              minValue = element;
            }
          }
          return minValue;
        }

        for (final element in elements.skip(1)) {
          if (element > maxValue) {
            maxValue = element;
          }
        }
        return maxValue;
      }

      return double.nan;
    }
    // sum() returns int or double, ensure division results in double
    return sum().toDouble() / size.toDouble();
  }

  // TODO: Implement mean, max, min
}
