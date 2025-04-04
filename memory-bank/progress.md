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

- **Phase 2 (Math &amp; Broadcasting):** In Progress.
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

## Known Issues / TODOs

1. **Implement Slice Assignment (NdArray):**
   - **TODO:** Implement assigning an `NdArray` to a slice (e.g.,
     `a[[Slice(0, 2)]] = b`). Requires broadcasting. **(Next Major Task)**
2. **Implement Type Promotion:**
   - **TODO:** Define rules and implement logic for array-array operations
     between different numeric dtypes (e.g., `int` array + `double` array).
3. **Refine Broadcasting:**
   - **TODO:** Add more complex broadcasting tests (views, varied dimensions).
   - **TODO:** Consider if explicit `broadcast_to` function is needed.
4. **Scalar Handling:**
   - **TODO:** Review and ensure consistent handling for 0-D (scalar) arrays
     across all functions (especially `toList()`). Consider adding
     `NdArray.scalar()` constructor.
5. **FFI Investigation:** Keep in mind for Phase 3 if performance becomes a
   bottleneck.
6. **Slicing Bug:** Address known bug with negative steps in slicing.
