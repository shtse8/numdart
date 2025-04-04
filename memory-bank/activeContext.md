# Active Context: NumDart (As of 2025-04-04 ~23:51 Europe/London)

## Current Focus

- **Phase 2 Math Ops:** Implemented scalar addition for `operator+`
  (`NdArray + num`).
- Handles type promotion (int array + double scalar -> double array).
- Added unit tests for scalar addition covering various scenarios including type
  promotion.
- All tests are currently passing.

## Recent Changes

- Modified `operator+` in `lib/src/ndarray.dart` to accept `dynamic` and handle
  `num` operands.
- Added scalar addition tests to `test/src/math_operations_test.dart`.
- Fixed test structure issues in `test/src/math_operations_test.dart` again.
- (Previous) Implemented `operator*`, `operator-`, `operator+` (array-array),
  and `toList()`.

## Next Steps

- Implement scalar subtraction, multiplication, and division (`array - scalar`,
  `array * scalar`, `array / scalar`).
- Implement basic element-wise division (`operator/`) for same-shape arrays
  (consider result type and division by zero).
- Consider implementing type promotion for array-array operations.

## Open Questions / Considerations

- How to best handle type promotion for mixed-type array-array operations?
- Division by zero handling: Should it throw an error, return `Infinity`, or
  `NaN`?
