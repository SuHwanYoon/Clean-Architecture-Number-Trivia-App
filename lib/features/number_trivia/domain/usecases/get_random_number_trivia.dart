import 'package:clean_architecture_app/core/error/failures.dart';
import 'package:clean_architecture_app/core/usecases/usecase.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:dartz/dartz.dart';

// GetConcreteNumberTrivia는 특정 숫자에 대한 퀴즈를 가져오는 유스케이스를 나타내는 클래스입니다.
// usecase의 역할은 도메인 계층에서 비즈니스 로직을 수행하는 것입니다.
// 이 클래스는 NumberTriviaRepository를 의존성으로 받아, 해당 리포지토리에서 데이터를 가져오는 역할을 수행합니다.
// 여기서 UseCase의 type이 NumberTrivia이고, Params가 int 타입의 number가 되는이유는
// GetConcreteNumberTrivia 유스케이스가 특정 숫자에 대한 퀴즈를 가져오는 역할을 수행하기 때문입니다.
class GetRandomNumberTrivia implements UseCase<NumberTrivia, NoParams> {
  // Test cases for GetConcreteNumberTrivia use case will be implemented here.
  final NumberTriviaRepository repository;

  GetRandomNumberTrivia(this.repository);

  @override
  Future<Either<Failure, NumberTrivia>> call(NoParams params) async {
    return await repository.getRandomNumberTrivia();
  }
}
