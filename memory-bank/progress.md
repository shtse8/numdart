# Project Progress: NumDart

## Current Status

- **Phase 1 (Foundation):** ✅ Complete.
  - Core `NdArray` class structure defined (`data`, `shape`, `strides`, `dtype`,
    `size`, `ndim`, `offsetInBytes`). `dtype` now stores primitive type
    (`int`/`double`).
  - Basic creation functions implemented and tested.
  - Basic integer indexing (`operator []`) implemented and tested.
  - Basic slicing (`operator []` returning view) implemented and tested.
  - Reshaping (`reshape()` returning view) implemented and tested.
  - Scalar slice assignment (`operator []=`) implemented and tested.
  - Helper method `toList()` implemented and tested.

- **Phase 2 (Math & Broadcasting):** ⏳ In Progress.
  - Element-wise addition (`operator+`) with broadcasting implemented and
    tested.
  - Scalar addition (`NdArray + num`) implemented and tested.
  - Element-wise subtraction (`operator-`) with broadcasting implemented and
    tested.
  - Scalar subtraction (`NdArray - num`) implemented and tested.
  - Element-wise multiplication (`operator*`) with broadcasting implemented and
    tested.
  - Scalar multiplication (`NdArray * num`) implemented and tested.
  - Element-wise division (`operator/`) with broadcasting implemented and tested
    (result always double).
  - Scalar division (`NdArray / num`) implemented and tested (result always
    double).
  - Basic broadcasting mechanism implemented via `_calculateBroadcastShape` and
    integrated into arithmetic operators.
  - NdArray slice assignment (`operator []=`) implemented and tested (including
    broadcasting).
  - Fixed bug related to `dtype` in scalar operations on empty arrays.

## Known Issues / TODOs

1. **Implement Type Promotion:**
   - **TODO:** Define rules and implement logic for array-array operations
     between different numeric dtypes (e.g., `int` array + `double` array).
     **(Next Major Task)**
2. **Add More Math Functions:**
   - **TODO:** Implement common element-wise functions (e.g., `sqrt`, `exp`,
     `sin`).
   - **TODO:** Implement aggregation functions (e.g., `sum`, `mean`, `max`,
     `min`).
3. **Refine Broadcasting:**
   - **TODO:** Add more complex broadcasting tests (views, varied dimensions).
   - **TODO:** Consider if explicit `broadcast_to` function is needed.
4. **Scalar Handling:**
   - **TODO:** Review and ensure consistent handling for 0-D (scalar) arrays
     across all functions (especially `toList()`). Consider adding
     `NdArray.scalar()` constructor or improving `NdArray.array()` for scalars.
5. **Slicing Bug:**
   - **TODO:** Address known bug with negative steps in slicing.
6. **FFI Investigation:** Keep in mind for Phase 3 if performance becomes a
   bottleneck.
