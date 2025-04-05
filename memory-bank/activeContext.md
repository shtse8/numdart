# Active Context: NumDart (As of 2025-04-05 ~03:50 Europe/London)

## Current Focus

- **Phase 2 Type Promotion:** Defining rules and starting implementation for
  operations between arrays of different numeric `dtype`s (e.g., `int` array +
  `double` array). This is the immediate next task.

## Recent Changes

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

1. **Implement Type Promotion:**
   - Modify arithmetic operators (`+`, `-`, `*`, `/`) to handle mixed `dtype`
     inputs according to promotion rules (e.g., `int + double -> double`).
   - Ensure the result `NdArray` has the correctly promoted `dtype` and
     `TypedData`.
   - Add comprehensive unit tests for mixed-type operations.
2. **Add More Math Functions:** Implement common element-wise functions (e.g.,
   `sqrt`, `exp`, `sin`).
3. **Refine Broadcasting:** Add more complex broadcasting tests.
4. **Address Slicing Bug:** Investigate and fix the known bug with negative
   steps in slicing.

## Open Questions / Considerations

- Finalize specific type promotion rules (e.g., how to handle different
  `TypedData` sizes like `Int32List` vs `Int64List` if introduced later). For
  now, assume `int` maps to `Int64List` and `double` maps to `Float64List`.
- Need robust testing for edge cases in broadcasting, especially with views and
  different strides. (Still relevant)
