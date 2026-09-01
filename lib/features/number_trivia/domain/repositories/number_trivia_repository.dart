import 'package:dartz/dartz.dart';
import 'package:clean_architecture_app/core/error/failures.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/entities/number_trivia.dart';

// NumberTriviaRepository는 도메인 계층에서 숫자 퀴즈 관련 데이터를 가져오는 역할을 하는 추상 클래스입니다.
// 추상클래스로 정의하는 이유는 실제 구현은 데이터 소스에 따라 달라질 수 있기 때문입니다. 따라서 인터페이스 역할을 수행합니다.
abstract class NumberTriviaRepository {
  // Future는 비동기 작업을 나타내며, Either<Failure, NumberTrivia>는 실패(Failure) 또는 성공(NumberTrivia) 결과를 반환할 수 있음을 의미합니다.
  // Either는 dartz 패키지에서 제공하는 타입으로, 두 가지 가능한 결과 중 하나를 나타낼 수 있습니다. 왼쪽은 실패(Failure), 오른쪽은 성공(NumberTrivia)를 의미합니다.

  // getConcreteNumberTrivia 메서드는 특정 숫자에 대한 퀴즈를 가져오는 역할을 합니다. 매개변수로 int 타입의 number를 받습니다.
  // getRandomNumberTrivia 메서드는 랜덤한 숫자에 대한 퀴즈를 가져오는 역할을 합니다. 매개변수는 필요하지 않습니다.
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(int number);
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia();
}
