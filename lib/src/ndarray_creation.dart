part of 'ndarray.dart';

// --- Factory Constructors (Now Top-Level Functions within the library scope) ---

NdArray array(List list, {Type? dtype}) {
  final List<int> shape = inferShape(list);
  if (shape.length == 1 && shape[0] == 0) {
    final targetType = dtype ?? Float64List;
    final data = createTypedData(targetType, 0);
    final elementSize = getElementSizeInBytes(data);
    final strides = calculateStrides(shape, elementSize);
    // Pass the primitive dtype to the constructor
    return NdArray._(data, shape, strides, getDType(data), 0, 1, 0);
  }
  if (shape.length > 1 && shape.contains(0)) {
    final targetType = dtype ?? Float64List;
    final data = createTypedData(targetType, 0);
    final elementSize = getElementSizeInBytes(data);
    final strides = calculateStrides(shape, elementSize);
    // Pass the primitive dtype to the constructor
    final size = calculateSize(shape);
    return NdArray._(
        data, shape, strides, getDType(data), size, shape.length, 0);
  }
  Type targetType = dtype ?? inferDataType(list) ?? Float64List;
  List<num> flatList = flatten<num>(list);
  final int size = calculateSize(shape);
  if (size != flatList.length) {
    throw StateError(
        'Shape size $size != flattened list length ${flatList.length}.');
  }
  TypedData data;
  try {
    data = createTypedData(targetType, size);
    for (int i = 0; i < size; i++) setDataItem(data, i, flatList[i]);
  } catch (e) {
    throw ArgumentError('Failed to create TypedData: $e');
  }
  final int elementSize = getElementSizeInBytes(data);
  final List<int> strides = calculateStrides(shape, elementSize);
  // Pass the primitive dtype to the constructor
  final int ndim = shape.length;
  return NdArray._(data, shape, strides, getDType(data), size, ndim, 0);
}

NdArray zeros(List<int> shape, {Type dtype = Float64List}) {
  if (shape.any((dim) => dim < 0))
    throw ArgumentError('Negative dimensions not allowed.');
  final int size = calculateSize(shape);
  TypedData data;
  try {
    data = createTypedData(dtype, size);
  } catch (e) {
    throw ArgumentError('Failed to create TypedData: $e');
  }
  final int elementSize = getElementSizeInBytes(data);
  final List<int> strides = calculateStrides(shape, elementSize);
  // Pass the primitive dtype to the constructor
  final int ndim = shape.length;
  return NdArray._(data, shape, strides, getDType(data), size, ndim, 0);
}

NdArray ones(List<int> shape, {Type dtype = Float64List}) {
  if (shape.any((dim) => dim < 0))
    throw ArgumentError('Negative dimensions not allowed.');
  final int size = calculateSize(shape);
  TypedData data;
  try {
    data = createTypedData(dtype, size);
    num oneValue = (dtype == Float32List || dtype == Float64List) ? 1.0 : 1;
    for (int i = 0; i < size; i++) setDataItem(data, i, oneValue);
  } catch (e) {
    throw ArgumentError('Failed to create TypedData: $e');
  }
  final int elementSize = getElementSizeInBytes(data);
  final List<int> strides = calculateStrides(shape, elementSize);
  // Pass the primitive dtype to the constructor
  final int ndim = shape.length;
  return NdArray._(data, shape, strides, getDType(data), size, ndim, 0);
}

NdArray arange(num startOrStop, {num? stop, num step = 1, Type? dtype}) {
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
    size = math.max(
        0,
        ((actualStop.toDouble() - actualStart.toDouble()) / step.toDouble())
            .ceil());
  else if (step < 0 && actualStop < actualStart)
    size = math.max(
        0,
        ((actualStop.toDouble() - actualStart.toDouble()) / step.toDouble())
            .ceil());
  if (size <= 0) {
    final emptyData = createTypedData(targetType, 0);
    final shape = [0];
    final elementSize = getElementSizeInBytes(emptyData);
    final strides = calculateStrides(shape, elementSize);
    // Pass the primitive dtype to the constructor
    return NdArray._(emptyData, shape, strides, getDType(emptyData), 0, 1, 0);
  }
  TypedData data;
  try {
    data = createTypedData(targetType, size);
    num currentValue = actualStart;
    for (int i = 0; i < size; i++) {
      setDataItem(data, i, currentValue);
      currentValue = currentValue.toDouble() + step.toDouble();
    }
  } catch (e) {
    throw ArgumentError('Failed to create TypedData: $e');
  }
  final shape = [size];
  final int elementSize = getElementSizeInBytes(data);
  final List<int> strides = calculateStrides(shape, elementSize);
  // Pass the primitive dtype to the constructor
  final int ndim = 1;
  return NdArray._(data, shape, strides, getDType(data), size, ndim, 0);
}

NdArray linspace(
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
    final emptyData = createTypedData(dtype, 0);
    final shape = [0];
    final elementSize = getElementSizeInBytes(emptyData);
    final strides = calculateStrides(shape, elementSize);
    // Pass the primitive dtype to the constructor
    return NdArray._(emptyData, shape, strides, getDType(emptyData), 0, 1, 0);
  }
  if (num == 1) {
    final data = createTypedData(dtype, 1);
    setDataItem(data, 0, start);
    final shape = [1];
    final elementSize = getElementSizeInBytes(data);
    final strides = calculateStrides(shape, elementSize);
    // Pass the primitive dtype to the constructor
    return NdArray._(data, shape, strides, getDType(data), 1, 1, 0);
  }

  double step;
  int div = endpoint ? (num - 1) : num;
  if (div == 0) div = 1;
  step = (stop.toDouble() - start.toDouble()) / div;

  TypedData data;
  try {
    data = createTypedData(dtype, num);
    for (int i = 0; i < num; i++) {
      double value = start.toDouble() + i * step;
      if (endpoint && i == num - 1) {
        value = stop.toDouble();
      }
      setDataItem(data, i, value);
    }
  } catch (e) {
    throw ArgumentError(
        'Failed to create TypedData for linspace with dtype $dtype: $e');
  }

  final shape = [num];
  final int elementSize = getElementSizeInBytes(data);
  final List<int> strides = calculateStrides(shape, elementSize);
  // Pass the primitive dtype to the constructor
  final int ndim = 1;
  return NdArray._(data, shape, strides, getDType(data), num, ndim, 0);
}
