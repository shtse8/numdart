# Active Context: NumDart (As of 2025-04-05 ~00:06 Europe/London)

## Current Focus

- **Phase 2 Math Ops:** Implemented scalar multiplication for `operator*`
  (`NdArray * num`).
- Handles type promotion similar to scalar addition/subtraction.
- Added unit tests for scalar multiplication.
- All tests are currently passing.

## Recent Changes

- Modified `operator*` in `lib/src/ndarray.dart` to accept `dynamic` and handle
  `num` operands.
- Added scalar multiplication tests to `test/src/math_operations_test.dart`.
- (Previous) Implemented scalar addition/subtraction (`operator+`, `operator-`),
  array-array ops (`+`, `-`, `*`), `toList()`. Fixed test structure issues.

## Next Steps

- Implement scalar division (`array / scalar`).
- Implement basic element-wise division (`operator/`) for same-shape arrays
  (consider result type and division by zero).
- Consider implementing type promotion for array-array operations.

## Open Questions / Considerations

- How to best handle type promotion for mixed-type array-array operations?
- Division by zero handling: Should it throw an error, return `Infinity`, or
  `NaN`?
