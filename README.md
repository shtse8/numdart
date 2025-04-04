# NumDart

A NumPy-like package for Dart, focusing on performance and API compatibility,
primarily targeting Flutter.

## Current Status (Phase 1 - Foundation In Progress)

This project aims to bring the power and flexibility of NumPy to the Dart
ecosystem.

**Implemented Features:**

- **Core `NdArray`:** Multi-dimensional array structure using `dart:typed_data`.
- **Creation Functions:**
  - `NdArray.array()`: Create from nested Lists.
  - `NdArray.zeros()`: Create array filled with zeros.
  - `NdArray.ones()`: Create array filled with ones.
  - `NdArray.arange()`: Create array with evenly spaced values (like Python's
    range).
  - `NdArray.linspace()`: Create array with evenly spaced values over an
    interval.
- **Basic Indexing:** Access elements using `List<int>` (e.g., `array[[0, 1]]`).
  Supports negative indexing.
- **Basic Slicing:** Create views using `List<Object>` containing `int` and
  `Slice` (e.g., `array[[0, Slice.all]]`). Supports negative indexing and steps.
  (Note: Known bug with negative step slicing).
- **Basic Assignment:** Set element values using `List<int>` (e.g.,
  `array[[0, 1]] = 5`).
- **Reshape:** Change array shape using `reshape()` (returns a view).

**Next Steps:**

- Implement slice assignment (`operator []=`).
- Implement element-wise mathematical operations.
- Implement element-wise mathematical operations.
- Address known slicing bug (see `memory-bank/progress.md`).

## Installation

```yaml
dependencies:
  numdart: ^0.0.1 # Or latest version
```

## Usage

```dart
import 'package:numdart/numdart.dart';

void main() {
  // Create arrays
  var a = NdArray.array([[1, 2], [3, 4]]);
  var b = NdArray.arange(4);
  var c = NdArray.linspace(0, 1, num: 5);

  // Indexing
  print(a[[0, 1]]); // Output: 2

  // Slicing
  var row0 = a[[0, Slice.all]];
  print(row0); // Output: NdArray view representing [1, 2] (Need a proper toString method later)

  // Assignment
  b[[1]] = 99;
  print(b); // Output: NdArray representing [0, 99, 2, 3]

  // Reshape
  var d = NdArray.arange(6).reshape([2, 3]);
  print(d.shape); // Output: [2, 3]
  // Modifying reshaped view affects original
  // d[[0, 0]] = 100; // Example assignment on view 'd'
  // print(NdArray.arange(6)[[0]]); // Would output 100 if above line uncommented
}
```

_(Project plan and detailed progress can be found in the `memory-bank`
directory)._
