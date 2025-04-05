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

| Feature Phase                  | Status         | Key Features                                                                                                                                               |
| :----------------------------- | :------------- | :--------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Phase 1: Foundation**        | ✅ Complete    | Core `NdArray` (TypedData, shape, strides), Creation (`array`, `zeros`, `ones`, `arange`, `linspace`), Basic Indexing/Slicing/Assignment, `reshape` (view) |
| **Phase 2: Math/Broadcasting** | ⏳ In Progress | Element-wise Ops (`+`, `-`, `*`, `/`), Scalar Ops, Basic Broadcasting, Slice Assignment (`NdArray` value)                                                  |
| **Phase 3: Flutter & Opt.**    | 📅 Planned     | Packaging, Docs & Examples, Performance Profiling/Optimization, Potential FFI                                                                              |
| **Future Stages**              | 📅 Planned     | Linear Algebra (`linalg`), Random Numbers (`random`), Advanced Indexing, etc.                                                                              |

_(Detailed plan and progress tracking in the `memory-bank` directory)._

## Implemented Features (Highlights)

- **Core `NdArray`:** Multi-dimensional array structure using `dart:typed_data`.
- **Creation Functions:** `array()`, `zeros()`, `ones()`, `arange()`,
  `linspace()`.
- **Indexing & Slicing:** Access/assign elements (`[[i, j]]`), create views
  (`[[Slice.all, 0]]`). Supports negative indexing and steps. _(Note: Known bug
  with negative step slicing)_.
- **Assignment:** Set element values (`array[[0, 1]] = 5`), assign scalars or
  broadcast-compatible NdArrays to slices (`array[[Slice(0,2)]] = other_array`).
- **Reshape:** Change array shape using `reshape()` (returns a view).
- **Basic Math:** Element-wise `+`, `-`, `*`, `/` with scalar and array
  operands.
- **Broadcasting:** Basic NumPy-style broadcasting rules implemented for
  arithmetic operations.

## Next Steps

- Implement **Type Promotion** for operations between different numeric dtypes
  (e.g., `int` array + `double` array).
- Add more **Mathematical Functions** (e.g., `sqrt`, `exp`, `sin`, aggregation
  functions like `sum`, `mean`).
- Refine **Broadcasting** logic and add more tests.
- Address known **Slicing Bug** (negative steps).

## Installation

Add this to your `pubspec.yaml`:

```yaml
dependencies:
  numdart: ^0.0.1 # Replace with the actual latest version when published
```

Then run `dart pub get` or `flutter pub get`.

## Usage Example

```dart
import 'package:numdart/numdart.dart';

void main() {
  // Create arrays
  var a = NdArray.array([[1, 2], [3, 4]]);
  var b = NdArray.arange(4);
  var c = NdArray.linspace(0, 1, num: 5);
  var d = NdArray.ones([2, 2]);

  // Indexing
  print('a[0, 1]: ${a[[0, 1]]}'); // Output: 2

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
}
```
