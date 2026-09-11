import 'package:clean_architecture_app/features/number_trivia/data/models/number_trivia_model.dart';

abstract class NumberTriviaLocalDataSource {
  // 로컬 데이터 소스에서 마지막으로 캐시된 숫자 정보를 가져오는 메서드를 정의합니다.
  Future<NumberTriviaModel> getLastNumberTrivia();

  // 캐시된 데이터를 가져오는 메서드와 데이터를 캐시에 저장하는 메서드를 정의합니다.
  Future<void> cacheNumberTrivia(NumberTriviaModel triviaToCache);
}
