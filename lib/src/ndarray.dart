import 'dart:typed_data';
import 'dart:math'; // For max function
import 'package:meta/meta.dart';
import 'package:collection/collection.dart'; // Needed for ListEquality
import 'slice.dart'; // Import Slice

// --- Top-Level Helper Functions ---

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

int _calculateSize(List<int> shape) {
  if (shape.isEmpty) return 1; // Scalar size
  if (shape.contains(0)) return 0;
  return shape.reduce((value, element) => value * element);
}

Type _getDType(TypedData data) {
  if (data is Int8List) return int;
  if (data is Uint8List) return int;
  if (data is Int16List) return int;
  if (data is Uint16List) return int;
  if (data is Int32List) return int;
  if (data is Uint32List) return int;
  if (data is Int64List) return int;
  if (data is Uint64List) return int;
  if (data is Float32List) return double;
  if (data is Float64List) return double;
  throw ArgumentError('Unsupported TypedData type: ${data.runtimeType}');
}

int _getElementSizeInBytes(TypedData data) {
  return data.elementSizeInBytes;
}

List<int> _inferShape(List list) {
  if (list.isEmpty) return [0];
  final firstElement = list[0];
  if (firstElement is List) {
    final subShape = _inferShape(firstElement);
    for (int i = 0; i < list.length; i++) {
      if (list[i] is! List)
        throw ArgumentError(
            'Inconsistent structure: element at index $i is not a List.');
      final currentSubShape = _inferShape(list[i] as List);
      if (currentSubShape.length != subShape.length ||
          !const ListEquality().equals(currentSubShape, subShape)) {
        throw ArgumentError(
            'Inconsistent shape: expected $subShape but got $currentSubShape at index $i.');
      }
    }
    return [list.length, ...subShape];
  } else {
    for (int i = 0; i < list.length; i++) {
      if (list[i] is List)
        throw ArgumentError(
            'Inconsistent structure: mix of lists and non-lists at index $i.');
    }
    return [list.length];
  }
}

List<T> _flatten<T extends num>(List nestedList) {
  final List<T> flatList = [];
  for (final element in nestedList) {
    if (element is List) {
      flatList.addAll(_flatten<T>(element));
    } else if (element is T) {
      flatList.add(element);
    } else if (element is num) {
      try {
        if (T == double)
          flatList.add(element.toDouble() as T);
        else if (T == int)
          flatList.add(element.toInt() as T);
        else
          throw ArgumentError('Unsupported target numeric type $T');
      } catch (e) {
        throw ArgumentError(
            'Failed to convert type ${element.runtimeType} to $T: $e');
      }
    } else {
      throw ArgumentError('Non-numeric type ${element.runtimeType} found.');
    }
  }
  return flatList;
}

Type? _inferDataType(List list) {
  Type? inferredType;
  bool hasDouble = false;
  bool hasInt = false;
  bool isEmpty = true;
  void checkElement(dynamic element) {
    if (element is List) {
      if (!(element.isEmpty &&
          list.length > 1 &&
          list[0] is List &&
          (list[0] as List).isEmpty)) {
        isEmpty = false;
        for (var subElement in element) checkElement(subElement);
      }
    } else if (element is double) {
      hasDouble = true;
      inferredType ??= Float64List;
      isEmpty = false;
    } else if (element is int) {
      hasInt = true;
      inferredType ??= Int64List;
      isEmpty = false;
    } else {
      isEmpty = false;
      throw ArgumentError('Non-numeric type ${element.runtimeType} found.');
    }
  }

  if (list.isEmpty) return null;
  checkElement(list);
  if (isEmpty && list.isNotEmpty && list[0] is List) return null;
  if (hasDouble && hasInt) return Float64List;
  return inferredType;
}

TypedData _createTypedData(Type type, int length) {
  if (identical(type, Int8List)) return Int8List(length);
  if (identical(type, Uint8List)) return Uint8List(length);
  if (identical(type, Int16List)) return Int16List(length);
  if (identical(type, Uint16List)) return Uint16List(length);
  if (identical(type, Int32List)) return Int32List(length);
  if (identical(type, Uint32List)) return Uint32List(length);
  if (identical(type, Int64List)) return Int64List(length);
  if (identical(type, Uint64List)) return Uint64List(length);
  if (identical(type, Float32List)) return Float32List(length);
  if (identical(type, Float64List)) return Float64List(length);
  throw ArgumentError("Unsupported dtype for TypedData creation: $type");
}

// Removed targetType parameter as we check data directly
void _setDataItem(TypedData data, int index, num value) {
  // Use 'is' checks on the actual data object
  if (data is Int8List)
    data[index] = value.toInt();
  else if (data is Uint8List)
    data[index] = value.toInt();
  else if (data is Int16List)
    data[index] = value.toInt();
  else if (data is Uint16List)
    data[index] = value.toInt();
  else if (data is Int32List)
    data[index] = value.toInt();
  else if (data is Uint32List)
    data[index] = value.toInt();
  else if (data is Int64List)
    data[index] = value.toInt();
  else if (data is Uint64List)
    data[index] = value.toInt();
  else if (data is Float32List)
    data[index] = value.toDouble();
  else if (data is Float64List)
    data[index] = value.toDouble();
  else
    throw ArgumentError(
        "Unsupported TypedData type for setting item: ${data.runtimeType}");
}

dynamic _getDataItem(TypedData data, int index) {
  if (data is Int8List) return data[index];
  if (data is Uint8List) return data[index];
  if (data is Int16List) return data[index];
  if (data is Uint16List) return data[index];
  if (data is Int32List) return data[index];
  if (data is Uint32List) return data[index];
  if (data is Int64List) return data[index];
  if (data is Uint64List) return data[index];
  if (data is Float32List) return data[index];
  if (data is Float64List) return data[index];
  throw ArgumentError(
      "Unsupported TypedData type for getting item: ${data.runtimeType}");
}

/// Represents a multi-dimensional, fixed-size array of items of the same type.
class NdArray {
  @internal
  final TypedData data;
  final List<int> shape;
  final List<int> strides;
  final Type dtype;
  final int size;
  final int ndim;
  @internal
  final int offsetInBytes;

  /// Internal constructor - Use factory methods or internalCreateView.
  NdArray._(this.data, this.shape, this.strides, this.dtype, this.size,
      this.ndim, this.offsetInBytes);

  /// Internal factory method to create a view.
  @internal
  static NdArray internalCreateView(TypedData data, List<int> shape,
      List<int> strides, Type dtype, int size, int ndim, int offsetInBytes) {
    // This method exists to allow creating views from outside the class (e.g., in extensions for testing)
    // without exposing the private constructor directly.
    return NdArray._(data, shape, strides, dtype, size, ndim, offsetInBytes);
  }

  // --- Factory Constructors ---

  factory NdArray.array(List list, {Type? dtype}) {
    final List<int> shape = _inferShape(list);
    if (shape.length == 1 && shape[0] == 0) {
      final targetType = dtype ?? Float64List;
      final data = _createTypedData(targetType, 0);
      final elementSize = _getElementSizeInBytes(data);
      final strides = _calculateStrides(shape, elementSize);
      final actualDtype = _getDType(data);
      // Corrected call with 7 arguments
      return NdArray._(data, shape, strides, actualDtype, 0, 1, 0);
    }
    if (shape.length > 1 && shape.contains(0)) {
      final targetType = dtype ?? Float64List;
      final data = _createTypedData(targetType, 0);
      final elementSize = _getElementSizeInBytes(data);
      final strides = _calculateStrides(shape, elementSize);
      final actualDtype = _getDType(data);
      final size = _calculateSize(shape);
      // Corrected call with 7 arguments
      return NdArray._(
          data, shape, strides, actualDtype, size, shape.length, 0);
    }
    Type targetType = dtype ?? _inferDataType(list) ?? Float64List;
    List<num> flatList = _flatten<num>(list);
    final int size = _calculateSize(shape);
    if (size != flatList.length) {
      throw StateError(
          'Shape size $size != flattened list length ${flatList.length}.');
    }
    TypedData data;
    try {
      data = _createTypedData(targetType, size);
      for (int i = 0; i < size; i++)
        _setDataItem(data, i, flatList[i]); // Removed targetType
    } catch (e) {
      throw ArgumentError('Failed to create TypedData: $e');
    }
    final int elementSize = _getElementSizeInBytes(data);
    final List<int> strides = _calculateStrides(shape, elementSize);
    final Type actualDtype = _getDType(data);
    final int ndim = shape.length;
    // Corrected call with 7 arguments
    return NdArray._(data, shape, strides, actualDtype, size, ndim, 0);
  }

  factory NdArray.zeros(List<int> shape, {Type dtype = Float64List}) {
    if (shape.any((dim) => dim < 0))
      throw ArgumentError('Negative dimensions not allowed.');
    final int size = _calculateSize(shape);
    TypedData data;
    try {
      data = _createTypedData(dtype, size);
    } catch (e) {
      throw ArgumentError('Failed to create TypedData: $e');
    }
    final int elementSize = _getElementSizeInBytes(data);
    final List<int> strides = _calculateStrides(shape, elementSize);
    final Type actualDtype = _getDType(data);
    final int ndim = shape.length;
    // Corrected call with 7 arguments
    return NdArray._(data, shape, strides, actualDtype, size, ndim, 0);
  }

  factory NdArray.ones(List<int> shape, {Type dtype = Float64List}) {
    if (shape.any((dim) => dim < 0))
      throw ArgumentError('Negative dimensions not allowed.');
    final int size = _calculateSize(shape);
    TypedData data;
    try {
      data = _createTypedData(dtype, size);
      num oneValue = (dtype == Float32List || dtype == Float64List) ? 1.0 : 1;
      for (int i = 0; i < size; i++)
        _setDataItem(data, i, oneValue); // Removed dtype
    } catch (e) {
      throw ArgumentError('Failed to create TypedData: $e');
    }
    final int elementSize = _getElementSizeInBytes(data);
    final List<int> strides = _calculateStrides(shape, elementSize);
    final Type actualDtype = _getDType(data);
    final int ndim = shape.length;
    // Corrected call with 7 arguments
    return NdArray._(data, shape, strides, actualDtype, size, ndim, 0);
  }

  factory NdArray.arange(num startOrStop,
      {num? stop, num step = 1, Type? dtype}) {
    num actualStart;
    num actualStop;
    if (stop == null) {
      actualStart = 0;
      actualStop = startOrStop;
    } else {
      actualStart = startOrStop;
      actualStop = stop;
    }
    if (step == 0) throw ArgumentError('step cannot be zero');
    final bool isInputInt =
        actualStart is int && actualStop is int && step is int;
    final Type targetType = dtype ?? (isInputInt ? Int64List : Float64List);
    int size = 0;
    if (step > 0 && actualStop > actualStart)
      size = max(
          0,
          ((actualStop.toDouble() - actualStart.toDouble()) / step.toDouble())
              .ceil());
    else if (step < 0 && actualStop < actualStart)
      size = max(
          0,
          ((actualStop.toDouble() - actualStart.toDouble()) / step.toDouble())
              .ceil());
    if (size <= 0) {
      final emptyData = _createTypedData(targetType, 0);
      final shape = [0];
      final elementSize = _getElementSizeInBytes(emptyData);
      final strides = _calculateStrides(shape, elementSize);
      final actualDtype = _getDType(emptyData);
      // Corrected call with 7 arguments
      return NdArray._(emptyData, shape, strides, actualDtype, 0, 1, 0);
    }
    TypedData data;
    try {
      data = _createTypedData(targetType, size);
      num currentValue = actualStart;
      for (int i = 0; i < size; i++) {
        _setDataItem(data, i, currentValue); // Removed targetType
        currentValue = currentValue.toDouble() + step.toDouble();
      }
    } catch (e) {
      throw ArgumentError('Failed to create TypedData: $e');
    }
    final shape = [size];
    final int elementSize = _getElementSizeInBytes(data);
    final List<int> strides = _calculateStrides(shape, elementSize);
    final Type actualDtype = _getDType(data);
    final int ndim = 1;
    // Corrected call with 7 arguments
    return NdArray._(data, shape, strides, actualDtype, size, ndim, 0);
  }

  /// Creates an [NdArray] with a specified number of samples, spaced
  /// evenly between [start] and [stop].
  ///
  /// Similar to NumPy's `linspace`.
  ///
  /// - [start]: The starting value of the sequence.
  /// - [stop]: The end value of the sequence.
  /// - [num]: Number of samples to generate. Default is 50. Must be non-negative.
  /// - [endpoint]: If true (default), [stop] is the last sample. Otherwise, it is not included.
  /// - [dtype]: The desired data type. Defaults to [Float64List]. Linspace typically produces floats.
  ///
  /// Example:
  /// ```dart
  /// var a = NdArray.linspace(0, 1, num: 5); // [0.0, 0.25, 0.5, 0.75, 1.0]
  /// var b = NdArray.linspace(0, 1, num: 5, endpoint: false); // [0.0, 0.2, 0.4, 0.6, 0.8]
  /// ```
  factory NdArray.linspace(
    num start,
    num stop, {
    int num = 50,
    bool endpoint = true,
    Type dtype = Float64List,
  }) {
    if (num < 0) {
      throw ArgumentError('Number of samples, num, cannot be negative.');
    }
    if (num == 0) {
      // Return empty array
      final emptyData = _createTypedData(dtype, 0);
      final shape = [0];
      final elementSize = _getElementSizeInBytes(emptyData);
      final strides = _calculateStrides(shape, elementSize);
      final actualDtype = _getDType(emptyData);
      return NdArray._(emptyData, shape, strides, actualDtype, 0, 1, 0);
    }
    if (num == 1) {
      // Return array with only the start value
      final data = _createTypedData(dtype, 1);
      _setDataItem(data, 0, start);
      final shape = [1];
      final elementSize = _getElementSizeInBytes(data);
      final strides = _calculateStrides(shape, elementSize);
      final actualDtype = _getDType(data);
      return NdArray._(data, shape, strides, actualDtype, 1, 1, 0);
    }

    // Calculate step, always use double for precision
    double step;
    int div = endpoint ? (num - 1) : num;
    // Avoid division by zero if num=1 (already handled) but check anyway
    if (div == 0) div = 1;
    step = (stop.toDouble() - start.toDouble()) / div;

    // Create data and fill
    TypedData data;
    try {
      data = _createTypedData(dtype, num);
      for (int i = 0; i < num; i++) {
        // Calculate value using double precision
        double value = start.toDouble() + i * step;
        // Ensure the last value is exactly 'stop' if endpoint is true and step calculation was precise
        if (endpoint && i == num - 1) {
          value = stop.toDouble();
        }
        _setDataItem(data, i, value); // Let _setDataItem handle conversion
      }
    } catch (e) {
      throw ArgumentError(
          'Failed to create TypedData for linspace with dtype $dtype: $e');
    }

    // Calculate other properties
    final shape = [num];
    final int elementSize = _getElementSizeInBytes(data);
    final List<int> strides = _calculateStrides(shape, elementSize);
    final Type actualDtype = _getDType(data);
    final int ndim = 1; // linspace always produces 1D array

    // Create Instance
    return NdArray._(data, shape, strides, actualDtype, num, ndim, 0);
  }

  // --- Basic Properties ---
  int get dimensions => ndim;

  // --- Indexing and Slicing ---
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
      return _getDataItem(data, dataIndex);
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
      // DEBUG PRINT: Remove later
      // print('>>> DEBUG Creating View: newShape=$newShape newStrides=$newStrides newOffset=$viewOffsetInBytes');

      // Corrected call with 7 arguments
      return NdArray._(data, newShape, newStrides, dtype, newSize, newNdim,
          viewOffsetInBytes);
    }
  }

  /// Sets the element(s) at the specified multi-dimensional index or slice to [value].
  ///
  /// - If [indices] contains only integers, it sets a single element.
  /// - If [indices] contains any [Slice] objects, it performs slice assignment.
  ///   Currently, only assigning a scalar [num] value to a slice is supported.
  ///
  /// [indices] must have a length equal to [ndim].
  /// Integer indices must be within the bounds of the corresponding dimension.
  /// Supports negative indexing for integers.
  ///
  /// The [value] will be converted to the array's data type ([dtype]).
  ///
  /// Example:
  /// ```dart
  /// var a = NdArray.zeros([2, 2]);
  /// a[[0, 1]] = 5.0;
  /// print(a[[0, 1]]); // Output: 5.0 (or 5 if dtype is int)
  /// ```
  ///
  /// Throws [RangeError] if indices are out of bounds or have incorrect length.
  /// Throws [TypeError] if indices contain invalid types.
  /// Throws [ArgumentError] if [value] is not a [num] or cannot be converted.
  /// Throws [UnimplementedError] if attempting non-scalar slice assignment.
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

      // Existing integer assignment logic starts here...
      // (Adjust variable names if needed, e.g., use intIndices instead of indices)
      int byteOffsetWithinView = 0;
      for (int i = 0; i < ndim; i++) {
        int index = intIndices[i]; // Use intIndices
        int dimSize = shape[i];
        if (index < 0) index += dimSize; // Handle negative indexing
        if (index < 0 || index >= dimSize) {
          // Bounds check
          throw RangeError(
              'Index $index is out of bounds for dim $i size $dimSize');
        }
        byteOffsetWithinView += index * strides[i];
      }

      final int finalByteOffset = offsetInBytes + byteOffsetWithinView;
      final int dataIndex = finalByteOffset ~/ data.elementSizeInBytes;

      // Use the _setDataItem helper which handles type conversion
      try {
        _setDataItem(data, dataIndex, value);
      } catch (e) {
        // Catch potential conversion errors from _setDataItem
        throw ArgumentError('Failed to set value: $e');
      }
    } else {
      // --- Slice Assignment ---
      if (value is NdArray) {
        // TODO: Implement broadcasting assignment (NdArray = NdArray slice)
        throw UnimplementedError(
            'Assigning an NdArray to a slice (broadcasting) is not yet implemented.');
      } else if (value is! num) {
        // Handle assigning other invalid types (string, bool, null, etc.)
        throw ArgumentError(
            'Value for slice assignment must be a number (int or double), got ${value.runtimeType}');
      }
      // If we reach here, value is a num (scalar assignment)

      // Get the target view based on the slices/indices
      NdArray targetView;
      try {
        // Use the existing operator[] to get the view
        targetView = this[indices];
      } catch (e) {
        throw ArgumentError('Invalid slice or index for assignment: $e');
      }

      // Assign the scalar value to all elements in the view
      // Assign the scalar value to all elements in the view
      _assignScalarToView(targetView, value);
    }
  }

  // TODO: Extend operator []= to handle slice assignment

  /// Returns an array containing the same data with a new shape.
  ///
  /// Returns a view of the original array whenever possible. The total number
  /// of elements must remain the same.
  ///
  /// One dimension may be specified as -1. In this case, the value is
  /// inferred from the length of the array and remaining dimensions.
  ///
  /// Example:
  /// ```dart
  /// var a = NdArray.arange(6); // [0, 1, 2, 3, 4, 5]
  /// var b = a.reshape([2, 3]); // [[0, 1, 2], [3, 4, 5]]
  /// var c = a.reshape([3, -1]); // [[0, 1], [2, 3], [4, 5]] (Inferred shape [3, 2])
  ///
  /// // Modifying the view modifies the original
  /// b[[0, 0]] = 99;
  /// print(a[[0]]); // Output: 99
  /// ```
  ///
  /// Throws [ArgumentError] if the new shape is incompatible with the original size.
  NdArray reshape(List<int> newShape) {
    List<int> resolvedShape =
        List.from(newShape); // Copy to modify if -1 is present
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
      // Handle scalar case where size is 1 but productOfKnownDims might be 0 if shape is like [-1]
      if (size == 0 &&
          productOfKnownDims == 1 &&
          resolvedShape.length == 1 &&
          resolvedShape[0] == -1) {
        resolvedShape[unknownDimIndex] = 0; // Reshape empty to shape [0]
      } else if (productOfKnownDims == 0) {
        // This can happen if a known dimension is 0
        if (size == 0) {
          // Calculate the unknown dimension assuming others are valid
          int tempProduct = 1;
          resolvedShape.forEach((d) {
            if (d > 0) tempProduct *= d;
          });
          if (size % tempProduct != 0) {
            // Check if size is divisible by non-zero known dims
            throw ArgumentError(
                'Cannot reshape array of size $size into shape $newShape (product is zero)');
          }
          resolvedShape[unknownDimIndex] =
              0; // If size is 0, unknown dim must be 0
        } else {
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

    // Validate the final shape size
    final int newSize = _calculateSize(resolvedShape);
    if (newSize != size) {
      throw ArgumentError(
          'Cannot reshape array of size $size into shape $resolvedShape (calculated size $newSize)');
    }
    if (resolvedShape.any((dim) => dim < 0)) {
      throw ArgumentError(
          'Negative dimensions are not allowed in the final shape: $resolvedShape');
    }

    // Calculate new strides for the view
    // Note: Reshaping might not always be possible as a view if memory layout is non-contiguous
    // (e.g., after certain transpose operations). For now, we assume it's possible.
    final List<int> newStrides =
        _calculateStrides(resolvedShape, data.elementSizeInBytes);

    // Return a new view sharing the same data and offset
    return NdArray.internalCreateView(
        data,
        resolvedShape,
        newStrides,
        dtype,
        size, // Size remains the same
        resolvedShape.length, // New ndim
        offsetInBytes // Offset remains the same for reshape view
        );
  }

  /// Converts the NdArray (potentially a view) into a nested Dart List structure.
  ///
  /// Returns a List<dynamic> representing the array's data. For multi-dimensional
  /// arrays, this will be a list of lists.
  ///
  /// Example:
  /// ```dart
  /// var a = NdArray.array([[1, 2], [3, 4]]);
  /// print(a.toList()); // Output: [[1, 2], [3, 4]]
  ///
  /// var b = NdArray.arange(4).reshape([2, 2]);
  /// print(b.toList()); // Output: [[0, 1], [2, 3]]
  /// ```
  List<dynamic> toList() {
    if (size == 0) {
      // Handle empty arrays based on shape
      // Simplification: Return empty list if any dimension is 0 or size is 0.
      // More sophisticated empty list structure generation can be added later if needed.
      return [];
    }
    if (ndim == 0) {
      // Handle scalar (0-D array)
      // Return the scalar value itself, wrapped in a list to satisfy List<dynamic>.
      return [_getDataItem(data, offsetInBytes ~/ data.elementSizeInBytes)];
    }

    // Helper function to recursively build the list structure
    dynamic buildNestedList(int dimension, List<int> currentIndices) {
      List<dynamic> currentLevelList =
          List.filled(shape[dimension], null, growable: false);
      if (dimension == ndim - 1) {
        // Base case: innermost dimension
        for (int i = 0; i < shape[dimension]; i++) {
          currentIndices[dimension] = i;
          int byteOffset = offsetInBytes;
          for (int d = 0; d < ndim; d++) {
            byteOffset += currentIndices[d] * strides[d];
          }
          currentLevelList[i] =
              _getDataItem(data, byteOffset ~/ data.elementSizeInBytes);
        }
      } else {
        // Recursive case: build list of lists
        for (int i = 0; i < shape[dimension]; i++) {
          currentIndices[dimension] = i;
          currentLevelList[i] = buildNestedList(dimension + 1, currentIndices);
        }
      }
      // Reset index for this dimension after iterating through it (important for recursive calls)
      currentIndices[dimension] = 0;
      return currentLevelList;
    }

    return buildNestedList(0, List<int>.filled(ndim, 0));
  }

  /// Performs element-wise addition with another NdArray.
  ///
  /// Both arrays must have the same shape and dtype. Broadcasting is not yet supported.
  ///
  /// Example:
  /// ```dart
  /// var a = NdArray.array([1, 2]);
  /// var b = NdArray.array([3, 4]);
  /// var c = a + b; // c will be NdArray([4, 6])
  /// ```
  /// Throws [ArgumentError] if shapes or dtypes do not match.
  NdArray operator +(NdArray other) {
    // 1. Shape Check
    if (!const ListEquality().equals(shape, other.shape)) {
      throw ArgumentError(
          'Operands could not be broadcast together with shapes $shape and ${other.shape}');
    }

    // 2. Type Check (Initial: require same dtype)
    if (dtype != other.dtype) {
      throw ArgumentError(
          'Operands must have the same dtype for addition (got $dtype and ${other.dtype})');
      // TODO: Implement type promotion later
    }

    // 3. Create Result Array
    // Map element type (int/double) from this.dtype to the required TypedData type for zeros
    Type resultTypedDataType;
    if (dtype == int) {
      resultTypedDataType = Int64List; // Default integer TypedData
    } else if (dtype == double) {
      resultTypedDataType = Float64List; // Default float TypedData
    } else {
      // This case should ideally not happen if dtype is always int or double
      throw StateError("Unexpected element dtype in operator+: $dtype");
    }
    final result = NdArray.zeros(shape,
        dtype: resultTypedDataType); // Pass the correct TypedData type

    // 4. Element-wise Addition using logical indices
    if (size == 0) return result; // Handle empty arrays

    final List<int> currentIndices = List<int>.filled(ndim, 0);
    final int elementSizeBytes =
        data.elementSizeInBytes; // Assuming same dtype, same size

    for (int i = 0; i < size; i++) {
      // Calculate byte offset for 'this' array
      int thisByteOffset = offsetInBytes;
      for (int d = 0; d < ndim; d++) {
        thisByteOffset += currentIndices[d] * strides[d];
      }
      final int thisDataIndex = thisByteOffset ~/ elementSizeBytes;

      // Calculate byte offset for 'other' array
      int otherByteOffset = other.offsetInBytes;
      for (int d = 0; d < ndim; d++) {
        otherByteOffset += currentIndices[d] * other.strides[d];
      }
      final int otherDataIndex = otherByteOffset ~/ elementSizeBytes;

      // Calculate byte offset for 'result' array (always contiguous, offset 0)
      int resultByteOffset = 0; // Result offset is always 0 initially
      for (int d = 0; d < ndim; d++) {
        resultByteOffset += currentIndices[d] * result.strides[d];
      }
      final int resultDataIndex = resultByteOffset ~/ elementSizeBytes;

      // Get values and add
      final dynamic val1 = _getDataItem(data, thisDataIndex);
      final dynamic val2 = _getDataItem(other.data, otherDataIndex);
      // Dart's dynamic + handles num + num correctly
      final dynamic sum = val1 + val2;

      // Set result
      _setDataItem(result.data, resultDataIndex, sum);

      // Increment logical indices (like an odometer)
      for (int d = ndim - 1; d >= 0; d--) {
        currentIndices[d]++;
        if (currentIndices[d] < shape[d]) {
          break; // No carry-over needed
        }
        currentIndices[d] = 0; // Reset and carry-over
      }
    }

    return result;
  }

  /// Performs element-wise subtraction with another NdArray.
  ///
  /// Both arrays must have the same shape and dtype. Broadcasting is not yet supported.
  ///
  /// Example:
  /// ```dart
  /// var a = NdArray.array([5, 7, 9]);
  /// var b = NdArray.array([1, 2, 3]);
  /// var c = a - b; // c will be NdArray([4, 5, 6])
  /// ```
  /// Throws [ArgumentError] if shapes or dtypes do not match.
  NdArray operator -(NdArray other) {
    // 1. Shape Check
    if (!const ListEquality().equals(shape, other.shape)) {
      throw ArgumentError(
          'Operands could not be broadcast together with shapes $shape and ${other.shape}');
    }

    // 2. Type Check (Initial: require same dtype)
    if (dtype != other.dtype) {
      throw ArgumentError(
          'Operands must have the same dtype for subtraction (got $dtype and ${other.dtype})');
      // TODO: Implement type promotion later
    }

    // 3. Create Result Array
    // Map element type (int/double) from this.dtype to the required TypedData type for zeros
    Type resultTypedDataType;
    if (dtype == int) {
      resultTypedDataType = Int64List; // Default integer TypedData
    } else if (dtype == double) {
      resultTypedDataType = Float64List; // Default float TypedData
    } else {
      // This case should ideally not happen if dtype is always int or double
      throw StateError("Unexpected element dtype in operator-: $dtype");
    }
    final result = NdArray.zeros(shape,
        dtype: resultTypedDataType); // Pass the correct TypedData type

    // 4. Element-wise Subtraction using logical indices
    if (size == 0) return result; // Handle empty arrays

    final List<int> currentIndices = List<int>.filled(ndim, 0);
    final int elementSizeBytes =
        data.elementSizeInBytes; // Assuming same dtype, same size

    for (int i = 0; i < size; i++) {
      // Calculate byte offset for 'this' array
      int thisByteOffset = offsetInBytes;
      for (int d = 0; d < ndim; d++) {
        thisByteOffset += currentIndices[d] * strides[d];
      }
      final int thisDataIndex = thisByteOffset ~/ elementSizeBytes;

      // Calculate byte offset for 'other' array
      int otherByteOffset = other.offsetInBytes;
      for (int d = 0; d < ndim; d++) {
        otherByteOffset += currentIndices[d] * other.strides[d];
      }
      final int otherDataIndex = otherByteOffset ~/ elementSizeBytes;

      // Calculate byte offset for 'result' array (always contiguous, offset 0)
      int resultByteOffset = 0; // Result offset is always 0 initially
      for (int d = 0; d < ndim; d++) {
        resultByteOffset += currentIndices[d] * result.strides[d];
      }
      final int resultDataIndex = resultByteOffset ~/ elementSizeBytes;

      // Get values and subtract
      final dynamic val1 = _getDataItem(data, thisDataIndex);
      final dynamic val2 = _getDataItem(other.data, otherDataIndex);
      // Dart's dynamic - handles num - num correctly
      final dynamic diff = val1 - val2; // Changed + to -

      // Set result
      _setDataItem(result.data, resultDataIndex, diff); // Use diff

      // Increment logical indices (like an odometer)
      for (int d = ndim - 1; d >= 0; d--) {
        currentIndices[d]++;
        if (currentIndices[d] < shape[d]) {
          break; // No carry-over needed
        }
        currentIndices[d] = 0; // Reset and carry-over
      }
    }

    return result;
  }

  /// Performs element-wise multiplication with another NdArray.
  ///
  /// Both arrays must have the same shape and dtype. Broadcasting is not yet supported.
  ///
  /// Example:
  /// ```dart
  /// var a = NdArray.array([1, 2, 3]);
  /// var b = NdArray.array([4, 5, 6]);
  /// var c = a * b; // c will be NdArray([4, 10, 18])
  /// ```
  /// Throws [ArgumentError] if shapes or dtypes do not match.
  NdArray operator *(NdArray other) {
    // 1. Shape Check
    if (!const ListEquality().equals(shape, other.shape)) {
      throw ArgumentError(
          'Operands could not be broadcast together with shapes $shape and ${other.shape}');
    }

    // 2. Type Check (Initial: require same dtype)
    if (dtype != other.dtype) {
      throw ArgumentError(
          'Operands must have the same dtype for multiplication (got $dtype and ${other.dtype})');
      // TODO: Implement type promotion later
    }

    // 3. Create Result Array
    // Map element type (int/double) from this.dtype to the required TypedData type for zeros
    Type resultTypedDataType;
    if (dtype == int) {
      resultTypedDataType = Int64List; // Default integer TypedData
    } else if (dtype == double) {
      resultTypedDataType = Float64List; // Default float TypedData
    } else {
      // This case should ideally not happen if dtype is always int or double
      throw StateError("Unexpected element dtype in operator*: $dtype");
    }
    final result = NdArray.zeros(shape,
        dtype: resultTypedDataType); // Pass the correct TypedData type

    // 4. Element-wise Multiplication using logical indices
    if (size == 0) return result; // Handle empty arrays

    final List<int> currentIndices = List<int>.filled(ndim, 0);
    final int elementSizeBytes =
        data.elementSizeInBytes; // Assuming same dtype, same size

    for (int i = 0; i < size; i++) {
      // Calculate byte offset for 'this' array
      int thisByteOffset = offsetInBytes;
      for (int d = 0; d < ndim; d++) {
        thisByteOffset += currentIndices[d] * strides[d];
      }
      final int thisDataIndex = thisByteOffset ~/ elementSizeBytes;

      // Calculate byte offset for 'other' array
      int otherByteOffset = other.offsetInBytes;
      for (int d = 0; d < ndim; d++) {
        otherByteOffset += currentIndices[d] * other.strides[d];
      }
      final int otherDataIndex = otherByteOffset ~/ elementSizeBytes;

      // Calculate byte offset for 'result' array (always contiguous, offset 0)
      int resultByteOffset = 0; // Result offset is always 0 initially
      for (int d = 0; d < ndim; d++) {
        resultByteOffset += currentIndices[d] * result.strides[d];
      }
      final int resultDataIndex = resultByteOffset ~/ elementSizeBytes;

      // Get values and multiply
      final dynamic val1 = _getDataItem(data, thisDataIndex);
      final dynamic val2 = _getDataItem(other.data, otherDataIndex);
      // Dart's dynamic * handles num * num correctly
      final dynamic product = val1 * val2; // Changed - to *

      // Set result
      _setDataItem(result.data, resultDataIndex, product); // Use product

      // Increment logical indices (like an odometer)
      for (int d = ndim - 1; d >= 0; d--) {
        currentIndices[d]++;
        if (currentIndices[d] < shape[d]) {
          break; // No carry-over needed
        }
        currentIndices[d] = 0; // Reset and carry-over
      }
    }

    return result;
  }

  // --- Private Helper Methods ---

  /// Calculates and returns a list of indices into the underlying data buffer
  /// corresponding to the elements of this NdArray (potentially a view).
  List<int> _getViewDataIndices() {
    if (size == 0) return [];

    final List<int> dataIndices = List<int>.filled(size, 0);
    final List<int> currentIndices = List<int>.filled(ndim, 0);
    final int elementSize = data.elementSizeInBytes;
    int dataIndexCounter = 0;

    for (int i = 0; i < size; i++) {
      // Calculate byte offset for current logical indices
      int byteOffsetWithinView = 0;
      for (int d = 0; d < ndim; d++) {
        byteOffsetWithinView += currentIndices[d] * strides[d];
      }
      final int finalByteOffset = offsetInBytes + byteOffsetWithinView;
      dataIndices[dataIndexCounter++] = finalByteOffset ~/ elementSize;

      // Increment logical indices (like an odometer)
      for (int d = ndim - 1; d >= 0; d--) {
        currentIndices[d]++;
        if (currentIndices[d] < shape[d]) {
          break; // No carry-over needed
        }
        currentIndices[d] = 0; // Reset and carry-over
      }
    }
    return dataIndices;
  }

  /// Assigns a scalar value to all elements of the target view.
  void _assignScalarToView(NdArray targetView, num scalarValue) {
    // Get the list of actual data indices for the view
    final List<int> viewDataIndices = targetView._getViewDataIndices();

    // Iterate through the data indices and set the value
    for (final int dataIndex in viewDataIndices) {
      try {
        _setDataItem(targetView.data, dataIndex, scalarValue);
      } catch (e) {
        // Provide more context in case of error
        throw ArgumentError(
            'Failed to set scalar value $scalarValue to view element at data index $dataIndex: $e');
      }
    }
  }
} // End of NdArray class
