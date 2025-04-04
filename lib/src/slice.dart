/// Represents a slice operation with start, stop, and step parameters.
///
/// Used for creating views of NdArray data. All parameters are optional.
/// - [start]: The starting index (inclusive). Defaults depend on the step direction.
/// - [stop]: The ending index (exclusive). Defaults depend on the step direction.
/// - [step]: The step size. Defaults to 1.
class Slice {
  final int? start;
  final int? stop;
  final int? step;

  /// Creates a Slice object.
  Slice([this.start, this.stop, this.step = 1]) {
    if (step == 0) {
      throw ArgumentError('Slice step cannot be zero.');
    }
  }

  /// Convenience getter for the default slice representing all elements.
  static final Slice all = Slice();

  /// Adjusts the slice parameters based on the dimension size.
  /// Calculates the actual start, stop, and step within the bounds [0, length).
  /// Returns a tuple: (adjustedStart, adjustedStop, adjustedStep, sliceLength).
  (int, int, int, int) adjust(int length) {
    int actualStep = step ?? 1;
    int actualStart;
    int actualStop;

    // Adjust start based on step direction
    if (actualStep > 0) {
      actualStart = start ?? 0;
      if (actualStart < 0) actualStart += length;
      actualStart = actualStart.clamp(0, length);
    } else {
      // step < 0
      actualStart = start ?? length - 1;
      if (actualStart < 0) actualStart += length;
      actualStart = actualStart.clamp(-1, length - 1);
    }

    // Adjust stop based on step direction
    if (actualStep > 0) {
      actualStop = stop ?? length;
      if (actualStop < 0) actualStop += length;
      actualStop = actualStop.clamp(0, length);
    } else {
      // step < 0
      int? userStop = stop; // Keep track of original user input
      actualStop = userStop ?? -1; // Default stop is -1 (before beginning)

      if (userStop != null && actualStop < 0) {
        // Adjust only if stop was provided by user and is negative
        actualStop += length;
      }
      // Clamp stop for negative step. Should be clamped between -1 and length-1.
      actualStop = actualStop.clamp(-1, length - 1);
    }

    // Calculate slice length
    int sliceLength;
    if (actualStep > 0) {
      if (actualStart >= actualStop) {
        sliceLength = 0;
      } else {
        // Correct calculation for positive step
        sliceLength = (actualStop - actualStart + actualStep - 1) ~/ actualStep;
      }
    } else {
      // step < 0
      if (actualStart <= actualStop) {
        sliceLength = 0;
      } else {
        // Correct calculation for negative step
        sliceLength = (actualStart - actualStop + actualStep.abs() - 1) ~/
            actualStep.abs();
      }
    }
    // No need to clamp sliceLength here, the calculation should be correct if start/stop are clamped.
    // sliceLength = sliceLength.clamp(0, length); // Removed clamp

    return (actualStart, actualStop, actualStep, sliceLength);
  }

  @override
  String toString() => 'Slice(start: $start, stop: $stop, step: $step)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Slice &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          stop == other.stop &&
          step == other.step;

  @override
  int get hashCode => start.hashCode ^ stop.hashCode ^ step.hashCode;
}
