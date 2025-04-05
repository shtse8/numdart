# NumDart: NumPy Power for Dart & Flutter! 🚀

Tired of cumbersome numerical computations in Dart? Wish you had the power and
elegance of Python's NumPy in your Flutter apps or Dart backends? **NumDart is
the answer!**

NumDart brings a familiar, high-performance numerical computing experience to
the Dart ecosystem. Inspired by NumPy, it provides:

- **Intuitive API:** Leverage your existing NumPy knowledge.
- **High Performance:** Optimized for speed using `dart:typed_data`.
- **Flutter Focused:** Designed with Flutter integration in mind.
- **Foundation for Science:** Enables advanced data analysis, machine learning,
  and scientific computing in Dart.

## Project Status & Roadmap

| Feature Phase                  | Status         | Key Features                                                                                                                                                                                                                                                                     |
| :----------------------------- | :------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Phase 1: Foundation**        | ✅ Complete    | Core `NdArray` (TypedData, shape, strides, dtype), Creation (`array`, `zeros`, `ones`, `arange`, `linspace`), Basic Indexing/Slicing/Assignment, `reshape` (view), `toList()`, `elements` getter.                                                                                |
| **Phase 2: Math/Broadcasting** | ✅ Complete    | Element-wise Ops (`+`, `-`, `*`, `/`), Scalar Ops, Broadcasting, Slice Assignment (`NdArray` value), Type Promotion, Math funcs (`sqrt`, `exp`, `sin`, `cos`, `tan`, `log`), Aggregation (`sum`, `mean`, `max`, `min`), `scalar()` constructor, Improved `toList()` for scalars. |
| **Phase 3: Flutter & Opt.**    | ⏳ In Progress | Packaging, Docs & Examples, Performance Profiling/Optimization, Potential FFI                                                                                                                                                                                                    |
| **Future Stages**              | 📅 Planned     | Linear Algebra (`linalg`), Random Numbers (`random`), Advanced Indexing, `broadcast_to`, etc.                                                                                                                                                                                    |

_(Detailed plan and progress tracking in the `memory-bank` directory)._

## Implemented Features (Highlights)

- **Core `NdArray`:** Multi-dimensional array structure using `dart:typed_data`.
  Includes `shape`, `strides`, `dtype`, `size`, `ndim`, `offsetInBytes`,
  `elements` getter.
- **Creation Functions:** `array()`, `zeros()`, `ones()`, `arange()`,
  `linspace()`, `scalar()`.
- **Indexing & Slicing:** Access/assign elements (`[[i, j]]`), create views
  (`[[Slice.all, 0]]`). Supports negative indexing and steps.
- **Assignment:** Set element values (`array[[0, 1]] = 5`), assign scalars or
  broadcast-compatible NdArrays to slices (`array[[Slice(0,2)]] = other_array`).
- **Reshape:** Change array shape using `reshape()` (returns a view).
- **Arithmetic Ops:** Element-wise `+`, `-`, `*`, `/` with scalar and array
  operands, supporting broadcasting and type promotion.
- **Math Functions:** Element-wise `sqrt()`, `exp()`, `sin()`, `cos()`, `tan()`,
  `log()`.
- **Aggregation Functions:** `sum()`, `mean()`, `max()`, `min()`.
- **Conversion:** `toList()` converts NdArrays to nested Lists (returns scalar
  value for 0-D arrays).

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  numdart: ^0.1.0 # Replace with the actual latest version when published
```

Then run `dart pub get` or `flutter pub get`.

## Usage Example

```dart
import 'package:numdart/numdart.dart';
import 'dart:math' as math;

void main() {
  // Create arrays
  var a = NdArray.array([[1, 2], [3, 4]]);
  var b = NdArray.arange(4);
  var c = NdArray.linspace(0, math.pi, num: 5);
  var d = NdArray.ones([2, 2]);
  var s = NdArray.scalar(10); // Create a scalar array

  print('Scalar s: ${s.toList()}'); // Output: 10

  // Indexing
  print('a[0, 1]: ${a[[0, 1]]}'); // Output: 2
  print('Scalar s value: ${s[[]]}'); // Output: 10

  // Slicing
  var row0 = a[[0, Slice.all]];
  print('Row 0 of a: ${row0.toList()}'); // Output: [1, 2]

  // Assignment
  b[[1]] = 99;
  print('Modified b: ${b.toList()}'); // Output: [0, 99, 2, 3]
  a[[Slice(0,1), Slice.all]] = NdArray.array([10, 20]); // Assign to slice
  print('Modified a: ${a.toList()}'); // Output: [[10, 20], [3, 4]]

  // Reshape
  var e = NdArray.arange(6).reshape([2, 3]);
  print('e shape: ${e.shape}'); // Output: [2, 3]

  // Basic Math & Broadcasting
  var f = NdArray.array([[1, 1], [1, 1]]);
  var g = NdArray.array([10, 20]);
  var sum = f + g; // Broadcasting
  print('f + g: ${sum.toList()}'); // Output: [[11, 21], [11, 21]]
  var product = a * 2;
  print('a * 2: ${product.toList()}'); // Output: [[20, 40], [6, 8]]
  var scalarSum = product + s; // Broadcast scalar array
  print('product + s: ${scalarSum.toList()}'); // Output: [[30, 50], [16, 18]]

  // Math Functions
  print('sqrt(a): ${a.sqrt().toList()}');
  print('sin(c): ${c.sin().toList()}');

  // Aggregation Functions
  print('Sum of a: ${a.sum()}'); // Output: 37
  print('Mean of b: ${b.mean()}'); // Output: 26.0
  print('Max of e: ${e.max()}'); // Output: 5
  print('Min of c: ${c.min()}'); // Output: 0.0
}
```
