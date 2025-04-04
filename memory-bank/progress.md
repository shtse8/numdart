# Project Progress: NumDart

## Current Status

- **Phase 1 (Foundation):** Mostly Complete.
  - Core `NdArray` class structure defined (`data`, `shape`, `strides`, `dtype`,
    `size`, `ndim`, `offsetInBytes`).
  - Basic creation functions implemented and tested.
  - Basic integer indexing (`operator []`) implemented and tested.
  - Basic slicing (`operator []` returning view) implemented and tested.
  - Reshaping (`reshape()` returning view) implemented and tested.
  - Scalar slice assignment (`operator []=`) implemented and tested.
  - Helper method `toList()` implemented and tested.

- **Phase 2 (Math & Broadcasting):** In Progress.
  - Basic element-wise addition (`operator+`) for same-shape, same-dtype arrays
    implemented and tested.
  - Scalar addition (`NdArray + num`) implemented and tested (includes type
    promotion).
  - Basic element-wise subtraction (`operator-`) for same-shape, same-dtype
    arrays implemented and tested.
  - Scalar subtraction (`NdArray - num`) implemented and tested (includes type
    promotion).
  - Basic element-wise multiplication (`operator*`) for same-shape, same-dtype
    arrays implemented and tested.
  - Scalar multiplication (`NdArray * num`) implemented and tested (includes
    type promotion).
  - Scalar division (`NdArray / num`) implemented and tested (result always
    double, handles division by zero).

## Known Issues / TODOs

1. **Implement Slice Assignment (NdArray):**
   - **TODO:** Implement assigning an `NdArray` to a slice (requires
     broadcasting).
2. **Implement Broadcasting:** Core mechanism needed for NdArray slice
   assignment and many math operations.
3. **Implement Remaining Basic Math Ops:**
   - **TODO:** Implement array-array division (`operator/`). Consider result
     type and division by zero.
4. **Type Promotion:**
   - **TODO:** Define rules and implement logic for array-array operations
     between different numeric dtypes.
5. **Scalar Handling:** Review and ensure consistent handling for 0-D (scalar)
   arrays across all functions (especially `toList()`).
6. **FFI Investigation:** Keep in mind for Phase 3 if performance becomes a
   bottleneck.
