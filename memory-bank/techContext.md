# Technical Context: NumDart

## 1. Core Language & SDK

- **Language:** Dart (SDK version >= 3.0.0)
- **Environment:** Primarily developed and tested for Flutter integration, but
  aims for core platform independence where possible. Assumed development
  environment is Windows.

## 2. Key Dependencies

- **`meta`:** Used for annotations like `@internal` to indicate non-public API
  elements.
- **`collection`:** Used for `ListEquality` in shape comparison logic.
- **`test`:** Standard Dart testing framework used for unit tests.

## 3. Development Setup & Tooling

- **IDE:** VS Code with Dart/Flutter extensions.
- **Version Control:** Git, hosted on GitHub
  (https://github.com/shtse8/numdart.git).
- **Package Management:** Dart `pub`.
- **Testing:** Tests are run using `dart test`.

## 4. Technical Constraints & Considerations

- **Performance:** Pure Dart performance compared to native NumPy (C/Fortran) is
  a major consideration. Optimization techniques and potential FFI usage will be
  evaluated.
- **TypedData Limitations:** While efficient, `TypedData` has fixed types.
  Handling mixed types or complex numbers might require custom classes or
  different approaches later.
- **View Complexity:** Managing shared data buffers through views (slicing,
  reshaping) requires careful handling of offsets and strides to ensure
  correctness and avoid unintended side effects. The current negative step
  slicing implementation has a known bug.
- **API Design:** Balancing NumPy compatibility with Dart idioms and type safety
  is an ongoing consideration.
- **Memory Management:** Relying on Dart's garbage collector. Large array
  operations need to be mindful of memory allocation and potential pressure.
