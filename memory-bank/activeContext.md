# Active Context: NumDart (As of 2025-04-04 ~23:40 Europe/London)

## Current Focus

- **Phase 2 Math Ops:** Implemented basic element-wise subtraction (`operator-`)
  for `NdArray` instances with the same shape and dtype.
- Added unit tests for `operator-` covering various scenarios.
- All tests are currently passing.

## Recent Changes

- Added `operator-` method to `lib/src/ndarray.dart` for element-wise
  subtraction of same-shape, same-dtype arrays.
- Added tests for `operator-` to `test/src/math_operations_test.dart`.
- Fixed test structure issues in `test/src/math_operations_test.dart` that
  caused errors when adding new test groups.
- (Previous) Implemented `operator+` and `toList()`.

## Next Steps

- Implement other basic element-wise mathematical operations (e.g., `*`, `/`)
  for same-shape arrays.
- Implement element-wise operations between an `NdArray` and a scalar value
  (e.g., `array + 5`).
- Consider implementing type promotion for operations between different numeric
  dtypes (e.g., int + double).

## Open Questions / Considerations

- How to best handle type promotion for mixed-type operations? (e.g.,
  Int64List + Float64List should likely result in Float64List).
