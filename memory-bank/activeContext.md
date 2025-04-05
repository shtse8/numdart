<!-- Version: 1.10 | Last Updated: 2025-04-05 | Updated By: Cline -->

# Active Context: NumDart (As of 2025-04-05 ~07:43 Europe/London)

## Current Focus

- **Phase 3 - Performance:** Setting up framework for performance analysis and
  benchmarking.

## Recent Changes

- **Benchmarking Setup:**
  - Researched strategy for performance analysis (DevTools) and benchmarking
    (`benchmark_harness`).
  - Created `benchmark/` directory.
  - Added `benchmark_harness: ^2.3.0` to `dev_dependencies` in `pubspec.yaml`.
  - Created initial benchmark file `benchmark/creation_benchmark.dart` for
    `NdArray.zeros` and `NdArray.array`.
- **Fixed Aggregation Structure:** Corrected the structure in
  `lib/src/ndarray_aggregation.dart` by moving `max()` and `min()` methods out
  of the `mean()` method body to the top level of the `NdArrayAggregation`
  extension.
- **Fixed Test File Issues:**
  - Deleted obsolete test runner files
    (`test/arithmetic/arithmetic_ops_test.dart`,
    `test/elementwise/elementwise_math_test.dart`).
  - Added missing import for `ndarray_aggregation.dart` in
    `test/aggregation_test.dart` (implicitly fixed by correcting the aggregation
    file structure).
- **Deferred `broadcast_to`:** Decided to defer implementation of an explicit
  `broadcast_to` function to a future stage, as implicit broadcasting covers
  current needs.
- **Improved Scalar Handling:**
  - Added `NdArray.scalar()` factory constructor for creating 0-D arrays.
  - Modified `NdArray.toList()` to return the scalar value directly for 0-D
    arrays (aligning with NumPy).
  - Updated tests (`creation_test.dart`, `arithmetic/*_test.dart`,
    `aggregation_test.dart`) to use `NdArray.scalar()` and verify new `toList()`
    behavior.
- **Investigated Slicing Bug:** Reviewed negative step slicing implementation.
  No active bug found; existing logic appears correct.
- **Added Complex Broadcasting Tests (Arithmetic):** Added tests for 3D+2D,
  multiple ones, stepped view, and scalar array broadcasting scenarios for `+`,
  `-`, `*`, `/`.
- **Implemented Aggregation Functions:** Added `sum()`, `mean()`, `max()`,
  `min()` methods via an extension (`NdArrayAggregation`).
- **Added `elements` Getter:** Implemented an `Iterable<num> get elements`
  getter in `NdArray`.
- **Added Aggregation Tests:** Created `test/aggregation_test.dart`.
- **Refactored Test Creation Methods:** Updated all test files to use static
  `NdArray` creation methods.
- **Removed Obsolete `part` Files:** Deleted all `.part.dart` files from test
  subdirectories.
- (Previous changes...)

## Next Steps

1. **Run Initial Benchmarks:** Execute `benchmark/creation_benchmark.dart` to
   get baseline performance data for array creation.
2. **Expand Benchmarks:** Add benchmarks for other core operations (indexing,
   arithmetic, math functions, aggregation).
3. **Analyze Performance:** Use Dart DevTools to profile benchmarks and identify
   potential bottlenecks.
4. **Continue Phase 3:** Proceed with Flutter integration planning and
   documentation writing.

## Open Questions / Considerations

- Finalize specific type promotion rules (e.g., how to handle different
  `TypedData` sizes like `Int32List` vs `Int64List` if introduced later). For
  now, assume `int` maps to `Int64List` and `double` maps to `Float64List`.
- Need robust testing for edge cases in broadcasting, especially with views and
  different strides. (Partially addressed by recent tests)
- Persistent analyzer errors related to deleted test files might require manual
  cache clearing or IDE restart by the user. (Should resolve after restart)
