# System Patterns: NumDart

## 1. Core Architecture

- **Central `NdArray` Class:** A single class (`lib/src/ndarray.dart`)
  encapsulates the multi-dimensional array data and its properties (shape,
  strides, dtype, size, ndim, offset).
- **Top-Level Helper Functions:** Internal logic like calculating strides, size,
  inferring shape/dtype, and data access/manipulation are implemented as
  top-level functions (prefixed with `_`) within `ndarray.dart` for clarity and
  potential reuse.
- **Factory Constructors:** Array creation logic (`array`, `zeros`, `ones`,
  `arange`, `linspace`) is implemented using factory constructors within the
  `NdArray` class.
- **View-Based Operations:** Slicing (`operator []`) and reshaping (`reshape`)
  primarily return views that share the original `TypedData` buffer, modifying
  `shape`, `strides`, and `offsetInBytes` accordingly. This prioritizes memory
  efficiency over copying.
- **Internal View Creation:** A static method `NdArray.internalCreateView` is
  provided for controlled creation of views, primarily intended for internal use
  or testing extensions.

## 2. Data Storage

- **`dart:typed_data`:** The core data buffer (`NdArray.data`) uses Dart's
  `TypedData` (e.g., `Float64List`, `Int64List`) for efficient, contiguous
  memory storage and potential interoperability with native code (FFI).
- **Type Handling:** The specific `TypedData` type determines the array's
  element type. Helper functions (`_getDType`, `_setDataItem`, `_getDataItem`)
  manage type checking and basic conversions.

## 3. Indexing and Slicing

- **`operator []` Overload:** Handles both integer indexing (returning an
  element) and slicing (returning an `NdArray` view) based on the type of
  elements in the input `List<Object>`.
- **`Slice` Class:** A dedicated class (`lib/src/slice.dart`) represents slice
  operations (`start`, `stop`, `step`) and includes logic (`adjust`) to
  calculate adjusted indices and slice length based on dimension size.
- **Offset and Strides:** Views are implemented by calculating a new
  `offsetInBytes` into the shared `data` buffer and new `strides` based on the
  slicing parameters.

## 4. Key Design Decisions

- **Immutability of Core Properties:** `NdArray` properties like `shape`,
  `strides`, `data`, `dtype`, `offsetInBytes` are `final` after creation.
  Operations that change these (like slicing or reshaping) return new `NdArray`
  instances (views).
- **View vs. Copy:** Prioritize returning views for slicing and reshaping for
  performance and memory, aligning with NumPy's common behavior. Explicit copy
  methods will be needed later.
- **Error Handling:** Use standard Dart exceptions (`ArgumentError`,
  `RangeError`, `StateError`) for invalid operations or inputs.

## 5. Future Considerations

- **Broadcasting Implementation:** Will likely require dedicated logic,
  potentially involving iterators or helper functions to manage element-wise
  operations between arrays of different shapes.
- **Mathematical Operations:** Operator overloading (`+`, `-`, etc.) and
  dedicated math functions will be added, likely operating element-wise
  initially.
- **FFI Integration:** If performance bottlenecks arise, FFI calls to optimized
  C/C++ libraries (like BLAS/LAPACK) could be integrated, potentially requiring
  changes to data access or specific function implementations.
