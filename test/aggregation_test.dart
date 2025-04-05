import 'package:test/test.dart';
import 'package:numdart/numdart.dart';
import 'dart:typed_data'; // For dtype comparison

void main() {
  group('NdArray Aggregation Tests - sum()', () {
    test('1D Integer Array Sum', () {
      var a = NdArray.array([1, 2, 3, 4, 5]);
      expect(a.sum(), equals(15));
      expect(a.sum().runtimeType, equals(int));
    });

    test('1D Double Array Sum', () {
      var a = NdArray.array([1.5, 2.5, 3.5]);
      expect(a.sum(), closeTo(7.5, 1e-9));
      expect(a.sum().runtimeType, equals(double));
    });

    test('2D Integer Array Sum', () {
      var a = NdArray.array([
        [1, 2],
        [3, 4]
      ]);
      expect(a.sum(), equals(10));
      expect(a.sum().runtimeType, equals(int));
    });

    test('2D Double Array Sum', () {
      var a = NdArray.array([
        [1.1, 2.2],
        [3.3, 4.4]
      ]);
      expect(a.sum(), closeTo(11.0, 1e-9));
      expect(a.sum().runtimeType, equals(double));
    });

    test('Empty Array Sum', () {
      var a = NdArray.zeros([2, 0], dtype: Int64List);
      expect(a.sum(), equals(0));
      expect(a.sum().runtimeType, equals(int));

      var b = NdArray.zeros([0, 3], dtype: Float64List);
      expect(b.sum(), equals(0.0));
      expect(b.sum().runtimeType, equals(double));
    });

    test('Sum of a View (Slice)', () {
      var a = NdArray.arange(10); // [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
      var view = a[[Slice(2, 7, 2)]]; // Wrap Slice in a list for 1D array
      expect(view.sum(), equals(12));
      expect(view.sum().runtimeType, equals(int));

      var b = NdArray.arange(10, dtype: Float64List);
      var viewB = b[[Slice(1, 5)]]; // Wrap Slice in a list for 1D array
      expect(viewB.sum(), closeTo(10.0, 1e-9));
      expect(viewB.sum().runtimeType, equals(double));
    });

    test('Scalar (0D) Array Sum', () {
      var a = NdArray.array([5]); // Wrap scalar in a list for array creation
      expect(a.sum(), equals(5));
      expect(a.sum().runtimeType, equals(int));

      var b = NdArray.array([3.14]); // Wrap scalar in a list for array creation
      expect(b.sum(), closeTo(3.14, 1e-9));
      expect(b.sum().runtimeType, equals(double));
    });

    // TODO: Add tests for mean, max, min

    group('NdArray Aggregation Tests - mean()', () {
      test('1D Integer Array Mean', () {
        var a = NdArray.array([1, 2, 3, 4, 5]);
        expect(a.mean(), closeTo(3.0, 1e-9));
      });

      test('1D Double Array Mean', () {
        var a = NdArray.array([1.5, 2.5, 3.5, 4.5]);
        expect(a.mean(), closeTo(3.0, 1e-9));
      });

      test('2D Integer Array Mean', () {
        var a = NdArray.array([
          [1, 2],
          [3, 4]
        ]);
        expect(a.mean(), closeTo(2.5, 1e-9));
      });

      test('2D Double Array Mean', () {
        var a = NdArray.array([
          [1.1, 2.2],
          [3.3, 4.4]
        ]);
        expect(a.mean(), closeTo(2.75, 1e-9));
      });

      test('Empty Array Mean', () {
        var a = NdArray.zeros([2, 0]);
        expect(a.mean().isNaN, isTrue);

        var b = NdArray.zeros([0]);
        expect(b.mean().isNaN, isTrue);
      });

      test('Mean of a View (Slice)', () {
        var a = NdArray.arange(10); // [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
        var view = a[[Slice(2, 7, 2)]]; // [2, 4, 6]
        expect(view.mean(), closeTo(4.0, 1e-9));

        var b = NdArray.arange(10, dtype: Float64List);
        var viewB = b[[Slice(1, 5)]]; // [1.0, 2.0, 3.0, 4.0]
        expect(viewB.mean(), closeTo(2.5, 1e-9));
      });

      test('Scalar (0D) Array Mean', () {
        var a = NdArray.array([5]);
        expect(a.mean(), closeTo(5.0, 1e-9));

        var b = NdArray.array([3.14]);
        expect(b.mean(), closeTo(3.14, 1e-9));
      });

      // TODO: Add tests for max, min

      group('NdArray Aggregation Tests - max()', () {
        test('1D Integer Array Max', () {
          var a = NdArray.array([1, 5, 2, 4, 3]);
          expect(a.max(), equals(5));
        });

        test('1D Double Array Max', () {
          var a = NdArray.array([1.5, -2.5, 3.5, 0.0]);
          expect(a.max(), closeTo(3.5, 1e-9));
        });

        test('2D Integer Array Max', () {
          var a = NdArray.array([
            [1, 2],
            [5, 4]
          ]);
          expect(a.max(), equals(5));
        });

        test('2D Double Array Max', () {
          var a = NdArray.array([
            [1.1, -2.2],
            [3.3, 4.4]
          ]);
          expect(a.max(), closeTo(4.4, 1e-9));
        });

        test('Empty Array Max', () {
          var a = NdArray.zeros([2, 0]);
          expect(() => a.max(), throwsStateError);

          var b = NdArray.zeros([0]);
          expect(() => b.max(), throwsStateError);
        });

        test('Max of a View (Slice)', () {
          var a = NdArray.array([0, 1, 9, 3, 8, 5, 6, 7, 2, 4]);
          var view = a[[Slice(2, 7, 2)]]; // [9, 8, 6]
          expect(view.max(), equals(9));

          var b = NdArray.array([0.0, 1.1, 9.9, 3.3, 8.8], dtype: Float64List);
          var viewB = b[[Slice(1, 4)]]; // [1.1, 9.9, 3.3]
          expect(viewB.max(), closeTo(9.9, 1e-9));
        });

        test('Scalar (0D) Array Max', () {
          var a = NdArray.array([5]);
          expect(a.max(), equals(5));

          var b = NdArray.array([3.14]);
          expect(b.max(), closeTo(3.14, 1e-9));
        });

        // TODO: Add tests for min

        group('NdArray Aggregation Tests - min()', () {
          test('1D Integer Array Min', () {
            var a = NdArray.array([1, 5, 0, 4, 3]);
            expect(a.min(), equals(0));
          });

          test('1D Double Array Min', () {
            var a = NdArray.array([1.5, -2.5, 3.5, 0.0]);
            expect(a.min(), closeTo(-2.5, 1e-9));
          });

          test('2D Integer Array Min', () {
            var a = NdArray.array([
              [1, 2],
              [-5, 4]
            ]);
            expect(a.min(), equals(-5));
          });

          test('2D Double Array Min', () {
            var a = NdArray.array([
              [1.1, -2.2],
              [3.3, -4.4]
            ]);
            expect(a.min(), closeTo(-4.4, 1e-9));
          });

          test('Empty Array Min', () {
            var a = NdArray.zeros([2, 0]);
            expect(() => a.min(), throwsStateError);

            var b = NdArray.zeros([0]);
            expect(() => b.min(), throwsStateError);
          });

          test('Min of a View (Slice)', () {
            var a = NdArray.array([0, 1, 9, 3, 8, 5, 6, 7, 2, 4]);
            var view = a[[Slice(2, 7, 2)]]; // [9, 8, 6]
            expect(view.min(), equals(6));

            var b =
                NdArray.array([0.0, 1.1, 9.9, -3.3, 8.8], dtype: Float64List);
            var viewB = b[[Slice(1, 4)]]; // [1.1, 9.9, -3.3]
            expect(viewB.min(), closeTo(-3.3, 1e-9));
          });

          test('Scalar (0D) Array Min', () {
            var a = NdArray.array([5]);
            expect(a.min(), equals(5));

            var b = NdArray.array([3.14]);
            expect(b.min(), closeTo(3.14, 1e-9));
          });
        });
      });
    });
  });
}
