<!-- Version: 1.11 | Last Updated: 2025-04-05 | Updated By: Cline -->

# Active Context: NumDart (As of 2025-04-05 ~08:15 Europe/London)

## Current Focus

- **Phase 3 - Performance:** Successfully ran initial benchmarks after fixing
  critical bugs.

## Recent Changes

- **Fixed Benchmark Execution Errors:**
  - **Identified & Fixed Recursion:** Corrected infinite recursion in static
    `NdArray.zeros` and `NdArray.array` methods in `lib/src/ndarray.dart` by
    renaming the corresponding top-level functions in
    `lib/src/ndarray_creation.dart` to `_createZeros` and `_createArray` and
    updating the static methods to call the renamed functions.
  - **Fixed `createTypedData`:** Modified the helper function in
    `lib/src/ndarray_helpers.dart` to accept primitive `int` and `double` types,
    mapping them to `Int64List` and `Float64List` respectively. This resolved
    the "Unsupported dtype" error during benchmarking.
  - **Corrected Test File Calls:** Updated all test files (`test/*.dart`,
    `test/arithmetic/*.dart`, `test/elementwise/*.dart`) to use the static
    methods `NdArray.zeros(...)` and `NdArray.array(...)` instead of direct
    top-level function calls.
- **Successfully Ran Initial Benchmarks:** Executed
  `benchmark/creation_benchmark.dart` and obtained initial performance data for
  `NdArray.zeros` and `NdArray.array`.
- **Benchmarking Setup:**
  - Researched strategy for performance analysis (DevTools) and benchmarking
    (`benchmark_harness`).
  - Created `benchmark/` directory.
  - Added `benchmark_harness: ^2.3.0` to `dev_dependencies` in `pubspec.yaml`.
  - Created initial benchmark file `benchmark/creation_benchmark.dart`.
- **Fixed Aggregation Structure:** Corrected the structure in
  `lib/src/ndarray_aggregation.dart`.
- **Fixed Test File Issues:** Deleted obsolete test runner files and corrected
  imports/calls.
- (Previous changes...)

## Next Steps

1. **Expand Benchmarks:** Add benchmarks for other core operations (indexing,
   arithmetic, math functions, aggregation) in separate files within the
   `benchmark/` directory.
2. **Analyze Performance:** Use Dart DevTools to profile benchmarks and identify
   potential bottlenecks, particularly the difference between `zeros` and
   `array` creation.
3. **Continue Phase 3:** Proceed with Flutter integration planning and
   documentation writing.

## Open Questions / Considerations

- Finalize specific type promotion rules (e.g., how to handle different
  `TypedData` sizes like `Int32List` vs `Int64List` if introduced later). For
  now, assume `int` maps to `Int64List` and `double` maps to `Float64List`.
- Need robust testing for edge cases in broadcasting, especially with views and
  different strides. (Partially addressed by recent tests)
- Persistent analyzer errors related to deleted test files might require manual
  cache clearing or IDE restart by the user. (Should resolve after restart)
