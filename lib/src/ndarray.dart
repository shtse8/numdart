library ndarray; // Define a library name

import 'dart:typed_data';
import 'dart:math' as math; // For max, sqrt, trig functions etc.
import 'package:meta/meta.dart';
import 'package:collection/collection.dart'; // Needed for ListEquality
import 'slice.dart'; // Import Slice

part 'ndarray_helpers.dart';
part 'ndarray_creation.dart';
part 'ndarray_indexing.dart';
part 'ndarray_math_ops.dart';
part 'ndarray_math_funcs.dart';
part 'ndarray_manipulation.dart';

/// Represents a multi-dimensional, fixed-size array of items of the same type.
class NdArray {
  @internal
  final TypedData data;
  final List<int> shape;
  final List<int> strides;
  final Type dtype; // Represents the element type (int or double)
  final int size;
  final int ndim;
  @internal
  final int offsetInBytes;

  /// Internal constructor - Use factory methods or internalCreateView.
  NdArray._(this.data, this.shape, this.strides, this.dtype, this.size,
      this.ndim, this.offsetInBytes);

  /// Internal factory method to create a view.
  /// This might be refactored or removed if public factories cover all needs.
  @internal
  static NdArray internalCreateView(TypedData data, List<int> shape,
      List<int> strides, Type dtype, int size, int ndim, int offsetInBytes) {
    return NdArray._(data, shape, strides, dtype, size, ndim, offsetInBytes);
  }

  // --- Basic Properties ---
  int get dimensions => ndim;

  // --- Factory Constructors ---
  // Defined in ndarray_creation.dart via top-level functions like array(), zeros() etc.
  // Example: static NdArray array(List list, {Type? dtype}) => array(list, dtype: dtype);
  // We need static methods in the class to delegate to the part functions
  static NdArray array(List list, {Type? dtype}) => array(list, dtype: dtype);
  static NdArray zeros(List<int> shape, {Type dtype = Float64List}) =>
      zeros(shape, dtype: dtype);
  static NdArray ones(List<int> shape, {Type dtype = Float64List}) =>
      ones(shape, dtype: dtype);
  static NdArray arange(num startOrStop,
          {num? stop, num step = 1, Type? dtype}) =>
      arange(startOrStop, stop: stop, step: step, dtype: dtype);
  static NdArray linspace(num start, num stop,
          {int num = 50, bool endpoint = true, Type dtype = Float64List}) =>
      linspace(start, stop, num: num, endpoint: endpoint, dtype: dtype);

  // --- Indexing and Slicing ---
  // Defined in ndarray_indexing.dart via operator methods
  /// Accesses an element or creates a view based on the provided indices/slices.
  ///
  /// If all elements in [indices] are integers, it returns the single element
  /// Returns a new view of the array with a different shape, without changing data.
  ///
  /// The new shape must be compatible with the original shape (i.e., the total
  /// number of elements must remain the same).
  /// One dimension can be specified as -1. In this case, the value is inferred
  /// from the length of the array and the remaining dimensions.
  ///
  /// Example:
  /// ```dart
  /// var a = NdArray.arange(6);
  /// var b = a.reshape([2, 3]);
  /// print(b.shape); // Output: [2, 3]
  ///
  /// var c = a.reshape([3, -1]); // Infer last dimension
  /// print(c.shape); // Output: [3, 2]
  /// ```
  ///
  /// Throws [ArgumentError] if the new shape is incompatible or invalid.
  NdArray reshape(List<int> newShape) {
    List<int> resolvedShape = List.from(newShape);
    int unknownDimIndex = resolvedShape.indexOf(-1);

    if (unknownDimIndex != -1) {
      if (resolvedShape.where((d) => d == -1).length > 1) {
        throw ArgumentError('Can only specify one unknown dimension (-1)');
      }
      int productOfKnownDims = 1;
      for (int dim in resolvedShape) {
        if (dim > 0) {
          productOfKnownDims *= dim;
        } else if (dim == 0 || dim < -1) {
          throw ArgumentError('Invalid dimension size in new shape: $dim');
        }
      }
      if (size == 0 && // Corrected from &amp;&amp;
          productOfKnownDims == 1 && // Corrected from &amp;&amp;
          resolvedShape.length == 1 && // Corrected from &amp;&amp;
          resolvedShape[0] == -1) {
        resolvedShape[unknownDimIndex] = 0;
      } else if (productOfKnownDims == 0) {
        if (size == 0) {
          int tempProduct = 1;
          resolvedShape.forEach((d) {
            if (d > 0) tempProduct *= d;
          });
          // Allow reshaping [0] to [0, x] or [x, 0] etc.
          // Check if the known dimensions multiply to zero, which is only possible if at least one known dim is 0.
          // If the original size is 0, this reshape is valid.
          if (tempProduct == 0) {
            resolvedShape[unknownDimIndex] =
                0; // Or any value, as total size remains 0
          } else if (size % tempProduct != 0) {
            // Should not happen if tempProduct is 0
            throw ArgumentError(
                'Cannot reshape array of size $size into shape $newShape (product is zero)');
          } else {
            resolvedShape[unknownDimIndex] =
                0; // If size is 0 and product is non-zero (e.g. reshape([0], [-1, 5]))
          }
        } else {
          // size != 0
          throw ArgumentError(
              'Cannot reshape array of size $size into shape $newShape (product is zero)');
        }
      } else if (size % productOfKnownDims != 0) {
        throw ArgumentError(
            'Cannot reshape array of size $size into shape $newShape');
      } else {
        resolvedShape[unknownDimIndex] = size ~/ productOfKnownDims;
      }
    }

    final int newSize = calculateSize(resolvedShape); // Use public version
    if (newSize != size) {
      throw ArgumentError(
          'Cannot reshape array of size $size into shape $resolvedShape (calculated size $newSize)');
    }
    if (resolvedShape.any((dim) => dim < 0)) {
      throw ArgumentError(
          'Negative dimensions are not allowed in the final shape: $resolvedShape');
    }

    // TODO: Check for contiguity before allowing view-based reshape.
    // If not contiguous, a copy might be needed. For now, assume view is possible.
    final List<int> newStrides = calculateStrides(
        resolvedShape, data.elementSizeInBytes); // Use public version

    // Note: NdArray._ is the internal constructor
    return NdArray._(data, resolvedShape, newStrides, dtype, size,
        resolvedShape.length, offsetInBytes);
  }

  /// Converts the NdArray to a nested [List].
  ///
  /// The structure of the nested list mirrors the shape of the NdArray.
  /// For a 0-dimensional array (scalar), it returns a list containing the single element.
  /// For an empty array (size 0), it returns an empty list or nested empty lists
  /// matching the shape.
  ///
  /// Example:
  /// ```dart
  /// var a = NdArray.array([[1, 2], [3, 4]]);
  /// print(a.toList()); // Output: [[1, 2], [3, 4]]
  ///
  /// var b = NdArray.array(5); // Scalar
  /// print(b.toList()); // Output: [5]
  ///
  /// var c = NdArray.zeros([2, 0]);
  /// print(c.toList()); // Output: [[], []]
  /// ```
  List<dynamic> toList() {
    if (size == 0) {
      // Handle empty arrays correctly based on dimensions
      if (ndim == 0)
        return []; // Should not happen for size 0? NumPy returns scalar item
      if (ndim == 1) return [];
      // For ndim > 1, create nested empty lists matching shape
      dynamic buildEmptyNested(int dim) {
        if (dim == ndim - 1) {
          return List.filled(shape[dim], null,
              growable: false); // Will be size 0 if shape[dim] is 0
        }
        List<dynamic> nested = List.filled(shape[dim], null, growable: false);
        for (int i = 0; i < shape[dim]; ++i) {
          nested[i] = buildEmptyNested(dim + 1);
        }
        return nested;
      }

      // Handle cases like shape [2, 0] -> [[], []]
      if (shape.contains(0)) {
        return buildEmptyNested(0);
      } else {
        return []; // Should not be reached if size is 0 and no dim is 0
      }
    }
    if (ndim == 0) {
      // Handle scalar array
      return [
        getDataItem(data, offsetInBytes ~/ data.elementSizeInBytes)
      ]; // Use public version
    }

    dynamic buildNestedList(int dimension, List<int> currentIndices) {
      List<dynamic> currentLevelList =
          List.filled(shape[dimension], null, growable: false);
      if (dimension == ndim - 1) {
        for (int i = 0; i < shape[dimension]; i++) {
          currentIndices[dimension] = i;
          int byteOffset = offsetInBytes;
          for (int d = 0; d < ndim; d++) {
            byteOffset += currentIndices[d] * strides[d];
          }
          currentLevelList[i] = getDataItem(data,
              byteOffset ~/ data.elementSizeInBytes); // Use public version
        }
      } else {
        for (int i = 0; i < shape[dimension]; i++) {
          currentIndices[dimension] = i;
          currentLevelList[i] = buildNestedList(dimension + 1, currentIndices);
        }
      }
      // Reset index for this dimension before returning up the recursion
      // currentIndices[dimension] = 0; // Not needed as a new list is passed down
      return currentLevelList;
    }

    return buildNestedList(0, List<int>.filled(ndim, 0));
  }

  // --- Helper Methods (originally private, now library-private) ---

  /// Returns a flat list of the data indices corresponding to the elements
  /// in this view, in logical order.
  /// Useful for iterating over view elements directly in the underlying buffer.
  List<int> getViewDataIndices() {
    // Renamed from _getViewDataIndices
    if (size == 0) return []; // Handle empty view

    final List<int> dataIndices = List<int>.filled(size, 0);
    final List<int> currentIndices = List<int>.filled(ndim, 0);
    final int elementSize = data.elementSizeInBytes;
    int dataIndexCounter = 0;

    for (int i = 0; i < size; i++) {
      // Calculate byte offset for the current logical index within the view
      int byteOffsetWithinView = 0;
      for (int d = 0; d < ndim; d++) {
        byteOffsetWithinView += currentIndices[d] * strides[d];
      }
      // Calculate the final byte offset in the original data buffer
      final int finalByteOffset = offsetInBytes + byteOffsetWithinView;
      // Convert byte offset to data index
      dataIndices[dataIndexCounter++] = finalByteOffset ~/ elementSize;

      // Increment the multi-dimensional logical index
      for (int d = ndim - 1; d >= 0; d--) {
        currentIndices[d]++;
        if (currentIndices[d] < shape[d]) {
          break; // No carry-over needed for this dimension
        }
        currentIndices[d] =
            0; // Reset current dimension index and carry-over to the next
      }
    }
    return dataIndices;
  }

  /// Assigns a scalar value to all elements within a given view.
  /// Internal helper used by the `[]= operator`.
  void assignScalarToView(NdArray targetView, num scalarValue) {
    // Renamed from _assignScalarToView
    // Use the public version now
    final List<int> viewDataIndices =
        targetView.getViewDataIndices(); // Use public version
    for (final int dataIndex in viewDataIndices) {
      try {
        // Use the public version now
        setDataItem(
            targetView.data, dataIndex, scalarValue); // Use public version
      } catch (e) {
        throw ArgumentError(
            'Failed to set scalar value $scalarValue to view element at data index $dataIndex: $e');
      }
    }
  }

  /// Converts the NdArray to a nested [List].
  ///
  /// The structure of the nested list mirrors the shape of the NdArray.
  /// For a 0-dimensional array (scalar), it returns a list containing the single element.
  /// For an empty array (size 0), it returns an empty list or nested empty lists
  /// matching the shape.
  ///
  /// Example:
  /// ```dart
  /// var a = NdArray.array([[1, 2], [3, 4]]);
  /// print(a.toList()); // Output: [[1, 2], [3, 4]]
  ///
  /// var b = NdArray.array(5); // Scalar
  /// print(b.toList()); // Output: [5]
  ///
  /// var c = NdArray.zeros([2, 0]);
  /// print(c.toList()); // Output: [[], []]
  /// ```

  // --- Helper Methods (originally private, now library-private) ---

  /// at that position.
  /// If any element in [indices] is a [Slice], it returns a new [NdArray] view
  /// representing the sliced portion.
  /// Performs element-wise addition with broadcasting.
  ///
  /// Supports addition with another [NdArray] or a scalar [num].
  /// The result dtype is determined by promoting the types of the operands.
  ///
  /// Throws [ArgumentError] if the operand types are unsupported or if
  /// broadcasting is not possible.
  NdArray operator +(dynamic other) {
    if (other is NdArray) {
      // --- Array-Array Addition with Broadcasting ---
      final List<int> broadcastShape =
          calculateBroadcastShape(shape, other.shape);
      final int resultSize = calculateSize(broadcastShape);
      final int resultNdim = broadcastShape.length;

      // Determine result primitive data type based on operands' dtypes
      final Type resultDataType =
          getResultDataType(dtype, other.dtype); // Use the new function
      // Determine the actual TypedData type for the result array
      final Type resultTypedDataType = (resultDataType == double)
          ? Float64List
          : Int64List; // Default int to Int64List

      // Use the static method from NdArray for creation
      final result = NdArray.zeros(broadcastShape, dtype: resultTypedDataType);
      if (resultSize == 0) return result;

      final List<int> currentIndices = List<int>.filled(resultNdim, 0);
      final int thisElementSizeBytes = data.elementSizeInBytes;
      final int otherElementSizeBytes = other.data.elementSizeInBytes;
      final int resultElementSizeBytes = result.data.elementSizeInBytes;

      for (int i = 0; i < resultSize; i++) {
        // Calculate byte offset for 'this' array considering broadcasting
        int thisByteOffset = offsetInBytes;
        for (int d = 0; d < resultNdim; d++) {
          final int idx = currentIndices[d];
          final int thisDimIdx =
              d - (resultNdim - ndim); // Align dimensions from the right
          if (thisDimIdx >= 0) {
            final int thisDimSize = shape[thisDimIdx];
            final int thisStride = strides[thisDimIdx];
            // If dimension was broadcast (size 1), use stride 0 effectively
            if (thisDimSize == 1 && broadcastShape[d] > 1) {
              // Stride is effectively 0, add nothing
            } else {
              thisByteOffset += idx * thisStride;
            }
          }
          // If thisDimIdx < 0, this dimension doesn't exist in 'this', effectively broadcast
        }
        final int thisDataIndex = thisByteOffset ~/ thisElementSizeBytes;

        // Calculate byte offset for 'other' array considering broadcasting
        int otherByteOffset = other.offsetInBytes;
        for (int d = 0; d < resultNdim; d++) {
          final int idx = currentIndices[d];
          final int otherDimIdx =
              d - (resultNdim - other.ndim); // Align dimensions
          if (otherDimIdx >= 0) {
            final int otherDimSize = other.shape[otherDimIdx];
            final int otherStride = other.strides[otherDimIdx];
            if (otherDimSize == 1 && broadcastShape[d] > 1) {
              // Stride is effectively 0, add nothing
            } else {
              otherByteOffset += idx * otherStride;
            }
          }
          // If otherDimIdx < 0, this dimension doesn't exist in 'other', effectively broadcast
        }
        final int otherDataIndex = otherByteOffset ~/ otherElementSizeBytes;

        // Calculate byte offset for 'result' array
        int resultByteOffset = 0;
        for (int d = 0; d < resultNdim; d++) {
          resultByteOffset += currentIndices[d] * result.strides[d];
        }
        final int resultDataIndex = resultByteOffset ~/ resultElementSizeBytes;

        // Perform operation and ensure correct type for result
        final dynamic val1 = getDataItem(data, thisDataIndex);
        final dynamic val2 = getDataItem(other.data, otherDataIndex);
        num sum;
        if (resultTypedDataType == Float64List) {
          sum = val1.toDouble() + val2.toDouble();
        } else {
          sum = val1.toInt() + val2.toInt();
        }
        setDataItem(result.data, resultDataIndex,
            sum); // setDataItem handles final conversion if needed

        // Increment multi-dimensional index for broadcast shape
        for (int d = resultNdim - 1; d >= 0; d--) {
          currentIndices[d]++;
          if (currentIndices[d] < broadcastShape[d]) break;
          currentIndices[d] = 0;
        }
      }
      return result;
    } else if (other is num) {
      // --- Array-Scalar Addition ---
      final num scalar = other;
      // Determine result TypedData type based on this.dtype and scalar type
      final Type resultTypedDataType;
      final bool isThisFloat = (dtype == double); // Check primitive type
      if (isThisFloat || scalar is double) {
        resultTypedDataType = Float64List; // Promote to Float64List
      } else {
        resultTypedDataType = Int64List; // Both are int types
      }
      // Use the static method from NdArray for creation
      final result = NdArray.zeros(shape, dtype: resultTypedDataType);
      if (size == 0) return result;

      final List<int> currentIndices = List<int>.filled(ndim, 0);
      final int elementSizeBytes = data.elementSizeInBytes;
      final int resultElementSizeBytes = result.data.elementSizeInBytes;

      for (int i = 0; i < size; i++) {
        int thisByteOffset = offsetInBytes;
        for (int d = 0; d < ndim; d++) {
          thisByteOffset += currentIndices[d] * strides[d];
        }
        final int thisDataIndex = thisByteOffset ~/ elementSizeBytes;

        int resultByteOffset = 0;
        for (int d = 0; d < ndim; d++) {
          resultByteOffset += currentIndices[d] * result.strides[d];
        }
        final int resultDataIndex = resultByteOffset ~/ resultElementSizeBytes;

        // Perform operation ensuring correct types
        final dynamic val1 = getDataItem(data, thisDataIndex);
        num sum;
        if (resultTypedDataType == Float64List) {
          sum = val1.toDouble() + scalar.toDouble();
        } else {
          sum = val1.toInt() + scalar.toInt();
        }
        setDataItem(result.data, resultDataIndex, sum);

        for (int d = ndim - 1; d >= 0; d--) {
          currentIndices[d]++;
          if (currentIndices[d] < shape[d]) break;
          currentIndices[d] = 0;
        }
      }
      return result;
    } else {
      throw ArgumentError(
          'Unsupported operand type for +: ${other.runtimeType}');
    }
  }

  /// Performs element-wise subtraction with broadcasting.
  ///
  /// Supports subtraction with another [NdArray] or a scalar [num].
  /// The result dtype is determined by promoting the types of the operands.
  ///
  /// Throws [ArgumentError] if the operand types are unsupported or if
  /// broadcasting is not possible.
  NdArray operator -(dynamic other) {
    if (other is NdArray) {
      // --- Array-Array Subtraction with Broadcasting ---
      final List<int> broadcastShape =
          calculateBroadcastShape(shape, other.shape);
      final int resultSize = calculateSize(broadcastShape);
      final int resultNdim = broadcastShape.length;

      // Determine result primitive data type based on operands' dtypes
      final Type resultDataType =
          getResultDataType(dtype, other.dtype); // Use the new function
      // Determine the actual TypedData type for the result array
      final Type resultTypedDataType = (resultDataType == double)
          ? Float64List
          : Int64List; // Default int to Int64List

      // Use the static method from NdArray for creation
      final result = NdArray.zeros(broadcastShape, dtype: resultTypedDataType);
      if (resultSize == 0) return result;

      final List<int> currentIndices = List<int>.filled(resultNdim, 0);
      final int thisElementSizeBytes = data.elementSizeInBytes;
      final int otherElementSizeBytes = other.data.elementSizeInBytes;
      final int resultElementSizeBytes = result.data.elementSizeInBytes;

      for (int i = 0; i < resultSize; i++) {
        // Calculate byte offset for 'this' array considering broadcasting
        int thisByteOffset = offsetInBytes;
        for (int d = 0; d < resultNdim; d++) {
          final int idx = currentIndices[d];
          final int thisDimIdx = d - (resultNdim - ndim); // Align dimensions
          if (thisDimIdx >= 0) {
            final int thisDimSize = shape[thisDimIdx];
            final int thisStride = strides[thisDimIdx];
            if (!(thisDimSize == 1 && broadcastShape[d] > 1)) {
              thisByteOffset += idx * thisStride;
            }
          }
        }
        final int thisDataIndex = thisByteOffset ~/ thisElementSizeBytes;

        // Calculate byte offset for 'other' array considering broadcasting
        int otherByteOffset = other.offsetInBytes;
        for (int d = 0; d < resultNdim; d++) {
          final int idx = currentIndices[d];
          final int otherDimIdx =
              d - (resultNdim - other.ndim); // Align dimensions
          if (otherDimIdx >= 0) {
            final int otherDimSize = other.shape[otherDimIdx];
            final int otherStride = other.strides[otherDimIdx];
            if (!(otherDimSize == 1 && broadcastShape[d] > 1)) {
              otherByteOffset += idx * otherStride;
            }
          }
        }
        final int otherDataIndex = otherByteOffset ~/ otherElementSizeBytes;

        // Calculate byte offset for 'result' array
        int resultByteOffset = 0;
        for (int d = 0; d < resultNdim; d++) {
          resultByteOffset += currentIndices[d] * result.strides[d];
        }
        final int resultDataIndex = resultByteOffset ~/ resultElementSizeBytes;

        // Perform operation and ensure correct type for result
        final dynamic val1 = getDataItem(data, thisDataIndex);
        final dynamic val2 = getDataItem(other.data, otherDataIndex);
        num diff;
        if (resultTypedDataType == Float64List) {
          diff = val1.toDouble() - val2.toDouble();
        } else {
          diff = val1.toInt() - val2.toInt();
        }
        setDataItem(result.data, resultDataIndex,
            diff); // setDataItem handles final conversion if needed

        // Increment multi-dimensional index for broadcast shape
        for (int d = resultNdim - 1; d >= 0; d--) {
          currentIndices[d]++;
          if (currentIndices[d] < broadcastShape[d]) break;
          currentIndices[d] = 0;
        }
      }
      return result;
    } else if (other is num) {
      // --- Array-Scalar Subtraction ---
      final num scalar = other;
      // Determine result TypedData type based on this.dtype and scalar type
      final Type resultTypedDataType;
      final bool isThisFloat = (dtype == double); // Check primitive type
      if (isThisFloat || scalar is double) {
        resultTypedDataType = Float64List; // Promote to Float64List
      } else {
        resultTypedDataType = Int64List; // Both are int types
      }
      // Use the static method from NdArray for creation
      final result = NdArray.zeros(shape, dtype: resultTypedDataType);
      if (size == 0) return result;

      final List<int> currentIndices = List<int>.filled(ndim, 0);
      final int elementSizeBytes = data.elementSizeInBytes;
      final int resultElementSizeBytes = result.data.elementSizeInBytes;

      for (int i = 0; i < size; i++) {
        int thisByteOffset = offsetInBytes;
        for (int d = 0; d < ndim; d++) {
          thisByteOffset += currentIndices[d] * strides[d];
        }
        final int thisDataIndex = thisByteOffset ~/ elementSizeBytes;

        int resultByteOffset = 0;
        for (int d = 0; d < ndim; d++) {
          resultByteOffset += currentIndices[d] * result.strides[d];
        }
        final int resultDataIndex = resultByteOffset ~/ resultElementSizeBytes;

        // Perform operation ensuring correct types
        final dynamic val1 = getDataItem(data, thisDataIndex);
        num diff;
        if (resultTypedDataType == Float64List) {
          diff = val1.toDouble() - scalar.toDouble();
        } else {
          diff = val1.toInt() - scalar.toInt();
        }
        setDataItem(result.data, resultDataIndex, diff);

        for (int d = ndim - 1; d >= 0; d--) {
          currentIndices[d]++;
          if (currentIndices[d] < shape[d]) break;
          currentIndices[d] = 0;
        }
      }
      return result;
    } else {
      throw ArgumentError(
          'Unsupported operand type for -: ${other.runtimeType}');
    }
  }

  /// Performs element-wise multiplication with broadcasting.
  ///
  /// Supports multiplication with another [NdArray] or a scalar [num].
  /// The result dtype is determined by promoting the types of the operands.
  ///
  /// Throws [ArgumentError] if the operand types are unsupported or if
  /// broadcasting is not possible.
  NdArray operator *(dynamic other) {
    if (other is NdArray) {
      // --- Array-Array Multiplication with Broadcasting ---
      final List<int> broadcastShape =
          calculateBroadcastShape(shape, other.shape);
      final int resultSize = calculateSize(broadcastShape);
      final int resultNdim = broadcastShape.length;

      // Determine result TypedData type based on operands' TypedData types
      final Type resultDataType =
          getResultDataType(dtype, other.dtype); // Use the new function
      // Determine the actual TypedData type for the result array
      final Type resultTypedDataType = (resultDataType == double)
          ? Float64List
          : Int64List; // Default int to Int64List
      // Use the static method from NdArray for creation
      final result = NdArray.zeros(broadcastShape, dtype: resultTypedDataType);
      if (resultSize == 0) return result;

      final List<int> currentIndices = List<int>.filled(resultNdim, 0);
      final int thisElementSizeBytes = data.elementSizeInBytes;
      final int otherElementSizeBytes = other.data.elementSizeInBytes;
      final int resultElementSizeBytes = result.data.elementSizeInBytes;

      for (int i = 0; i < resultSize; i++) {
        // Calculate byte offset for 'this' array considering broadcasting
        int thisByteOffset = offsetInBytes;
        for (int d = 0; d < resultNdim; d++) {
          final int idx = currentIndices[d];
          final int thisDimIdx = d - (resultNdim - ndim); // Align dimensions
          if (thisDimIdx >= 0) {
            final int thisDimSize = shape[thisDimIdx];
            final int thisStride = strides[thisDimIdx];
            if (!(thisDimSize == 1 && broadcastShape[d] > 1)) {
              thisByteOffset += idx * thisStride;
            }
          }
        }
        final int thisDataIndex = thisByteOffset ~/ thisElementSizeBytes;

        // Calculate byte offset for 'other' array considering broadcasting
        int otherByteOffset = other.offsetInBytes;
        for (int d = 0; d < resultNdim; d++) {
          final int idx = currentIndices[d];
          final int otherDimIdx =
              d - (resultNdim - other.ndim); // Align dimensions
          if (otherDimIdx >= 0) {
            final int otherDimSize = other.shape[otherDimIdx];
            final int otherStride = other.strides[otherDimIdx];
            if (!(otherDimSize == 1 && broadcastShape[d] > 1)) {
              otherByteOffset += idx * otherStride;
            }
          }
        }
        final int otherDataIndex = otherByteOffset ~/ otherElementSizeBytes;

        // Calculate byte offset for 'result' array
        int resultByteOffset = 0;
        for (int d = 0; d < resultNdim; d++) {
          resultByteOffset += currentIndices[d] * result.strides[d];
        }
        final int resultDataIndex = resultByteOffset ~/ resultElementSizeBytes;

        // Perform operation
        final dynamic val1 = getDataItem(data, thisDataIndex);
        final dynamic val2 = getDataItem(other.data, otherDataIndex);
        final num product; // Use num for intermediate calculation
        if (resultTypedDataType == Float64List) {
          product = val1.toDouble() * val2.toDouble();
        } else {
          product = val1.toInt() * val2.toInt();
        }
        setDataItem(result.data, resultDataIndex,
            product); // setDataItem handles final conversion if needed

        // Increment multi-dimensional index for broadcast shape
        for (int d = resultNdim - 1; d >= 0; d--) {
          currentIndices[d]++;
          if (currentIndices[d] < broadcastShape[d]) break;
          currentIndices[d] = 0;
        }
      }
      return result;
    } else if (other is num) {
      // --- Array-Scalar Multiplication ---
      final num scalar = other;
      // Determine result TypedData type based on this.dtype and scalar type
      final Type resultTypedDataType;
      final bool isThisFloat = (dtype == double); // Check primitive type
      if (isThisFloat || scalar is double) {
        resultTypedDataType = Float64List; // Promote to Float64List
      } else {
        resultTypedDataType = Int64List; // Both are int types
      }
      // Use the static method from NdArray for creation
      final result = NdArray.zeros(shape, dtype: resultTypedDataType);
      if (size == 0) return result;

      final List<int> currentIndices = List<int>.filled(ndim, 0);
      final int elementSizeBytes = data.elementSizeInBytes;
      final int resultElementSizeBytes = result.data.elementSizeInBytes;

      for (int i = 0; i < size; i++) {
        int thisByteOffset = offsetInBytes;
        for (int d = 0; d < ndim; d++) {
          thisByteOffset += currentIndices[d] * strides[d];
        }
        final int thisDataIndex = thisByteOffset ~/ elementSizeBytes;

        int resultByteOffset = 0;
        for (int d = 0; d < ndim; d++) {
          resultByteOffset += currentIndices[d] * result.strides[d];
        }
        final int resultDataIndex = resultByteOffset ~/ resultElementSizeBytes;

        // Perform operation ensuring correct types
        final dynamic val1 = getDataItem(data, thisDataIndex);
        num product;
        if (resultTypedDataType == Float64List) {
          product = val1.toDouble() * scalar.toDouble();
        } else {
          product = val1.toInt() * scalar.toInt();
        }
        setDataItem(result.data, resultDataIndex,
            product); // setDataItem handles final conversion if needed

        for (int d = ndim - 1; d >= 0; d--) {
          currentIndices[d]++;
          if (currentIndices[d] < shape[d]) break;
          currentIndices[d] = 0;
        }
      }
      return result;
    } else {
      throw ArgumentError(
          'Unsupported operand type for *: ${other.runtimeType}');
    }
  }

  /// Performs element-wise division with broadcasting.
  ///
  /// Supports division by another [NdArray] or a scalar [num].
  /// The result is always a double-precision floating-point array (`Float64List`).
  /// Division by zero follows standard Dart double behavior.
  ///
  /// Throws [ArgumentError] if the operand types are unsupported or if
  /// broadcasting is not possible.
  NdArray operator /(dynamic other) {
    if (other is num) {
      // --- Array-Scalar Division ---
      final num scalar = other;

      // 1. Result Type is always double for division
      final Type resultTypedDataType =
          Float64List; // Use final instead of const

      // 2. Create Result Array
      // Use the static method from NdArray for creation
      final result = NdArray.zeros(shape, dtype: resultTypedDataType);

      // 3. Element-wise Division using logical indices
      if (size == 0) return result;

      final List<int> currentIndices = List<int>.filled(ndim, 0);
      final int elementSizeBytes = data.elementSizeInBytes;
      final int resultElementSizeBytes =
          result.data.elementSizeInBytes; // Should be Float64List size

      for (int i = 0; i < size; i++) {
        // Calculate byte offset for 'this' array
        int thisByteOffset = offsetInBytes;
        for (int d = 0; d < ndim; d++) {
          thisByteOffset += currentIndices[d] * strides[d];
        }
        final int thisDataIndex = thisByteOffset ~/ elementSizeBytes;

        // Calculate byte offset for 'result' array
        int resultByteOffset = 0;
        for (int d = 0; d < ndim; d++) {
          resultByteOffset += currentIndices[d] * result.strides[d];
        }
        final int resultDataIndex = resultByteOffset ~/ resultElementSizeBytes;

        // Get value and divide by scalar
        final dynamic val1 = getDataItem(data, thisDataIndex);

        // Perform division, always resulting in double, handle division by zero
        final double divisionResult = val1.toDouble() / scalar.toDouble();

        // Set result (which is always double)
        setDataItem(result.data, resultDataIndex, divisionResult);

        // Increment logical indices
        for (int d = ndim - 1; d >= 0; d--) {
          currentIndices[d]++;
          if (currentIndices[d] < shape[d]) break;
          currentIndices[d] = 0;
        }
      }
      return result;
    } else if (other is NdArray) {
      // --- Array-Array Division with Broadcasting ---
      final List<int> broadcastShape =
          calculateBroadcastShape(shape, other.shape);
      final int resultSize = calculateSize(broadcastShape);
      final int resultNdim = broadcastShape.length;

      // Result is always double for division
      final Type resultTypedDataType =
          Float64List; // Use final instead of const
      // Use the static method from NdArray for creation
      final result = NdArray.zeros(broadcastShape, dtype: resultTypedDataType);
      if (resultSize == 0) return result;

      final List<int> currentIndices = List<int>.filled(resultNdim, 0);
      final int thisElementSizeBytes = data.elementSizeInBytes;
      final int otherElementSizeBytes = other.data.elementSizeInBytes;
      final int resultElementSizeBytes = result.data.elementSizeInBytes;

      for (int i = 0; i < resultSize; i++) {
        // Calculate byte offset for 'this' array considering broadcasting
        int thisByteOffset = offsetInBytes;
        for (int d = 0; d < resultNdim; d++) {
          final int idx = currentIndices[d];
          final int thisDimIdx = d - (resultNdim - ndim); // Align dimensions
          if (thisDimIdx >= 0) {
            final int thisDimSize = shape[thisDimIdx];
            final int thisStride = strides[thisDimIdx];
            if (!(thisDimSize == 1 && broadcastShape[d] > 1)) {
              thisByteOffset += idx * thisStride;
            }
          }
        }
        final int thisDataIndex = thisByteOffset ~/ thisElementSizeBytes;

        // Calculate byte offset for 'other' array considering broadcasting
        int otherByteOffset = other.offsetInBytes;
        for (int d = 0; d < resultNdim; d++) {
          final int idx = currentIndices[d];
          final int otherDimIdx =
              d - (resultNdim - other.ndim); // Align dimensions
          if (otherDimIdx >= 0) {
            final int otherDimSize = other.shape[otherDimIdx];
            final int otherStride = other.strides[otherDimIdx];
            if (!(otherDimSize == 1 && broadcastShape[d] > 1)) {
              otherByteOffset += idx * otherStride;
            }
          }
        }
        final int otherDataIndex = otherByteOffset ~/ otherElementSizeBytes;

        // Calculate byte offset for 'result' array
        int resultByteOffset = 0;
        for (int d = 0; d < resultNdim; d++) {
          resultByteOffset += currentIndices[d] * result.strides[d];
        }
        final int resultDataIndex = resultByteOffset ~/ resultElementSizeBytes;

        // Perform operation
        final dynamic val1 = getDataItem(data, thisDataIndex);
        final dynamic val2 = getDataItem(other.data, otherDataIndex);
        // Perform division, always resulting in double, handle division by zero
        final double divisionResult = val1.toDouble() / val2.toDouble();
        setDataItem(result.data, resultDataIndex, divisionResult);

        // Increment multi-dimensional index for broadcast shape
        for (int d = resultNdim - 1; d >= 0; d--) {
          currentIndices[d]++;
          if (currentIndices[d] < broadcastShape[d]) break;
          currentIndices[d] = 0;
        }
      }
      return result;
    } else {
      throw ArgumentError(
          'Unsupported operand type for /: ${other.runtimeType}');
    }
  }

  ///
  /// Throws [RangeError] if indices are out of bounds or the wrong number of
  /// indices are provided.
  /// Calculates the non-negative square root of each element.
  ///
  /// The result is always a double-precision floating-point array (`Float64List`).
  /// If an element is negative, the result for that element will be `NaN`.
  ///
  /// Example:
  /// ```dart
  /// var a = NdArray.array([4, 9, 16]);
  /// var b = a.sqrt(); // b will be NdArray([2.0, 3.0, 4.0], dtype: Float64List)
  ///
  /// var c = NdArray.array([4.0, -9.0, 16.0]);
  /// var d = c.sqrt(); // d will be NdArray([2.0, NaN, 4.0], dtype: Float64List)
  /// ```
  NdArray sqrt() {
    // Result is always double
    final Type resultTypedDataType = Float64List; // Use final
    final result = NdArray.zeros(shape, dtype: resultTypedDataType);

    if (size == 0) return result;

    final List<int> currentIndices = List<int>.filled(ndim, 0);
    final int elementSizeBytes = data.elementSizeInBytes;
    final int resultElementSizeBytes = result.data.elementSizeInBytes;

    for (int i = 0; i < size; i++) {
      // Calculate byte offset for 'this' array
      int thisByteOffset = offsetInBytes;
      for (int d = 0; d < ndim; d++) {
        thisByteOffset += currentIndices[d] * strides[d];
      }
      final int thisDataIndex = thisByteOffset ~/ elementSizeBytes;

      // Calculate byte offset for 'result' array
      int resultByteOffset = 0;
      for (int d = 0; d < ndim; d++) {
        resultByteOffset += currentIndices[d] * result.strides[d];
      }
      final int resultDataIndex = resultByteOffset ~/ resultElementSizeBytes;

      // Get value, calculate sqrt, and set result
      final dynamic val = getDataItem(data, thisDataIndex);
      final double sqrtResult = math.sqrt(val.toDouble()); // Use dart:math.sqrt
      setDataItem(result.data, resultDataIndex, sqrtResult);

      // Increment logical indices
      for (int d = ndim - 1; d >= 0; d--) {
        currentIndices[d]++;
        if (currentIndices[d] < shape[d]) break;
        currentIndices[d] = 0;
      }
    }
    return result;
  }

  /// Calculates the exponential of each element (e^x).
  ///
  /// The result is always a double-precision floating-point array (`Float64List`).
  ///
  /// Example:
  /// ```dart
  /// var a = NdArray.array([0, 1, 2]);
  /// var b = a.exp(); // b will be NdArray([1.0, 2.718..., 7.389...], dtype: Float64List)
  ///
  /// var c = NdArray.array([0.0, -1.0]);
  /// var d = c.exp(); // d will be NdArray([1.0, 0.367...], dtype: Float64List)
  /// ```
  NdArray exp() {
    // Result is always double
    final Type resultTypedDataType = Float64List; // Use final
    final result = NdArray.zeros(shape, dtype: resultTypedDataType);

    if (size == 0) return result;

    final List<int> currentIndices = List<int>.filled(ndim, 0);
    final int elementSizeBytes = data.elementSizeInBytes;
    final int resultElementSizeBytes = result.data.elementSizeInBytes;

    for (int i = 0; i < size; i++) {
      // Calculate byte offset for 'this' array
      int thisByteOffset = offsetInBytes;
      for (int d = 0; d < ndim; d++) {
        thisByteOffset += currentIndices[d] * strides[d];
      }
      final int thisDataIndex = thisByteOffset ~/ elementSizeBytes;

      // Calculate byte offset for 'result' array
      int resultByteOffset = 0;
      for (int d = 0; d < ndim; d++) {
        resultByteOffset += currentIndices[d] * result.strides[d];
      }
      final int resultDataIndex = resultByteOffset ~/ resultElementSizeBytes;

      // Get value, calculate exp, and set result
      final dynamic val = getDataItem(data, thisDataIndex);
      final double expResult = math.exp(val.toDouble()); // Use dart:math.exp
      setDataItem(result.data, resultDataIndex, expResult);

      // Increment logical indices
      for (int d = ndim - 1; d >= 0; d--) {
        currentIndices[d]++;
        if (currentIndices[d] < shape[d]) break;
        currentIndices[d] = 0;
      }
    }
    return result;
  }

  /// Calculates the sine of each element.
  ///
  /// The result is always a double-precision floating-point array (`Float64List`).
  /// Input values are interpreted as radians.
  ///
  /// Example:
  /// ```dart
  /// var a = NdArray.array([0, math.pi / 2, math.pi]);
  /// var b = a.sin(); // b will be NdArray([0.0, 1.0, 0.0], dtype: Float64List) (approx)
  /// ```
  NdArray sin() {
    // Result is always double
    final Type resultTypedDataType = Float64List; // Use final
    final result = NdArray.zeros(shape, dtype: resultTypedDataType);

    if (size == 0) return result;

    final List<int> currentIndices = List<int>.filled(ndim, 0);
    final int elementSizeBytes = data.elementSizeInBytes;
    final int resultElementSizeBytes = result.data.elementSizeInBytes;

    for (int i = 0; i < size; i++) {
      // Calculate byte offset for 'this' array
      int thisByteOffset = offsetInBytes;
      for (int d = 0; d < ndim; d++) {
        thisByteOffset += currentIndices[d] * strides[d];
      }
      final int thisDataIndex = thisByteOffset ~/ elementSizeBytes;

      // Calculate byte offset for 'result' array
      int resultByteOffset = 0;
      for (int d = 0; d < ndim; d++) {
        resultByteOffset += currentIndices[d] * result.strides[d];
      }
      final int resultDataIndex = resultByteOffset ~/ resultElementSizeBytes;

      // Get value, calculate sin, and set result
      final dynamic val = getDataItem(data, thisDataIndex);
      final double sinResult = math.sin(val.toDouble()); // Use dart:math.sin
      setDataItem(result.data, resultDataIndex, sinResult);

      // Increment logical indices
      for (int d = ndim - 1; d >= 0; d--) {
        currentIndices[d]++;
        if (currentIndices[d] < shape[d]) break;
        currentIndices[d] = 0;
      }
    }
    return result;
  }

  /// Calculates the cosine of each element.
  ///
  /// The result is always a double-precision floating-point array (`Float64List`).
  /// Input values are interpreted as radians.
  ///
  /// Example:
  /// ```dart
  /// var a = NdArray.array([0, math.pi / 2, math.pi]);
  /// var b = a.cos(); // b will be NdArray([1.0, 0.0, -1.0], dtype: Float64List) (approx)
  /// ```
  NdArray cos() {
    // Result is always double
    final Type resultTypedDataType = Float64List; // Use final
    final result = NdArray.zeros(shape, dtype: resultTypedDataType);

    if (size == 0) return result;

    final List<int> currentIndices = List<int>.filled(ndim, 0);
    final int elementSizeBytes = data.elementSizeInBytes;
    final int resultElementSizeBytes = result.data.elementSizeInBytes;

    for (int i = 0; i < size; i++) {
      // Calculate byte offset for 'this' array
      int thisByteOffset = offsetInBytes;
      for (int d = 0; d < ndim; d++) {
        thisByteOffset += currentIndices[d] * strides[d];
      }
      final int thisDataIndex = thisByteOffset ~/ elementSizeBytes;

      // Calculate byte offset for 'result' array
      int resultByteOffset = 0;
      for (int d = 0; d < ndim; d++) {
        resultByteOffset += currentIndices[d] * result.strides[d];
      }
      final int resultDataIndex = resultByteOffset ~/ resultElementSizeBytes;

      // Get value, calculate cos, and set result
      final dynamic val = getDataItem(data, thisDataIndex);
      final double cosResult = math.cos(val.toDouble()); // Use dart:math.cos
      setDataItem(result.data, resultDataIndex, cosResult);

      // Increment logical indices
      for (int d = ndim - 1; d >= 0; d--) {
        currentIndices[d]++;
        if (currentIndices[d] < shape[d]) break;
        currentIndices[d] = 0;
      }
    }
    return result;
  }

  /// Calculates the tangent of each element.
  ///
  /// The result is always a double-precision floating-point array (`Float64List`).
  /// Input values are interpreted as radians.
  ///
  /// Example:
  /// ```dart
  /// var a = NdArray.array([0, math.pi / 4, math.pi]);
  /// var b = a.tan(); // b will be NdArray([0.0, 1.0, 0.0], dtype: Float64List) (approx)
  /// ```
  NdArray tan() {
    // Result is always double
    final Type resultTypedDataType = Float64List; // Use final
    final result = NdArray.zeros(shape, dtype: resultTypedDataType);

    if (size == 0) return result;

    final List<int> currentIndices = List<int>.filled(ndim, 0);
    final int elementSizeBytes = data.elementSizeInBytes;
    final int resultElementSizeBytes = result.data.elementSizeInBytes;

    for (int i = 0; i < size; i++) {
      // Calculate byte offset for 'this' array
      int thisByteOffset = offsetInBytes;
      for (int d = 0; d < ndim; d++) {
        thisByteOffset += currentIndices[d] * strides[d];
      }
      final int thisDataIndex = thisByteOffset ~/ elementSizeBytes;

      // Calculate byte offset for 'result' array
      int resultByteOffset = 0;
      for (int d = 0; d < ndim; d++) {
        resultByteOffset += currentIndices[d] * result.strides[d];
      }
      final int resultDataIndex = resultByteOffset ~/ resultElementSizeBytes;

      // Get value, calculate tan, and set result
      final dynamic val = getDataItem(data, thisDataIndex);
      final double tanResult = math.tan(val.toDouble()); // Use dart:math.tan
      setDataItem(result.data, resultDataIndex, tanResult);

      // Increment logical indices
      for (int d = ndim - 1; d >= 0; d--) {
        currentIndices[d]++;
        if (currentIndices[d] < shape[d]) break;
        currentIndices[d] = 0;
      }
    }
    return result;
  }

  /// Calculates the natural logarithm (base e) of each element.
  ///
  /// The result is always a double-precision floating-point array (`Float64List`).
  /// - For positive input values `x`, the result is `ln(x)`.
  /// - For input value `0`, the result is `double.negativeInfinity`.
  /// - For negative input values, the result is `double.nan` (Not a Number).
  ///
  /// Example:
  /// ```dart
  /// var a = NdArray.array([1, math.e, 10, 0, -1]);
  /// var b = a.log();
  /// // b will be NdArray([0.0, 1.0, 2.3025..., -Infinity, NaN], dtype: Float64List) (approx)
  /// ```
  NdArray log() {
    // Result is always double
    final Type resultTypedDataType = Float64List; // Use final
    final result = NdArray.zeros(shape, dtype: resultTypedDataType);

    if (size == 0) return result;

    final List<int> currentIndices = List<int>.filled(ndim, 0);
    final int elementSizeBytes = data.elementSizeInBytes;
    final int resultElementSizeBytes = result.data.elementSizeInBytes;

    for (int i = 0; i < size; i++) {
      // Calculate byte offset for 'this' array
      int thisByteOffset = offsetInBytes;
      for (int d = 0; d < ndim; d++) {
        thisByteOffset += currentIndices[d] * strides[d];
      }
      final int thisDataIndex = thisByteOffset ~/ elementSizeBytes;

      // Calculate byte offset for 'result' array
      int resultByteOffset = 0;
      for (int d = 0; d < ndim; d++) {
        resultByteOffset += currentIndices[d] * result.strides[d];
      }
      final int resultDataIndex = resultByteOffset ~/ resultElementSizeBytes;

      // Get value, calculate log, and set result
      final dynamic val = getDataItem(data, thisDataIndex);
      final double logResult = math.log(val.toDouble()); // Use dart:math.log
      setDataItem(result.data, resultDataIndex, logResult);

      // Increment logical indices
      for (int d = ndim - 1; d >= 0; d--) {
        currentIndices[d]++;
        if (currentIndices[d] < shape[d]) break;
        currentIndices[d] = 0;
      }
    }
    return result;
  }

  /// Throws [ArgumentError] if an invalid type is provided in the [indices] list.
  dynamic operator [](List<Object> indices) {
    if (indices.length != ndim)
      throw RangeError('Expected $ndim indices/slices, got ${indices.length}.');
    bool isSlicing = indices.any((item) => item is Slice);

    if (!isSlicing) {
      // Pure integer indexing
      List<int> intIndices;
      try {
        intIndices = indices.cast<int>();
      } catch (e) {
        throw ArgumentError('Invalid index type: $indices.');
      }
      int byteOffsetWithinView = 0;
      for (int i = 0; i < ndim; i++) {
        int index = intIndices[i];
        int dimSize = shape[i];
        if (index < 0) index += dimSize;
        if (index < 0 || index >= dimSize)
          throw RangeError(
              'Index $index out of bounds for dim $i size $dimSize');
        byteOffsetWithinView += index * strides[i];
      }
      final int finalByteOffset = offsetInBytes + byteOffsetWithinView;
      final int dataIndex = finalByteOffset ~/ data.elementSizeInBytes;
      return getDataItem(data, dataIndex);
    } else {
      // Slicing (create a view)
      final List<int> newShape = [];
      final List<int> newStrides = [];
      int viewOffsetInBytes = offsetInBytes;
      for (int i = 0; i < ndim; i++) {
        final indexOrSlice = indices[i];
        final currentDimSize = shape[i];
        final currentStride = strides[i];
        if (indexOrSlice is int) {
          int index = indexOrSlice;
          if (index < 0) index += currentDimSize;
          if (index < 0 || index >= currentDimSize)
            throw RangeError(
                'Index $index out of bounds for dim $i size $currentDimSize');
          viewOffsetInBytes += index * currentStride;
        } else if (indexOrSlice is Slice) {
          final slice = indexOrSlice;
          final (start, _, step, length) = slice.adjust(currentDimSize);
          newShape.add(length);
          newStrides.add(currentStride * step);
          viewOffsetInBytes += start * currentStride;
        } else {
          throw ArgumentError(
              'Invalid type in index list: ${indexOrSlice.runtimeType}.');
        }
      }
      final int newSize =
          newShape.isEmpty ? 1 : newShape.reduce((a, b) => a * b);
      final int newNdim = newShape.length;
      // Note: NdArray._ is the internal constructor
      return NdArray._(data, newShape, newStrides, dtype, newSize, newNdim,
          viewOffsetInBytes);
    }
  }

  /// Assigns a [value] to the element or slice specified by [indices].
  ///
  /// If all elements in [indices] are integers, assigns the scalar [value]
  /// to the single element at that position.
  /// If any element in [indices] is a [Slice], assigns the [value] (which can be
  /// a scalar or a broadcastable [NdArray]) to the resulting view.
  ///
  /// Throws [RangeError] if indices are out of bounds or the wrong number of
  /// indices are provided.
  /// Throws [ArgumentError] if an invalid type is provided in the [indices] list,
  /// if the [value] type is incompatible, or if broadcasting fails.
  void operator []=(List<Object> indices, dynamic value) {
    if (indices.length != ndim) {
      throw RangeError(
          'Incorrect number of indices provided. Expected $ndim, got ${indices.length}.');
    }
    bool isSlicing = indices.any((item) => item is Slice);

    if (!isSlicing) {
      // --- Integer Index Assignment ---
      List<int> intIndices;
      try {
        intIndices = indices.cast<int>();
      } catch (e) {
        throw ArgumentError(
            'Invalid index type for integer assignment: expected List<int>, got $indices.');
      }

      if (value is! num) {
        throw ArgumentError(
            'Value for single element assignment must be a number (int or double), got ${value.runtimeType}');
      }

      int byteOffsetWithinView = 0;
      for (int i = 0; i < ndim; i++) {
        int index = intIndices[i];
        int dimSize = shape[i];
        if (index < 0) index += dimSize;
        if (index < 0 || index >= dimSize) {
          throw RangeError(
              'Index $index is out of bounds for dim $i size $dimSize');
        }
        byteOffsetWithinView += index * strides[i];
      }

      final int finalByteOffset = offsetInBytes + byteOffsetWithinView;
      final int dataIndex = finalByteOffset ~/ data.elementSizeInBytes;

      try {
        setDataItem(data, dataIndex, value);
      } catch (e) {
        throw ArgumentError('Failed to set value: $e');
      }
    } else {
      // --- Slice Assignment ---
      NdArray targetView;
      try {
        // Using 'this[]' relies on the operator[] being defined in this class
        targetView = this[indices]; // Get the view representing the slice
      } catch (e) {
        throw ArgumentError('Invalid slice or index for assignment target: $e');
      }

      if (value is NdArray) {
        // --- Assigning an NdArray to a Slice ---
        final NdArray sourceArray = value;

        // 1. Check dtype compatibility (TODO: Implement type promotion/casting later)
        if (targetView.dtype != sourceArray.dtype) {
          // Attempt conversion if possible (e.g., int to double)
          if (targetView.dtype == Float64List &&
              sourceArray.dtype == Int32List) {
            // Allow assigning int array to double slice (will convert)
          } else if (targetView.dtype == Int32List &&
              sourceArray.dtype == Float64List) {
            // Allow assigning double array to int slice (will truncate)
          } else {
            throw ArgumentError(
                'Cannot assign NdArray with dtype ${sourceArray.dtype} to slice with dtype ${targetView.dtype}. Type promotion not yet implemented for this combination.');
          }
        }

        // 2. Check broadcast compatibility
        final List<int> broadcastShape;
        try {
          // The source array must be broadcastable *to* the target view's shape
          broadcastShape =
              calculateBroadcastShape(targetView.shape, sourceArray.shape);
          // Ensure the broadcast result matches the target view's shape exactly
          if (!const ListEquality().equals(broadcastShape, targetView.shape)) {
            throw ArgumentError(
                'Shape mismatch: Source array shape ${sourceArray.shape} cannot be broadcast to target slice shape ${targetView.shape}');
          }
        } catch (e) {
          throw ArgumentError(
              'Source array shape ${sourceArray.shape} cannot be broadcast to target slice shape ${targetView.shape}: $e');
        }

        // 3. Perform element-wise assignment with broadcasting
        if (targetView.size == 0)
          return; // Nothing to assign if target is empty

        final int targetNdim = targetView.ndim;
        final List<int> currentIndices = List<int>.filled(targetNdim, 0);
        final int targetElementSizeBytes = targetView.data
            .elementSizeInBytes; // Should be same as this.data.elementSizeInBytes
        final int sourceElementSizeBytes = sourceArray.data.elementSizeInBytes;

        for (int i = 0; i < targetView.size; i++) {
          // Calculate byte offset for the target view element
          int targetByteOffset = targetView.offsetInBytes;
          for (int d = 0; d < targetNdim; d++) {
            targetByteOffset += currentIndices[d] * targetView.strides[d];
          }
          final int targetDataIndex =
              targetByteOffset ~/ targetElementSizeBytes;

          // Calculate corresponding byte offset for the source array element (with broadcasting)
          int sourceByteOffset = sourceArray.offsetInBytes;
          for (int d = 0; d < targetNdim; d++) {
            final int idx = currentIndices[d];
            final int sourceDimIdx =
                d - (targetNdim - sourceArray.ndim); // Align dimensions
            if (sourceDimIdx >= 0) {
              final int sourceDimSize = sourceArray.shape[sourceDimIdx];
              final int sourceStride = sourceArray.strides[sourceDimIdx];
              // Use index 0 if the source dimension was broadcast
              if (sourceDimSize == 1 && targetView.shape[d] > 1) {
                // Use index 0 for broadcast dimension -> add 0 * stride
              } else {
                sourceByteOffset += idx * sourceStride;
              }
            }
            // If sourceDimIdx < 0, this dimension doesn't exist in source, effectively broadcast
          }
          final int sourceDataIndex =
              sourceByteOffset ~/ sourceElementSizeBytes;

          // Get value from source and set it in the target view's data buffer
          final dynamic sourceValue =
              getDataItem(sourceArray.data, sourceDataIndex);
          try {
            // Use targetView.data which points to the same underlying buffer as this.data
            setDataItem(targetView.data, targetDataIndex, sourceValue);
          } catch (e) {
            throw ArgumentError(
                'Failed to set value during slice assignment: $e');
          }

          // Increment multi-dimensional index for the target view shape
          for (int d = targetNdim - 1; d >= 0; d--) {
            currentIndices[d]++;
            if (currentIndices[d] < targetView.shape[d]) break;
            currentIndices[d] = 0;
          }
        }
      } else if (value is num) {
        // --- Assigning a Scalar to a Slice ---
        // Note: _assignScalarToView needs to be accessible or moved
        assignScalarToView(targetView, value);
      } else {
        throw ArgumentError(
            'Value for slice assignment must be a number or an NdArray, got ${value.runtimeType}');
      }
    }
  }

  // --- Manipulation ---
  // Defined in ndarray_manipulation.dart via methods

  // --- Mathematical Operations ---
  // Defined in ndarray_math_ops.dart via operator methods

  // --- Element-wise Mathematical Functions ---
  // Defined in ndarray_math_funcs.dart via methods
} // End of NdArray class
