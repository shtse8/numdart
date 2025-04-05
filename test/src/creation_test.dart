import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:numdart/numdart.dart'; // Import main library now that NdArray is exported
import 'package:numdart/src/ndarray.dart'; // Keep internal import for accessing internal members if needed later

void main() {
  group('array creation tests', () {
    test('1D List<int> creation', () {
      var list = [1, 2, 3, 4];
      var nd = array(list);
      expect(nd.shape, equals([4]));
      expect(nd.dtype, equals(int)); // Already correct
      expect(nd.size, equals(4));
      expect(nd.ndim, equals(1));
      expect(nd.strides, equals([nd.data.elementSizeInBytes]));
      expect(nd.data, equals(Int64List.fromList([1, 2, 3, 4])));
    });

    test('1D List<double> creation', () {
      var list = [1.0, 2.5, 3.0];
      var nd = array(list);
      expect(nd.shape, equals([3]));
      expect(nd.dtype, equals(double)); // Already correct
      expect(nd.size, equals(3));
      expect(nd.ndim, equals(1));
      expect(nd.strides, equals([nd.data.elementSizeInBytes]));
      expect(nd.data, equals(Float64List.fromList([1.0, 2.5, 3.0])));
    });

    test('1D List<num> (mixed) creation', () {
      var list = [1, 2.5, 3];
      var nd = array(list);
      expect(nd.shape, equals([3]));
      expect(nd.dtype, equals(double)); // Already correct
      expect(nd.size, equals(3));
      expect(nd.ndim, equals(1));
      expect(nd.strides, equals([nd.data.elementSizeInBytes]));
      expect(nd.data, equals(Float64List.fromList([1.0, 2.5, 3.0])));
    });

    test('2D List<List<int>> creation', () {
      var list = [
        [1, 2],
        [3, 4],
        [5, 6]
      ];
      var nd = array(list);
      final elementSize = nd.data.elementSizeInBytes;
      expect(nd.shape, equals([3, 2]));
      expect(nd.dtype, equals(int)); // Already correct
      expect(nd.size, equals(6));
      expect(nd.ndim, equals(2));
      expect(nd.strides, equals([2 * elementSize, elementSize]));
      expect(nd.data, equals(Int64List.fromList([1, 2, 3, 4, 5, 6])));
    });

    test('2D List<List<double>> creation with explicit dtype Float32List', () {
      var list = [
        [1.0, 2.0],
        [3.0, 4.0]
      ];
      var nd = array(list, dtype: Float32List);
      final elementSize = nd.data.elementSizeInBytes;
      expect(nd.shape, equals([2, 2]));
      expect(nd.dtype, equals(double)); // Already correct
      expect(nd.data, isA<Float32List>());
      expect(elementSize, equals(4));
      expect(nd.size, equals(4));
      expect(nd.ndim, equals(2));
      expect(nd.strides, equals([2 * elementSize, elementSize]));
      expect(nd.data, equals(Float32List.fromList([1.0, 2.0, 3.0, 4.0])));
    });

    test('3D List creation', () {
      var list = [
        [
          [1, 2],
          [3, 4]
        ],
        [
          [5, 6],
          [7, 8]
        ]
      ];
      var nd = array(list);
      final elementSize = nd.data.elementSizeInBytes;
      expect(nd.shape, equals([2, 2, 2]));
      expect(nd.dtype, equals(int)); // Already correct
      expect(nd.size, equals(8));
      expect(nd.ndim, equals(3));
      expect(
          nd.strides, equals([4 * elementSize, 2 * elementSize, elementSize]));
      expect(nd.data, equals(Int64List.fromList([1, 2, 3, 4, 5, 6, 7, 8])));
    });

    test('Empty list [] creation', () {
      var list = [];
      var nd = array(list);
      final elementSize = nd.data.elementSizeInBytes;
      expect(nd.shape, equals([0]));
      expect(nd.dtype, equals(double)); // Already correct
      expect(nd.data, isA<Float64List>());
      expect(nd.size, equals(0));
      expect(nd.ndim, equals(1));
      expect(nd.strides,
          equals([elementSize])); // NumPy stride is (8,) for shape (0,)
      expect(nd.data, equals(Float64List.fromList([])));
    });

    test('List with empty list [[]] creation', () {
      var list = [[]];
      var nd = array(list);
      final elementSize = nd.data.elementSizeInBytes;
      expect(nd.shape, equals([1, 0]));
      expect(nd.dtype, equals(double)); // Already correct
      expect(nd.data, isA<Float64List>());
      expect(nd.size, equals(0));
      expect(nd.ndim, equals(2));
      expect(
          nd.strides,
          equals([
            elementSize,
            elementSize
          ])); // Stride for (1,0) should be [0*elem, elem] -> [0, 8]? No, [elem, elem]? Let's recheck _calculateStrides
      // _calculateStrides logic: strides[i] = (shape[i + 1] == 0) ? elementSizeInBytes : strides[i + 1] * shape[i + 1];
      // i=1: strides[1] = elementSize (8)
      // i=0: strides[0] = (shape[1]==0) ? elementSize : strides[1]*shape[1] = elementSize = 8
      // So strides should be [8, 8]
      expect(nd.strides, equals([elementSize, elementSize]));
      expect(nd.data, equals(Float64List.fromList([])));
    });

    test('List with multiple empty lists [[], []] creation', () {
      var list = [[], []];
      var nd = array(list);
      final elementSize = nd.data.elementSizeInBytes;
      expect(nd.shape, equals([2, 0]));
      expect(nd.dtype, equals(double)); // Already correct
      expect(nd.data, isA<Float64List>());
      expect(nd.size, equals(0));
      expect(nd.ndim, equals(2));
      // Strides for (2,0): [0*elem, elem] -> [0, 8]? No, [elem, elem] -> [8, 8] based on above logic
      expect(nd.strides, equals([elementSize, elementSize]));
      expect(nd.data, equals(Float64List.fromList([])));
    });

    test('Inconsistent shape throws error', () {
      var list = [
        [1, 2],
        [3, 4, 5]
      ];
      expect(() => array(list), throwsArgumentError);
      var list2 = [
        1,
        [2, 3]
      ];
      expect(() => array(list2), throwsArgumentError);
    });

    test('Inconsistent type (non-numeric) throws error', () {
      var list = [1, 2, 'hello'];
      expect(() => array(list), throwsArgumentError);
      var list2 = [
        [1, 2],
        [3, true]
      ];
      expect(() => array(list2), throwsArgumentError);
    });

    test('Explicit dtype Int32List', () {
      var list = [10, 20, 30];
      var nd = array(list, dtype: Int32List);
      expect(nd.shape, equals([3]));
      expect(nd.dtype, equals(int));
      expect(nd.data, isA<Int32List>());
      expect(nd.size, equals(3));
      expect(nd.ndim, equals(1));
      expect(nd.strides, equals([nd.data.elementSizeInBytes]));
      expect(nd.data, equals(Int32List.fromList([10, 20, 30])));
    });
  }); // End of array group

  group('zeros creation tests', () {
    test('zeros with shape [3]', () {
      var shape = [3];
      var nd = zeros(shape);
      final elementSize = nd.data.elementSizeInBytes;
      expect(nd.shape, equals(shape));
      expect(nd.dtype, equals(double));
      expect(nd.data, isA<Float64List>());
      expect(nd.size, equals(3));
      expect(nd.ndim, equals(1));
      expect(nd.strides, equals([elementSize]));
      expect(nd.data, equals(Float64List.fromList([0.0, 0.0, 0.0])));
    });

    test('zeros with shape [2, 3] and dtype Int32List', () {
      var shape = [2, 3];
      var nd = zeros(shape, dtype: Int32List);
      final elementSize = nd.data.elementSizeInBytes;
      expect(nd.shape, equals(shape));
      expect(nd.dtype, equals(int));
      expect(nd.data, isA<Int32List>());
      expect(elementSize, equals(4));
      expect(nd.size, equals(6));
      expect(nd.ndim, equals(2));
      expect(nd.strides, equals([3 * elementSize, elementSize]));
      expect(nd.data, equals(Int32List.fromList([0, 0, 0, 0, 0, 0])));
    });

    test('zeros with shape [2, 0]', () {
      var shape = [2, 0];
      var nd = zeros(shape);
      final elementSize = nd.data.elementSizeInBytes;
      expect(nd.shape, equals(shape));
      expect(nd.dtype, equals(double));
      expect(nd.data, isA<Float64List>());
      expect(nd.size, equals(0));
      expect(nd.ndim, equals(2));
      expect(
          nd.strides,
          equals([
            elementSize,
            elementSize
          ])); // Corrected expectation based on _calculateStrides logic
      expect(nd.data, equals(Float64List(0)));
    });

    test('zeros with empty shape [] - Scalar', () {
      var shape = <int>[];
      var nd = zeros(shape);
      final elementSize = nd.data.elementSizeInBytes;
      expect(nd.shape, equals(shape));
      expect(nd.dtype, equals(double)); // Already correct
      expect(nd.data, isA<Float64List>());
      expect(nd.size, equals(1)); // Expect size 1 for scalar
      expect(nd.ndim, equals(0));
      expect(nd.strides, equals([]));
      expect(nd.data, equals(Float64List.fromList([0.0]))); // Expect data [0.0]
    });

    test('zeros with negative dimension throws error', () {
      var shape = [2, -3];
      expect(() => zeros(shape), throwsArgumentError);
    });
  }); // End of zeros group

  group('ones creation tests', () {
    test('ones with shape [4]', () {
      var shape = [4];
      var nd = ones(shape);
      final elementSize = nd.data.elementSizeInBytes;
      expect(nd.shape, equals(shape));
      expect(nd.dtype, equals(double));
      expect(nd.data, isA<Float64List>());
      expect(nd.size, equals(4));
      expect(nd.ndim, equals(1));
      expect(nd.strides, equals([elementSize]));
      expect(nd.data, equals(Float64List.fromList([1.0, 1.0, 1.0, 1.0])));
    });

    test('ones with shape [2, 2] and dtype Int8List', () {
      var shape = [2, 2];
      var nd = ones(shape, dtype: Int8List);
      final elementSize = nd.data.elementSizeInBytes;
      expect(nd.shape, equals(shape));
      expect(nd.dtype, equals(int));
      expect(nd.data, isA<Int8List>());
      expect(elementSize, equals(1));
      expect(nd.size, equals(4));
      expect(nd.ndim, equals(2));
      expect(nd.strides, equals([2 * elementSize, elementSize]));
      expect(nd.data, equals(Int8List.fromList([1, 1, 1, 1])));
    });

    test('ones with shape [3, 0]', () {
      var shape = [3, 0];
      var nd = ones(shape);
      final elementSize = nd.data.elementSizeInBytes;
      expect(nd.shape, equals(shape));
      expect(nd.dtype, equals(double)); // Already correct
      expect(nd.data, isA<Float64List>());
      expect(nd.size, equals(0));
      expect(nd.ndim, equals(2));
      expect(nd.strides,
          equals([elementSize, elementSize])); // Corrected expectation
      expect(nd.data, equals(Float64List(0)));
    });

    test('ones with empty shape [] - Scalar', () {
      var shape = <int>[];
      var nd = ones(shape);
      final elementSize = nd.data.elementSizeInBytes;
      expect(nd.shape, equals(shape));
      expect(nd.dtype, equals(double));
      expect(nd.data, isA<Float64List>());
      expect(nd.size, equals(1)); // Expect size 1
      expect(nd.ndim, equals(0));
      expect(nd.strides, equals([]));
      expect(nd.data, equals(Float64List.fromList([1.0]))); // Expect data [1.0]
    });

    test('ones with negative dimension throws error', () {
      var shape = [-1, 5];
      expect(() => ones(shape), throwsArgumentError);
    });
  }); // End of ones group

  group('arange creation tests', () {
    test('arange with stop only (int)', () {
      var nd = arange(5);
      expect(nd.shape, equals([5]));
      expect(nd.dtype, equals(int));
      expect(nd.data, isA<Int64List>());
      expect(nd.data, equals(Int64List.fromList([0, 1, 2, 3, 4])));
    });

    test('arange with stop only (double)', () {
      var nd = arange(3.0);
      expect(nd.shape, equals([3]));
      expect(nd.dtype, equals(double)); // Already correct
      expect(nd.data, isA<Float64List>());
      expect(nd.data, equals(Float64List.fromList([0.0, 1.0, 2.0])));
    });

    test('arange with start and stop (int)', () {
      var nd = arange(2, stop: 6);
      expect(nd.shape, equals([4]));
      expect(nd.dtype, equals(int));
      expect(nd.data, isA<Int64List>());
      expect(nd.data, equals(Int64List.fromList([2, 3, 4, 5])));
    });

    test('arange with start, stop, and step (int)', () {
      var nd = arange(1, stop: 10, step: 2);
      expect(nd.shape, equals([5]));
      expect(nd.dtype, equals(int)); // Already correct
      expect(nd.data, isA<Int64List>());
      expect(nd.data, equals(Int64List.fromList([1, 3, 5, 7, 9])));
    });

    test('arange with start, stop, and step (double)', () {
      var nd = arange(1.0, stop: 3.0, step: 0.5);
      expect(nd.shape, equals([4]));
      expect(nd.dtype, equals(double));
      expect(nd.data, isA<Float64List>());
      expect((nd.data as Float64List)[0], closeTo(1.0, 1e-9));
      expect((nd.data as Float64List)[1], closeTo(1.5, 1e-9));
      expect((nd.data as Float64List)[2], closeTo(2.0, 1e-9));
      expect((nd.data as Float64List)[3], closeTo(2.5, 1e-9));
    });

    test('arange with negative step (int)', () {
      var nd = arange(5, stop: 1, step: -1);
      expect(nd.shape, equals([4]));
      expect(nd.dtype, equals(int)); // Already correct
      expect(nd.data, isA<Int64List>());
      expect(nd.data, equals(Int64List.fromList([5, 4, 3, 2])));
    });

    test('arange with negative step (double)', () {
      var nd = arange(2.5, stop: 0.0, step: -0.5);
      expect(nd.shape, equals([5]));
      expect(nd.dtype, equals(double)); // Already correct
      expect(nd.data, isA<Float64List>());
      expect((nd.data as Float64List)[0], closeTo(2.5, 1e-9));
      expect((nd.data as Float64List)[1], closeTo(2.0, 1e-9));
      expect((nd.data as Float64List)[2], closeTo(1.5, 1e-9));
      expect((nd.data as Float64List)[3], closeTo(1.0, 1e-9));
      expect((nd.data as Float64List)[4], closeTo(0.5, 1e-9));
    });

    test('arange resulting in empty array (positive step)', () {
      var nd = arange(5, stop: 5);
      expect(nd.shape, equals([0]));
      expect(nd.size, equals(0));
      expect(nd.dtype, equals(int)); // Already correct
      expect(nd.data, isA<Int64List>());
      expect((nd.data as Int64List).length, equals(0));
      var nd2 = arange(6, stop: 5);
      expect(nd2.shape, equals([0]));
      expect(nd2.size, equals(0));
    });

    test('arange resulting in empty array (negative step)', () {
      var nd = arange(1, stop: 5, step: -1);
      expect(nd.shape, equals([0]));
      expect(nd.size, equals(0));
      expect(nd.dtype, equals(int));
      expect(nd.data, isA<Int64List>());
      expect((nd.data as Int64List).length, equals(0));
    });

    test('arange with explicit dtype', () {
      var nd = arange(5, dtype: Float32List);
      expect(nd.shape, equals([5]));
      expect(nd.dtype, equals(double));
      expect(nd.data, isA<Float32List>());
      expect(nd.data, equals(Float32List.fromList([0.0, 1.0, 2.0, 3.0, 4.0])));
    });

    test('arange with zero step throws error', () {
      expect(() => arange(1, stop: 10, step: 0), throwsArgumentError);
    });

    test('arange with tricky float step', () {
      var nd = arange(0, stop: 1, step: 0.1);
      expect(nd.shape, equals([10]));
      expect(nd.dtype, equals(double));
      expect(nd.data, isA<Float64List>());
      expect((nd.data as Float64List).length, equals(10));
      expect((nd.data as Float64List)[9], closeTo(0.9, 1e-9));
    });
  }); // End of arange group

  group('linspace creation tests', () {
    test('linspace basic (endpoint=true)', () {
      var nd = linspace(0, 1, num: 5);
      expect(nd.shape, equals([5]));
      expect(nd.dtype, equals(double));
      expect(nd.data, isA<Float64List>());
      expect((nd.data as Float64List)[0], closeTo(0.0, 1e-9));
      expect((nd.data as Float64List)[1], closeTo(0.25, 1e-9));
      expect((nd.data as Float64List)[2], closeTo(0.5, 1e-9));
      expect((nd.data as Float64List)[3], closeTo(0.75, 1e-9));
      expect((nd.data as Float64List)[4], closeTo(1.0, 1e-9));
    });

    test('linspace endpoint=false', () {
      var nd = linspace(0, 1, num: 5, endpoint: false);
      expect(nd.shape, equals([5]));
      expect(nd.dtype, equals(double));
      expect(nd.data, isA<Float64List>());
      expect((nd.data as Float64List)[0], closeTo(0.0, 1e-9));
      expect((nd.data as Float64List)[1], closeTo(0.2, 1e-9));
      expect((nd.data as Float64List)[2], closeTo(0.4, 1e-9));
      expect((nd.data as Float64List)[3], closeTo(0.6, 1e-9));
      expect((nd.data as Float64List)[4], closeTo(0.8, 1e-9));
    });

    test('linspace with num=1', () {
      var nd = linspace(10, 20, num: 1);
      expect(nd.shape, equals([1]));
      expect(nd.dtype, equals(double));
      expect(nd.data, isA<Float64List>());
      expect((nd.data as Float64List)[0], closeTo(10.0, 1e-9));
    });

    test('linspace with num=0', () {
      var nd = linspace(0, 1, num: 0);
      expect(nd.shape, equals([0]));
      expect(nd.size, equals(0));
      expect(nd.dtype, equals(double));
      expect(nd.data, isA<Float64List>());
      expect((nd.data as Float64List).length, equals(0));
    });

    test('linspace with negative num throws error', () {
      expect(() => linspace(0, 1, num: -1), throwsArgumentError);
    });

    test('linspace with explicit dtype (int)', () {
      var nd = linspace(0, 4, num: 5, dtype: Int32List);
      expect(nd.shape, equals([5]));
      expect(nd.dtype, equals(int)); // Check primitive type
      expect(nd.data, isA<Int32List>());
      expect(nd.data, equals(Int32List.fromList([0, 1, 2, 3, 4])));
    });

    test('linspace with start > stop', () {
      var nd = linspace(1, 0, num: 5);
      expect(nd.shape, equals([5]));
      expect((nd.data as Float64List)[0], closeTo(1.0, 1e-9));
      expect((nd.data as Float64List)[1], closeTo(0.75, 1e-9));
      expect((nd.data as Float64List)[4], closeTo(0.0, 1e-9));
    });
  }); // End of linspace group
} // End of main
