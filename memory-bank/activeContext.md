# Active Context: NumDart (As of 2025-04-04 ~23:49 Europe/London)

## Current Focus

- **Phase 2 Math Ops:** Implemented basic element-wise multiplication
  (`operator*`) for `NdArray` instances with the same shape and dtype.
- Added unit tests for `operator*` covering various scenarios.
- All tests are currently passing.

## Recent Changes

- Added `operator*` method to `lib/src/ndarray.dart` for element-wise
  multiplication of same-shape, same-dtype arrays.
- Added tests for `operator*` to `test/src/math_operations_test.dart`.
- (Previous) Implemented `operator+`, `operator-`, and `toList()`. Fixed test
  structure issues.

## Next Steps

- Implement basic element-wise division (`operator/`) for same-shape arrays
  (result should likely always be double).
- Implement element-wise operations between an `NdArray` and a scalar value
  (e.g., `array + 5`, `array * 2`).
- Consider implementing type promotion for operations between different numeric
  dtypes (e.g., int + double).

## Open Questions / Considerations

- How to best handle type promotion for mixed-type operations? (e.g.,
  Int64List + Float64List should likely result in Float64List).
- Division by zero handling: Should it throw an error, return `Infinity`, or
  `NaN`? (NumPy returns `inf` or `NaN` and raises a warning).
