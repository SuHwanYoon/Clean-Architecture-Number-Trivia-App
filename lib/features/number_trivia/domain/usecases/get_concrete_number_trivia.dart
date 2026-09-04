import 'package:clean_architecture_app/core/error/failures.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:dartz/dartz.dart';

// GetConcreteNumberTrivia는 특정 숫자에 대한 퀴즈를 가져오는 유스케이스를 나타내는 클래스입니다.
// usecase의 역할은 도메인 계층에서 비즈니스 로직을 수행하는 것입니다.
// 이 클래스는 NumberTriviaRepository를 의존성으로 받아, 해당 리포지토리에서 데이터를 가져오는 역할을 수행합니다.
class GetConcreteNumberTrivia {
  // Test cases for GetConcreteNumberTrivia use case will be implemented here.

  final NumberTriviaRepository repository;

  GetConcreteNumberTrivia(this.repository);

  //Future는 비동기 작업을 나타내며, Either<Failure, NumberTrivia>는 실패(Failure) 또는 성공(NumberTrivia) 결과를 반환할 수 있음을 의미합니다.
  //Either는 dartz 패키지에서 제공하는 타입으로, 두 가지 가능한 결과 중 하나를 나타낼 수 있습니다. 왼쪽은 실패(Failure), 오른쪽은 성공(NumberTrivia)를 의미합니다.
  //call 메서드는 특정 숫자에 대한 퀴즈를 가져오는 역할을 합니다. 매개변수로 int 타입의 number를
  // 받습니다. 이 메서드는 비동기적으로 동작하며, 결과를 Future로 반환합니다.
  Future<Either<Failure, NumberTrivia>> call({required int number}) async {
    return await repository.getConcreteNumberTrivia(number);
  }
}
