<!-- Version: 1.3 | Last Updated: 2025-04-05 | Updated By: Cline -->

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
  - **✅ Verified Type Promotion:** Confirmed correct handling in arithmetic
    operators.
  - **✅ Implemented `NdArray.sqrt()`:** Element-wise square root.
  - **✅ Implemented `NdArray.exp()`:** Element-wise exponential.
  - **✅ Implemented `NdArray.sin()`:** Element-wise sine.
  - **✅ Implemented `NdArray.cos()`:** Element-wise cosine.
  - **✅ Implemented `NdArray.tan()`:** Element-wise tangent.
  - **✅ Implemented `NdArray.log()`:** Element-wise natural logarithm.
  - **✅ Refactored Tests:** Updated all creation and math operation tests to
    use static `NdArray` methods and removed obsolete `part` files.

## Known Issues / TODOs

1. **Add More Math Functions:**
   - **TODO:** Implement aggregation functions (e.g., `sum`, `mean`, `max`,
     `min`). (`sqrt`, `exp`, `sin`, `cos`, `tan`, `log` done).
2. **Refine Broadcasting:**
   - **TODO:** Add more complex broadcasting tests (views, varied dimensions).
   - **TODO:** Consider if explicit `broadcast_to` function is needed.
3. **Scalar Handling:**
   - **TODO:** Review and ensure consistent handling for 0-D (scalar) arrays
     across all functions (especially `toList()`). Consider adding
     `NdArray.scalar()` constructor or improving `NdArray.array()` for scalars.
4. **Slicing Bug:**
   - **TODO:** Address known bug with negative steps in slicing.
5. **FFI Investigation:** Keep in mind for Phase 3 if performance becomes a
   bottleneck.
