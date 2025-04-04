# Project Progress: NumDart

## Current Status

- **Phase 1 (Foundation):** In progress.
  - Core `NdArray` class structure defined (`data`, `shape`, `strides`, `dtype`,
    `size`, `ndim`, `offsetInBytes`).
  - Basic creation functions implemented and tested:
    - `NdArray.array()`
    - `NdArray.zeros()`
    - `NdArray.ones()`
    - `NdArray.arange()`
    - `NdArray.linspace()`
  - Basic integer indexing (`operator []`) implemented and tested.
  - Basic slicing (`operator []` returning view) implemented and tested
    (including negative steps).

## Known Issues / TODOs

1. **Negative Step Slicing Bug:** **(RESOLVED)**
   - **Symptom:** The test case `1D slicing - negative step` failed. A view
     created with `Slice(null, null, -1)` on `NdArray.arange(5)` incorrectly
     reported `shape=[0]`.
   - **Investigation:** Debugging revealed the issue was in `Slice.adjust`. When
     `step` was negative and `stop` was `null`, the `actualStop` was incorrectly
     adjusted by adding `length`, leading to an incorrect `sliceLength`
     calculation of 0.
   - **Fix:** Modified `Slice.adjust` to only adjust negative `stop` values if
     they were explicitly provided by the user, ensuring the default `stop` of
     `-1` is handled correctly for negative steps.
   - **Status:** Resolved. Test `1D slicing - negative step` now passes.

2. **Empty Array Slicing Test Failure:** **(RESOLVED)**
   - **Symptom:** The test case `Slicing results in empty array` failed.
   - **Investigation:** This issue was related to the negative step slicing bug
     (#1).
   - **Status:** Resolved. Test `Slicing results in empty array` now passes
     after fixing issue #1.

3. **Implement Slice Assignment:** **(Partially Complete)**
   - Extended `operator []=` to handle assigning **scalar** values to slices.
   - Implemented helper methods `_getViewDataIndices` and `_assignScalarToView`.
   - Added comprehensive tests for scalar slice assignment.
   - **TODO:** Implement assigning an `NdArray` to a slice (requires
     broadcasting).
4. **Scalar Handling:** Review and ensure consistent handling for 0-D (scalar)
   arrays across all functions.
5. **FFI Investigation:** Keep in mind for Phase 3 if performance becomes a
   bottleneck.
