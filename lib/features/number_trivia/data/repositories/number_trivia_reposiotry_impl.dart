import 'package:clean_architecture_app/core/error/exceptions.dart';
import 'package:clean_architecture_app/core/error/failures.dart';
import 'package:clean_architecture_app/core/network/network_info.dart';
import 'package:clean_architecture_app/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_architecture_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:clean_architecture_app/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:dartz/dartz.dart';

// 중복코드를 줄이기 위해서 typedef alias로 원격 데이터 소스에서 숫자 퀴즈를 가져오는 함수를 정의하고
// 이를 헬퍼 메서드 _getTrivia에서 사용합니다.
typedef _ConcreteOrRandomChooser = Future<NumberTriviaModel> Function();

// NumberTriviaRepositoryImpl는 NumberTriviaRepository를 구현하며,
// 원격 및 로컬 데이터 소스를 사용하여 숫자 퀴즈 데이터를 제공하는 클래스입니다.
class NumberTriviaRepositoryImpl implements NumberTriviaRepository {
  // NumberTriviaRepositoryImpl의 의존성으로 사용되는
  // 원격 및 로컬 데이터 소스와 네트워크 정보를 정의합니다.
  final NumberTriviaRemoteDataSource remoteDataSource;
  final NumberTriviaLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  NumberTriviaRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  // NumberTriviaRepositoryImpl의 메서드 구현 부분입니다.
  @override
  Future<Either<Failure, NumberTrivia>> getConcreteNumberTrivia(int number) {
    return _getTrivia(() => remoteDataSource.getConcreteNumberTrivia(number));
  }

  @override
  Future<Either<Failure, NumberTrivia>> getRandomNumberTrivia() {
    return _getTrivia(() => remoteDataSource.getRandomNumberTrivia());
  }

  // 중복 코드를 해결하기 위한 헬퍼 메서드 _getTrivia
  Future<Either<Failure, NumberTrivia>> _getTrivia(
    _ConcreteOrRandomChooser getTrivia,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteTrivia = await getTrivia();
        await localDataSource.cacheNumberTrivia(remoteTrivia);
        return Right(remoteTrivia);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final localTrivia = await localDataSource.getLastNumberTrivia();
        return Right(localTrivia);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
}
