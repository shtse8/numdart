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

  /// Sets the element at the specified multi-dimensional index to [value].
  ///
  /// [indices] must be a list of integers with length equal to [ndim].
  /// Each index must be within the bounds of the corresponding dimension.
  /// Supports negative indexing.
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
  /// Throws [TypeError] if indices are not integers.
  /// Throws [ArgumentError] if [value] cannot be converted to the array's dtype.
  void operator []=(List<int> indices, dynamic value) {
    if (indices.length != ndim) {
      throw RangeError(
          'Incorrect number of indices provided. Expected $ndim, got ${indices.length}.');
    }
    if (value is! num) {
      // Currently only support setting numeric values.
      throw ArgumentError(
          'Value must be a number (int or double), got ${value.runtimeType}');
    }

    int byteOffsetWithinView = 0;
    for (int i = 0; i < ndim; i++) {
      int index = indices[i];
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
      // Pass the actual runtime type of the data buffer to _setDataItem (No longer needed)
      _setDataItem(data, dataIndex, value);
    } catch (e) {
      // Catch potential conversion errors from _setDataItem
      throw ArgumentError('Failed to set value: $e');
    }
  }

  // TODO: Extend operator []= to handle slice assignment
} // End of NdArray class
