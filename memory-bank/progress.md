<!-- Version: 1.9 | Last Updated: 2025-04-05 | Updated By: Cline -->

# Project Progress: NumDart

## Current Status

- **Phase 1 (Foundation):** ✅ Complete.
  - Core `NdArray` class structure defined (`data`, `shape`, `strides`, `dtype`,
    `size`, `ndim`, `offsetInBytes`). `dtype` now stores primitive type
    (`int`/`double`).
  - Basic creation functions implemented and tested (`array`, `zeros`, `ones`,
    `arange`, `linspace`, `scalar`).
  - Basic integer indexing (`operator []`) implemented and tested.
  - Basic slicing (`operator []` returning view) implemented and tested.
  - Reshaping (`reshape()` returning view) implemented and tested.
  - Scalar slice assignment (`operator []=`) implemented and tested.
  - Helper method `toList()` implemented and tested (returns scalar for 0-D).
  - **✅ Added `elements` Getter:** Provides public iteration over elements.

- **Phase 2 (Math & Broadcasting):** ✅ Complete.
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
  - **✅ Implemented Aggregation Functions:** `sum()`, `mean()`, `max()`,
    `min()` implemented and tested.
  - **✅ Refactored Tests:** Updated all creation and math operation tests to
    use static `NdArray` methods and removed obsolete `part` files.
  - **✅ Refined Broadcasting Tests (Arithmetic Ops):** Added more complex test
    cases for `+`, `-`, `*`, `/`.
  - **✅ Investigated Slicing Bug:** No active bug found with negative steps.
  - **✅ Improved Scalar Handling:** Added `NdArray.scalar()` constructor and
    updated `toList()` behavior for 0-D arrays.
  - **✅ Fixed Aggregation Structure:** Corrected structure of `max()`/`min()`
    in `NdArrayAggregation`.
  - **✅ Cleaned Obsolete Test Files:** Removed old test runner files.

- **Phase 3 (Flutter Integration & Optimization):** ⏳ In Progress.
  - **✅ Researched Performance Strategy:** Defined approach using DevTools and
    `benchmark_harness`.
  - **✅ Setup Benchmarking:** Created `benchmark/` directory, added dependency,
    created initial `creation_benchmark.dart`.

## Known Issues / TODOs

1. **FFI Investigation:** Keep in mind for Phase 3 if performance becomes a
   bottleneck.
2. **Analyzer Issues:** Persistent errors related to deleted test files might
   require manual intervention (cache clear/IDE restart). (Should resolve after
   restart)
3. **Future:** Consider adding explicit `broadcast_to` function.
4. **Run/Expand Benchmarks:** Execute initial benchmarks and add more for other
   operations.
5. **Performance Profiling:** Use DevTools to analyze benchmark results.
