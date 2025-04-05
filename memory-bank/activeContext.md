# Active Context: NumDart (As of 2025-04-05 ~05:04 Europe/London)

## Current Focus

- **Phase 2 Math Functions:** Implement the next common element-wise function:
  `tan`.

## Recent Changes

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

1. **Add More Math Functions:** Implement common element-wise functions (e.g.,
   `tan`, `log`). (`sqrt`, `exp`, `sin`, `cos` done).
2. **Refine Broadcasting:** Add more complex broadcasting tests.
3. **Address Slicing Bug:** Investigate and fix the known bug with negative
   steps in slicing.
4. **Scalar Handling:** Review and ensure consistent handling for 0-D (scalar)
   arrays.

## Open Questions / Considerations

- Finalize specific type promotion rules (e.g., how to handle different
  `TypedData` sizes like `Int32List` vs `Int64List` if introduced later). For
  now, assume `int` maps to `Int64List` and `double` maps to `Float64List`.
- Need robust testing for edge cases in broadcasting, especially with views and
  different strides. (Still relevant)
