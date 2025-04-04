# Active Context: NumDart (As of 2025-04-04 ~23:22 Europe/London)

## Current Focus

- **Phase 2 Started:** Implemented basic element-wise addition (`operator+`) for
  `NdArray` instances with the same shape and dtype.
- Implemented `toList()` method for `NdArray` to facilitate testing and data
  inspection.
- Added unit tests for `operator+` covering various scenarios (1D, 2D, views,
  empty arrays, error handling).
- All tests are currently passing.

## Recent Changes

- Added `operator+` method to `lib/src/ndarray.dart` for element-wise addition
  of same-shape, same-dtype arrays.
- Added `toList()` method to `lib/src/ndarray.dart` to convert `NdArray`
  (including views) to nested Dart Lists.
- Created `test/src/math_operations_test.dart` with tests for `operator+`.
- Fixed issues in `operator+` related to `dtype` handling when creating the
  result array.
- Fixed issues in `test/src/math_operations_test.dart` by adding missing
  `dart:typed_data` import.

## Next Steps

- Implement other basic element-wise mathematical operations (e.g., `-`, `*`,
  `/`) for same-shape arrays.
- Implement element-wise operations between an `NdArray` and a scalar value.
- Consider implementing type promotion for operations between different numeric
  dtypes (e.g., int + double).

## Open Questions / Considerations

- How to best handle type promotion for mixed-type operations? (e.g.,
  Int64List + Float64List should likely result in Float64List).
