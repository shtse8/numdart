part of 'ndarray.dart';

// --- Top-Level Helper Functions (originally private in ndarray.dart) ---

List<int> calculateStrides(List<int> shape, int elementSizeInBytes) {
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

int calculateSize(List<int> shape) {
  if (shape.isEmpty) return 1; // Scalar size
  if (shape.contains(0)) return 0;
  return shape.reduce((value, element) => value * element);
}

/// Calculates the resulting shape after broadcasting two shapes.
/// Throws ArgumentError if the shapes are not broadcastable.
List<int> calculateBroadcastShape(List<int> shapeA, List<int> shapeB) {
  final int ndimA = shapeA.length;
  final int ndimB = shapeB.length;
  final int ndimMax = math.max(ndimA, ndimB);
  final List<int> resultShape = List<int>.filled(ndimMax, 0);

  for (int i = 0; i < ndimMax; i++) {
    // Get dimensions, padding with 1 if necessary
    final int dimA = (i < ndimA) ? shapeA[ndimA - 1 - i] : 1;
    final int dimB = (i < ndimB) ? shapeB[ndimB - 1 - i] : 1;

    if (dimA == dimB) {
      resultShape[ndimMax - 1 - i] = dimA;
    } else if (dimA == 1) {
      resultShape[ndimMax - 1 - i] = dimB;
    } else if (dimB == 1) {
      resultShape[ndimMax - 1 - i] = dimA;
    } else {
      throw ArgumentError(
          'Operands could not be broadcast together with shapes $shapeA and $shapeB');
    }
  }
  return resultShape;
}

/// Determines the resulting primitive data type (int or double) for an operation.
/// Division always results in double.
/// Int + Float -> double. Int + Int -> int. Float + Float -> double.
Type getResultDataType(Type dtypeA, Type dtypeB, {bool isDivision = false}) {
  if (isDivision) {
    return double; // Division always results in double
  }

  // Check if types are primitive int/double
  final bool isAPrimitiveFloat = (dtypeA == double);
  final bool isBPrimitiveFloat = (dtypeB == double);

  // Check if types are TypedData float types (fallback for safety, should ideally use primitive types)
  final bool isATypedDataFloat =
      (dtypeA == Float32List || dtypeA == Float64List);
  final bool isBTypedDataFloat =
      (dtypeB == Float32List || dtypeB == Float64List);

  if (isAPrimitiveFloat ||
      isBPrimitiveFloat ||
      isATypedDataFloat ||
      isBTypedDataFloat) {
    // If either operand is float (primitive or TypedData), the result is double
    return double;
  } else {
    // Both operands are int types (primitive or TypedData), result is int
    return int;
  }
}

Type getDType(TypedData data) {
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

int getElementSizeInBytes(TypedData data) {
  return data.elementSizeInBytes;
}

List<int> inferShape(List list) {
  if (list.isEmpty) return [0];
  final firstElement = list[0];
  if (firstElement is List) {
    final subShape = inferShape(firstElement);
    for (int i = 0; i < list.length; i++) {
      if (list[i] is! List)
        throw ArgumentError(
            'Inconsistent structure: element at index $i is not a List.');
      final currentSubShape = inferShape(list[i] as List);
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

List<T> flatten<T extends num>(List nestedList) {
  final List<T> flatList = [];
  for (final element in nestedList) {
    if (element is List) {
      flatList.addAll(flatten<T>(element));
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

Type? inferDataType(List list) {
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

TypedData createTypedData(Type type, int length) {
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

void setDataItem(TypedData data, int index, num value) {
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

dynamic getDataItem(TypedData data, int index) {
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
