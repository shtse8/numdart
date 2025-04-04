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

void _setDataItem(TypedData data, int index, num value) {
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
  final Type dtype; // Represents the element type (int or double)
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
      return NdArray._(data, shape, strides, actualDtype, 0, 1, 0);
    }
    if (shape.length > 1 && shape.contains(0)) {
      final targetType = dtype ?? Float64List;
      final data = _createTypedData(targetType, 0);
      final elementSize = _getElementSizeInBytes(data);
      final strides = _calculateStrides(shape, elementSize);
      final actualDtype = _getDType(data);
      final size = _calculateSize(shape);
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
      for (int i = 0; i < size; i++) _setDataItem(data, i, flatList[i]);
    } catch (e) {
      throw ArgumentError('Failed to create TypedData: $e');
    }
    final int elementSize = _getElementSizeInBytes(data);
    final List<int> strides = _calculateStrides(shape, elementSize);
    final Type actualDtype = _getDType(data);
    final int ndim = shape.length;
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
      for (int i = 0; i < size; i++) _setDataItem(data, i, oneValue);
    } catch (e) {
      throw ArgumentError('Failed to create TypedData: $e');
    }
    final int elementSize = _getElementSizeInBytes(data);
    final List<int> strides = _calculateStrides(shape, elementSize);
    final Type actualDtype = _getDType(data);
    final int ndim = shape.length;
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
      return NdArray._(emptyData, shape, strides, actualDtype, 0, 1, 0);
    }
    TypedData data;
    try {
      data = _createTypedData(targetType, size);
      num currentValue = actualStart;
      for (int i = 0; i < size; i++) {
        _setDataItem(data, i, currentValue);
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
    return NdArray._(data, shape, strides, actualDtype, size, ndim, 0);
  }

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
      final emptyData = _createTypedData(dtype, 0);
      final shape = [0];
      final elementSize = _getElementSizeInBytes(emptyData);
      final strides = _calculateStrides(shape, elementSize);
      final actualDtype = _getDType(emptyData);
      return NdArray._(emptyData, shape, strides, actualDtype, 0, 1, 0);
    }
    if (num == 1) {
      final data = _createTypedData(dtype, 1);
      _setDataItem(data, 0, start);
      final shape = [1];
      final elementSize = _getElementSizeInBytes(data);
      final strides = _calculateStrides(shape, elementSize);
      final actualDtype = _getDType(data);
      return NdArray._(data, shape, strides, actualDtype, 1, 1, 0);
    }

    double step;
    int div = endpoint ? (num - 1) : num;
    if (div == 0) div = 1;
    step = (stop.toDouble() - start.toDouble()) / div;

    TypedData data;
    try {
      data = _createTypedData(dtype, num);
      for (int i = 0; i < num; i++) {
        double value = start.toDouble() + i * step;
        if (endpoint && i == num - 1) {
          value = stop.toDouble();
        }
        _setDataItem(data, i, value);
      }
    } catch (e) {
      throw ArgumentError(
          'Failed to create TypedData for linspace with dtype $dtype: $e');
    }

    final shape = [num];
    final int elementSize = _getElementSizeInBytes(data);
    final List<int> strides = _calculateStrides(shape, elementSize);
    final Type actualDtype = _getDType(data);
    final int ndim = 1;
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
      return NdArray._(data, newShape, newStrides, dtype, newSize, newNdim,
          viewOffsetInBytes);
    }
  }

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
        _setDataItem(data, dataIndex, value);
      } catch (e) {
        throw ArgumentError('Failed to set value: $e');
      }
    } else {
      // --- Slice Assignment ---
      if (value is NdArray) {
        throw UnimplementedError(
            'Assigning an NdArray to a slice (broadcasting) is not yet implemented.');
      } else if (value is! num) {
        throw ArgumentError(
            'Value for slice assignment must be a number (int or double), got ${value.runtimeType}');
      }

      NdArray targetView;
      try {
        targetView = this[indices];
      } catch (e) {
        throw ArgumentError('Invalid slice or index for assignment: $e');
      }
      _assignScalarToView(targetView, value);
    }
  }

  // --- Manipulation ---

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
      if (size == 0 &&
          productOfKnownDims == 1 &&
          resolvedShape.length == 1 &&
          resolvedShape[0] == -1) {
        resolvedShape[unknownDimIndex] = 0;
      } else if (productOfKnownDims == 0) {
        if (size == 0) {
          int tempProduct = 1;
          resolvedShape.forEach((d) {
            if (d > 0) tempProduct *= d;
          });
          if (size % tempProduct != 0) {
            throw ArgumentError(
                'Cannot reshape array of size $size into shape $newShape (product is zero)');
          }
          resolvedShape[unknownDimIndex] = 0;
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

    final int newSize = _calculateSize(resolvedShape);
    if (newSize != size) {
      throw ArgumentError(
          'Cannot reshape array of size $size into shape $resolvedShape (calculated size $newSize)');
    }
    if (resolvedShape.any((dim) => dim < 0)) {
      throw ArgumentError(
          'Negative dimensions are not allowed in the final shape: $resolvedShape');
    }

    final List<int> newStrides =
        _calculateStrides(resolvedShape, data.elementSizeInBytes);

    return NdArray.internalCreateView(data, resolvedShape, newStrides, dtype,
        size, resolvedShape.length, offsetInBytes);
  }

  List<dynamic> toList() {
    if (size == 0) {
      return [];
    }
    if (ndim == 0) {
      return [_getDataItem(data, offsetInBytes ~/ data.elementSizeInBytes)];
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
          currentLevelList[i] =
              _getDataItem(data, byteOffset ~/ data.elementSizeInBytes);
        }
      } else {
        for (int i = 0; i < shape[dimension]; i++) {
          currentIndices[dimension] = i;
          currentLevelList[i] = buildNestedList(dimension + 1, currentIndices);
        }
      }
      currentIndices[dimension] = 0;
      return currentLevelList;
    }

    return buildNestedList(0, List<int>.filled(ndim, 0));
  }

  // --- Mathematical Operations ---

  NdArray operator +(dynamic other) {
    if (other is NdArray) {
      // --- Array-Array Addition ---
      if (!const ListEquality().equals(shape, other.shape)) {
        throw ArgumentError(
            'Operands could not be broadcast together with shapes $shape and ${other.shape}');
      }
      if (dtype != other.dtype) {
        throw ArgumentError(
            'Operands must have the same dtype for addition (got $dtype and ${other.dtype})');
        // TODO: Implement type promotion later
      }

      Type resultTypedDataType;
      if (dtype == int) {
        resultTypedDataType = Int64List;
      } else if (dtype == double) {
        resultTypedDataType = Float64List;
      } else {
        throw StateError("Unexpected element dtype in operator+: $dtype");
      }
      final result = NdArray.zeros(shape, dtype: resultTypedDataType);

      if (size == 0) return result;

      final List<int> currentIndices = List<int>.filled(ndim, 0);
      final int elementSizeBytes = data.elementSizeInBytes;

      for (int i = 0; i < size; i++) {
        int thisByteOffset = offsetInBytes;
        for (int d = 0; d < ndim; d++) {
          thisByteOffset += currentIndices[d] * strides[d];
        }
        final int thisDataIndex = thisByteOffset ~/ elementSizeBytes;

        int otherByteOffset = other.offsetInBytes;
        for (int d = 0; d < ndim; d++) {
          otherByteOffset += currentIndices[d] * other.strides[d];
        }
        final int otherDataIndex = otherByteOffset ~/ elementSizeBytes;

        int resultByteOffset = 0;
        for (int d = 0; d < ndim; d++) {
          resultByteOffset += currentIndices[d] * result.strides[d];
        }
        final int resultDataIndex = resultByteOffset ~/ elementSizeBytes;

        final dynamic val1 = _getDataItem(data, thisDataIndex);
        final dynamic val2 = _getDataItem(other.data, otherDataIndex);
        final dynamic sum = val1 + val2;
        _setDataItem(result.data, resultDataIndex, sum);

        for (int d = ndim - 1; d >= 0; d--) {
          currentIndices[d]++;
          if (currentIndices[d] < shape[d]) break;
          currentIndices[d] = 0;
        }
      }
      return result;
    } else if (other is num) {
      // --- Array-Scalar Addition ---
      final num scalar = other;
      Type resultTypedDataType;
      if (dtype == double || scalar is double) {
        resultTypedDataType = Float64List;
      } else if (dtype == int) {
        resultTypedDataType = Int64List;
      } else {
        throw StateError("Unexpected element dtype in operator+: $dtype");
      }
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

        final dynamic val1 = _getDataItem(data, thisDataIndex);
        final dynamic sum = val1 + scalar;
        _setDataItem(result.data, resultDataIndex, sum);

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

  NdArray operator -(dynamic other) {
    if (other is NdArray) {
      // --- Array-Array Subtraction ---
      if (!const ListEquality().equals(shape, other.shape)) {
        throw ArgumentError(
            'Operands could not be broadcast together with shapes $shape and ${other.shape}');
      }
      if (dtype != other.dtype) {
        throw ArgumentError(
            'Operands must have the same dtype for subtraction (got $dtype and ${other.dtype})');
        // TODO: Implement type promotion later
      }

      Type resultTypedDataType;
      if (dtype == int) {
        resultTypedDataType = Int64List;
      } else if (dtype == double) {
        resultTypedDataType = Float64List;
      } else {
        throw StateError("Unexpected element dtype in operator-: $dtype");
      }
      final result = NdArray.zeros(shape, dtype: resultTypedDataType);

      if (size == 0) return result;

      final List<int> currentIndices = List<int>.filled(ndim, 0);
      final int elementSizeBytes = data.elementSizeInBytes;

      for (int i = 0; i < size; i++) {
        int thisByteOffset = offsetInBytes;
        for (int d = 0; d < ndim; d++) {
          thisByteOffset += currentIndices[d] * strides[d];
        }
        final int thisDataIndex = thisByteOffset ~/ elementSizeBytes;

        int otherByteOffset = other.offsetInBytes;
        for (int d = 0; d < ndim; d++) {
          otherByteOffset += currentIndices[d] * other.strides[d];
        }
        final int otherDataIndex = otherByteOffset ~/ elementSizeBytes;

        int resultByteOffset = 0;
        for (int d = 0; d < ndim; d++) {
          resultByteOffset += currentIndices[d] * result.strides[d];
        }
        final int resultDataIndex = resultByteOffset ~/ elementSizeBytes;

        final dynamic val1 = _getDataItem(data, thisDataIndex);
        final dynamic val2 = _getDataItem(other.data, otherDataIndex);
        final dynamic diff = val1 - val2;
        _setDataItem(result.data, resultDataIndex, diff);

        for (int d = ndim - 1; d >= 0; d--) {
          currentIndices[d]++;
          if (currentIndices[d] < shape[d]) break;
          currentIndices[d] = 0;
        }
      }
      return result;
    } else if (other is num) {
      // --- Array-Scalar Subtraction ---
      final num scalar = other;
      Type resultTypedDataType;
      if (dtype == double || scalar is double) {
        resultTypedDataType = Float64List;
      } else if (dtype == int) {
        resultTypedDataType = Int64List;
      } else {
        throw StateError("Unexpected element dtype in operator-: $dtype");
      }
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

        final dynamic val1 = _getDataItem(data, thisDataIndex);
        final dynamic diff = val1 - scalar;
        _setDataItem(result.data, resultDataIndex, diff);

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

  NdArray operator *(dynamic other) {
    if (other is NdArray) {
      // --- Array-Array Multiplication ---
      if (!const ListEquality().equals(shape, other.shape)) {
        throw ArgumentError(
            'Operands could not be broadcast together with shapes $shape and ${other.shape}');
      }
      if (dtype != other.dtype) {
        throw ArgumentError(
            'Operands must have the same dtype for multiplication (got $dtype and ${other.dtype})');
        // TODO: Implement type promotion later
      }

      Type resultTypedDataType;
      if (dtype == int) {
        resultTypedDataType = Int64List;
      } else if (dtype == double) {
        resultTypedDataType = Float64List;
      } else {
        throw StateError("Unexpected element dtype in operator*: $dtype");
      }
      final result = NdArray.zeros(shape, dtype: resultTypedDataType);

      if (size == 0) return result;

      final List<int> currentIndices = List<int>.filled(ndim, 0);
      final int elementSizeBytes = data.elementSizeInBytes;

      for (int i = 0; i < size; i++) {
        int thisByteOffset = offsetInBytes;
        for (int d = 0; d < ndim; d++) {
          thisByteOffset += currentIndices[d] * strides[d];
        }
        final int thisDataIndex = thisByteOffset ~/ elementSizeBytes;

        int otherByteOffset = other.offsetInBytes;
        for (int d = 0; d < ndim; d++) {
          otherByteOffset += currentIndices[d] * other.strides[d];
        }
        final int otherDataIndex = otherByteOffset ~/ elementSizeBytes;

        int resultByteOffset = 0;
        for (int d = 0; d < ndim; d++) {
          resultByteOffset += currentIndices[d] * result.strides[d];
        }
        final int resultDataIndex = resultByteOffset ~/ elementSizeBytes;

        final dynamic val1 = _getDataItem(data, thisDataIndex);
        final dynamic val2 = _getDataItem(other.data, otherDataIndex);
        final dynamic product = val1 * val2;
        _setDataItem(result.data, resultDataIndex, product);

        for (int d = ndim - 1; d >= 0; d--) {
          currentIndices[d]++;
          if (currentIndices[d] < shape[d]) break;
          currentIndices[d] = 0;
        }
      }
      return result;
    } else if (other is num) {
      // --- Array-Scalar Multiplication ---
      final num scalar = other;
      Type resultTypedDataType;
      if (dtype == double || scalar is double) {
        resultTypedDataType = Float64List; // Promote to double
      } else if (dtype == int) {
        resultTypedDataType = Int64List; // Stays int
      } else {
        throw StateError("Unexpected element dtype in operator*: $dtype");
      }
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

        final dynamic val1 = _getDataItem(data, thisDataIndex);
        final dynamic product = val1 * scalar; // Changed operation
        _setDataItem(result.data, resultDataIndex, product);

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

  /// Performs element-wise division of this array by a scalar (num).
  ///
  /// The result is always a double-precision floating-point array (`Float64List`).
  /// Division by zero follows standard Dart double behavior:
  /// - `x / 0` where `x > 0` results in `Infinity`.
  /// - `x / 0` where `x < 0` results in `-Infinity`.
  /// - `0 / 0` results in `NaN` (Not a Number).
  ///
  /// Example:
  /// ```dart
  /// var a = NdArray.array([10, 20, 30]);
  /// var b = a / 10; // b will be NdArray([1.0, 2.0, 3.0], dtype: Float64List)
  ///
  /// var c = NdArray.array([1.0, 0.0, -1.0]);
  /// var d = c / 0; // d will be NdArray([Infinity, NaN, -Infinity], dtype: Float64List)
  /// ```
  /// Throws [ArgumentError] if [other] is not a num.
  /// Throws [UnimplementedError] if [other] is an NdArray (Array-Array division not implemented).
  NdArray operator /(dynamic other) {
    if (other is num) {
      // --- Array-Scalar Division ---
      final num scalar = other;

      // 1. Result Type is always double for division
      const Type resultTypedDataType = Float64List;

      // 2. Create Result Array
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
        final dynamic val1 = _getDataItem(data, thisDataIndex);

        // Perform division, always resulting in double, handle division by zero
        final double divisionResult = val1.toDouble() / scalar.toDouble();

        // Set result (which is always double)
        _setDataItem(result.data, resultDataIndex, divisionResult);

        // Increment logical indices
        for (int d = ndim - 1; d >= 0; d--) {
          currentIndices[d]++;
          if (currentIndices[d] < shape[d]) break;
          currentIndices[d] = 0;
        }
      }
      return result;
    } else if (other is NdArray) {
      // TODO: Implement Array-Array division (requires broadcasting potentially)
      throw UnimplementedError(
          'Array-Array division (operator /) is not yet implemented.');
    } else {
      throw ArgumentError(
          'Unsupported operand type for /: ${other.runtimeType}');
    }
  }

  // --- Private Helper Methods ---

  List<int> _getViewDataIndices() {
    if (size == 0) return [];

    final List<int> dataIndices = List<int>.filled(size, 0);
    final List<int> currentIndices = List<int>.filled(ndim, 0);
    final int elementSize = data.elementSizeInBytes;
    int dataIndexCounter = 0;

    for (int i = 0; i < size; i++) {
      int byteOffsetWithinView = 0;
      for (int d = 0; d < ndim; d++) {
        byteOffsetWithinView += currentIndices[d] * strides[d];
      }
      final int finalByteOffset = offsetInBytes + byteOffsetWithinView;
      dataIndices[dataIndexCounter++] = finalByteOffset ~/ elementSize;

      for (int d = ndim - 1; d >= 0; d--) {
        currentIndices[d]++;
        if (currentIndices[d] < shape[d]) {
          break;
        }
        currentIndices[d] = 0;
      }
    }
    return dataIndices;
  }

  void _assignScalarToView(NdArray targetView, num scalarValue) {
    final List<int> viewDataIndices = targetView._getViewDataIndices();
    for (final int dataIndex in viewDataIndices) {
      try {
        _setDataItem(targetView.data, dataIndex, scalarValue);
      } catch (e) {
        throw ArgumentError(
            'Failed to set scalar value $scalarValue to view element at data index $dataIndex: $e');
      }
    }
  }
} // End of NdArray class
