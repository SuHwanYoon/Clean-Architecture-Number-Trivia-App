import 'package:clean_architecture_app/core/error/exceptions.dart';
import 'package:clean_architecture_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:dio/dio.dart';

abstract class NumberTriviaRemoteDataSource {
  /// Calls the http://number-trivia.com/[number] endpoint to get trivia for the given [number].
  ///
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number);

  /// Calls the http://number-trivia.com/random endpoint to get trivia for a random number.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<NumberTriviaModel> getRandomNumberTrivia();
}

class NumberTriviaRemoteDataSourceImpl implements NumberTriviaRemoteDataSource {
  // 구현에 사용할 dio 인스턴스
  final Dio client;
  // 생성자에서 dio 인스턴스를 주입받음
  // 생성자에 dio인스턴스를 주입하는 이유는 테스트 용이성과 의존성 주입을 위해서이다.
  // 생성자에 주입된 인스턴스는 해당 클래스가 생성될때 사용된다.
  NumberTriviaRemoteDataSourceImpl({required this.client});

  @override
  Future<NumberTriviaModel> getConcreteNumberTrivia(int number) async {
    return _getTrivia('http://number-trivia.com/$number');
  }

  @override
  Future<NumberTriviaModel> getRandomNumberTrivia() async {
    return _getTrivia('http://number-trivia.com/random');
  }

  // _getTrivia는 주어진 URL로 HTTP GET 요청을 보내고, 응답을 NumberTriviaModel로 변환합니다.
  Future<NumberTriviaModel> _getTrivia(String url) async {
    // response는 Dio의 get() 메서드 호출 결과로 반환된 HTTP 응답입니다.
    // options에는 HTTP 요청 헤더를 설정합니다. 여기서는 Content-Type을 application/json으로 설정합니다.
    final response = await client.get(
      url,
      options: Options(headers: {'Content-Type': 'application/json'}),
    );
    // HTTP 응답 상태 코드가 200이면 성공으로 간주하고 JSON 데이터를 파싱합니다.
    if (response.statusCode == 200) {
      //response.data는 서버에서 반환된 JSON 데이터입니다. 이를 NumberTriviaModel로 변환합니다.
      return NumberTriviaModel.fromJson(response.data);
    } else {
      throw ServerException();
    }
  }
}
