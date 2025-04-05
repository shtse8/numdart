import 'dart:math' as math;
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:numdart/numdart.dart';
import 'package:test/test.dart';

part 'elementwise_math_sqrt_test.dart';
part 'elementwise_math_exp_test.dart';
part 'elementwise_math_sin_test.dart';
part 'elementwise_math_cos_test.dart';
part 'elementwise_math_tan_test.dart';
part 'elementwise_math_log_test.dart';

void main() {
  _testSqrtGroup();
  _testExpGroup();
  _testSinGroup();
  _testCosGroup();
  _testTanGroup();
  _testLogGroup();
}
