<!-- Version: 1.9 | Last Updated: 2025-04-05 | Updated By: Cline -->

# Active Context: NumDart (As of 2025-04-05 ~07:22 Europe/London)

## Current Focus

- **Phase 3 Planning:** Begin planning for Flutter integration, documentation,
  and performance profiling.

## Recent Changes

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
- **Investigated Slicing Bug:** Reviewed negative step slicing implementation
  (`Slice.adjust`, `NdArray.operator[]`, `elements` getter) and tests
  (`indexing_test.dart`). Added a 2D negative slicing test. No active bug found;
  existing logic appears correct. The previously noted bug might have been fixed
  during refactoring.
- **Added Complex Broadcasting Tests (Arithmetic):** Added tests for 3D+2D,
  multiple ones, stepped view, and scalar array broadcasting scenarios for
  `operator+`, `operator-`, `operator*`, and `operator/`. Fixed a minor issue in
  one test's expected value calculation.
- **Implemented Aggregation Functions:** Added `sum()`, `mean()`, `max()`,
  `min()` methods via an extension (`NdArrayAggregation`) in a new file
  `lib/src/ndarray_aggregation.dart`.
- **Added `elements` Getter:** Implemented an `Iterable<num> get elements`
  getter in `NdArray` (`lib/src/ndarray.dart`) to provide public access for
  iteration, used by aggregation functions.
- **Added Aggregation Tests:** Created `test/aggregation_test.dart` with tests
  for `sum()`, `mean()`, `max()`, and `min()`.
- **Fixed Test File Issues:** Deleted obsolete test runner files
  (`test/arithmetic/arithmetic_ops_test.dart`,
  `test/elementwise/elementwise_math_test.dart`) that were causing persistent
  analyzer errors after refactoring. Corrected slice and scalar creation syntax
  in `test/aggregation_test.dart`.
- **Refactored Test Creation Methods:** Updated all test files
  (`creation_test.dart`, `indexing_test.dart`, `reshape_test.dart`, and files in
  `test/arithmetic/` and `test/elementwise/`) to use static `NdArray` creation
  methods (e.g., `NdArray.array`, `NdArray.zeros`).
- **Removed Obsolete `part` Files:** Deleted all `.part.dart` files from
  `test/arithmetic/` and `test/elementwise/` directories as their content was
  merged into the main test files.
- **Verified `NdArray.log()`:** Confirmed implementation and tests for the
  natural logarithm method already exist.
- **Added Tests for `NdArray.tan()`:** Created and verified tests for the
  tangent method.
- **Reorganized Test Directory:** Moved test files into a more structured layout
  (`test/arithmetic`, `test/elementwise`).
- **Implemented `NdArray.cos()`:** Added the cosine method and corresponding
  tests.
- **Implemented `NdArray.sin()`:** Added the sine method and corresponding
  tests.
- **Implemented `NdArray.sqrt()`:** Added the square root method and
  corresponding tests.
- **Implemented `NdArray.exp()`:** Added the exponential method and
  corresponding tests.
- **Verified Type Promotion:** Confirmed that existing arithmetic operators
  (`+`, `-`, `*`, `/`) correctly handle type promotion between `int` and
  `double` arrays through added tests. No code changes were needed for the
  operators themselves.
- **Refactored `dtype` Handling:** Modified `NdArray` to store primitive `dtype`
  (`int` or `double`) instead of `TypedData` type. Updated all factory
  constructors and relevant tests (`creation_test.dart`,
  `math_operations_test.dart`).
- **Fixed `dtype` Bug in Scalar Ops:** Corrected a bug where scalar operations
  on empty `double` arrays incorrectly resulted in an `int` `dtype`. Updated
  relevant tests.
- **Verified Slice Assignment:** Confirmed that assigning an `NdArray` to a
  slice (including broadcasting) works correctly via existing tests in
  `indexing_test.dart`. Added a test case for assigning a scalar `NdArray`.
- **Updated `README.md`:** Added a more engaging introduction and a progress
  table.
- (Previous) Implemented broadcasting for arithmetic operators (`+`, `-`, `*`,
  `/`), array-array division, scalar ops, `toList()`.

## Next Steps

1. **Phase 3:** Begin Flutter integration, documentation, and performance
   profiling.

## Open Questions / Considerations

- Finalize specific type promotion rules (e.g., how to handle different
  `TypedData` sizes like `Int32List` vs `Int64List` if introduced later). For
  now, assume `int` maps to `Int64List` and `double` maps to `Float64List`.
- Need robust testing for edge cases in broadcasting, especially with views and
  different strides. (Partially addressed by recent tests)
- Persistent analyzer errors related to deleted test files and extension methods
  might require manual cache clearing or IDE restart by the user.
