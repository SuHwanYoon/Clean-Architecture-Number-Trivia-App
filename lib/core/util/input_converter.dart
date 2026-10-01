import 'package:clean_architecture_app/core/error/failures.dart';
import 'package:clean_architecture_app/core/util/result.dart';

class InputConverter {
  // 강의의 Either<Failure, int> 대신 Result<int, Failure> 사용
  Result<int, Failure> stringToUnsignedInteger(String str) {
    try {
      final integer = int.parse(str);
      if (integer < 0) throw const FormatException();
      return Success(integer); // 👈 강의의 Right(integer) 대신 Success!
    } on FormatException {
      return FailureResult(
        InvalidInputFailure(),
      ); // 👈 강의의 Left(...) 대신 FailureResult!
    }
  }
}

class InvalidInputFailure extends Failure {}
