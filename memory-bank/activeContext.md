# Active Context: NumDart (As of 2025-04-05 ~00:16 Europe/London)

## Current Focus

- **Phase 2 Math Ops:** Implemented scalar division for `operator/`
  (`NdArray / num`).
- Result is always `double` (`Float64List`).
- Handles division by zero according to Dart's double behavior (`Infinity`,
  `-Infinity`, `NaN`).
- Added unit tests for scalar division.
- All tests are currently passing.

## Recent Changes

- Added `operator/` method to `lib/src/ndarray.dart` (currently only supports
  scalar division).
- Added scalar division tests to `test/src/math_operations_test.dart`, including
  division by zero cases.
- (Previous) Implemented scalar multiplication (`operator*`), scalar
  addition/subtraction (`operator+`, `operator-`), array-array ops (`+`, `-`,
  `*`), `toList()`. Fixed test structure issues.

## Next Steps

- Implement basic element-wise division (`operator/`) for same-shape arrays.
- Consider implementing type promotion for array-array operations.
- Begin implementing Broadcasting mechanism (needed for NdArray slice assignment
  and more flexible math ops).

## Open Questions / Considerations

- How to best handle type promotion for mixed-type array-array operations?
- Division by zero handling for array-array division.
