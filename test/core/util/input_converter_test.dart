import 'package:clean_architecture_app/core/error/failures.dart';
import 'package:clean_architecture_app/core/util/input_converter.dart';
import 'package:clean_architecture_app/core/util/result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InputConverter inputConverter;

  setUp(() {
    inputConverter = InputConverter();
  });

  group('stringToUnsignedInt', () {
    // 이 테스트 케이스는 문자열이 부호 없는 정수를 나타낼 때 Success를 반환하는지 확인합니다.
    test(
      'should return Success when the string represents an unsigned integer',
      () {
        // arrange
        final str = '123';

        // act
        final result = inputConverter.stringToUnsignedInteger(str);

        // assert
        expect(result, Success<int, Failure>(123));
      },
    );
    // 이 테스트 케이스는 문자열이 부호 없는 정수를 나타내지 않을 때 FailureResult를 반환하는지 확인합니다.
    test(
      'should return FailureResult when the string is not an unsigned integer',
      () {
        // arrange
        final str = 'abc';

        // act
        final result = inputConverter.stringToUnsignedInteger(str);

        // assert
        expect(result, FailureResult<int, Failure>(InvalidInputFailure()));
      },
    );

    // 문자열이 마이너스 정수를 나타낼 때 FailureResult를 반환하는지 확인합니다。
    test('should return FailureResult when the string represents a negative integer', () {
      // arrange
      final str = '-123';

      // act
      final result = inputConverter.stringToUnsignedInteger(str);

      // assert
      expect(result, FailureResult<int, Failure>(InvalidInputFailure()));
    });
  });
}
