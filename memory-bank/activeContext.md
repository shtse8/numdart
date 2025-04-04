# Active Context: NumDart (As of 2025-04-05 ~00:30 Europe/London)

## Current Focus

- **Phase 2 Math Ops &amp; Broadcasting:** Implemented basic broadcasting
  mechanism for element-wise arithmetic operators (`+`, `-`, `*`, `/`).
- Implemented array-array division (`operator/`). Result is always `double`
  (`Float64List`), handles division by zero.
- Added unit tests for array-array division and basic broadcasting scenarios.
- All tests are currently passing.

## Recent Changes

- Added `_calculateBroadcastShape` helper function to `lib/src/ndarray.dart`.
- Modified `operator+`, `operator-`, `operator*`, `operator/` in
  `lib/src/ndarray.dart` to support broadcasting between compatible shapes.
- Added array-array division tests to `test/src/math_operations_test.dart`.
- Added broadcasting tests for arithmetic operators to
  `test/src/math_operations_test.dart`.
- (Previous) Implemented scalar division (`operator/`). Implemented scalar
  multiplication (`operator*`), scalar addition/subtraction (`operator+`,
  `operator-`), same-shape array-array ops (`+`, `-`, `*`), `toList()`. Fixed
  test structure issues.

## Next Steps

- **Implement NdArray Slice Assignment:** Implement assigning an `NdArray` to a
  slice (e.g., `a[[Slice(0, 2)]] = b`). This will heavily rely on the newly
  implemented broadcasting logic.
- **Implement Type Promotion:** Define rules and implement logic for array-array
  operations between different numeric dtypes (e.g., `int` array + `double`
  array).
- **Refine Broadcasting:** Add more complex broadcasting tests, potentially
  involving views and more varied dimension combinations.
- **Consider API:** Evaluate if explicit broadcasting functions (like NumPy's
  `broadcast_to`) are needed in the public API.

## Open Questions / Considerations

- How to best handle type promotion for mixed-type array-array operations?
  (Still relevant)
- Need robust testing for edge cases in broadcasting, especially with views and
  different strides.
