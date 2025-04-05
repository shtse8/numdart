<!-- Version: 1.4 | Last Updated: 2025-04-05 | Updated By: Cline -->

# Active Context: NumDart (As of 2025-04-05 ~07:05 Europe/London)

## Current Focus

- **Phase 2 Broadcasting:** Refine broadcasting implementation and add more
  complex tests.

## Recent Changes

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

1. **Refine Broadcasting:** Add more complex broadcasting tests.
2. **Address Slicing Bug:** Investigate and fix the known bug with negative
   steps in slicing.
3. **Scalar Handling:** Review and ensure consistent handling for 0-D (scalar)
   arrays.
4. **Add More Math Functions:** Implement aggregation functions (e.g., `sum`,
   `mean`, `max`, `min`). (`sqrt`, `exp`, `sin`, `cos`, `tan`, `log` done).

## Open Questions / Considerations

- Finalize specific type promotion rules (e.g., how to handle different
  `TypedData` sizes like `Int32List` vs `Int64List` if introduced later). For
  now, assume `int` maps to `Int64List` and `double` maps to `Float64List`.
- Need robust testing for edge cases in broadcasting, especially with views and
  different strides. (Still relevant)
