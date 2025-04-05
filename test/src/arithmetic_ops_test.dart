library arithmetic_ops_test; // Define a library name

import 'dart:typed_data';
import 'dart:math' as math; // Import math library with prefix
import 'dart:math'; // For isNaN checks

import 'package:test/test.dart';
import 'package:numdart/numdart.dart';
import 'package:collection/collection.dart'; // For deep equality checks

part 'arithmetic_ops_add_test.dart';
part 'arithmetic_ops_sub_test.dart';
part 'arithmetic_ops_mul_test.dart';
part 'arithmetic_ops_div_test.dart';

void main() {
  _testAdditionGroup();
  _testSubtractionGroup();
  _testMultiplicationGroup();
  _testDivisionGroup();
}
