# Product Context: NumDart

## 1. Problem Statement

Dart currently lacks a comprehensive, high-performance numerical computing
library comparable to Python's NumPy. This makes tasks involving
multi-dimensional arrays, linear algebra, and complex mathematical operations
cumbersome and inefficient, especially within the Flutter ecosystem where
performance is critical. Developers often resort to less optimized pure Dart
solutions, FFI wrappers with significant boilerplate, or avoid certain types of
computation altogether.

## 2. Project Vision

NumDart aims to be the de facto standard for numerical computing in Dart. It
will provide:

- A powerful and familiar API inspired by NumPy.
- High performance for core operations, leveraging `TypedData` and potentially
  FFI where necessary.
- Seamless integration with the Dart and Flutter ecosystems.
- A foundation for other scientific and data analysis libraries in Dart.

## 3. Target Audience & Use Cases

- **Flutter Developers:** Implementing features requiring numerical computation
  (e.g., image processing, physics simulations, data visualization, machine
  learning inference).
- **Dart Backend Developers:** Performing server-side calculations, data
  analysis, or scientific computing tasks.
- **Researchers & Scientists:** Using Dart for modeling, simulations, and data
  analysis.

## 4. Key Principles

- **API Familiarity:** Prioritize an API that feels intuitive to users familiar
  with NumPy.
- **Performance:** Optimize for speed and memory efficiency, especially for
  common operations.
- **Correctness:** Ensure numerical results are accurate and consistent with
  NumPy where applicable.
- **Extensibility:** Design the core library to be extensible for future modules
  (e.g., linear algebra, random numbers).
- **Dart Idiomatic:** While inspired by NumPy, adhere to Dart best practices and
  conventions.
