import 'dart:convert';

import 'package:clean_architecture_app/core/error/exceptions.dart';
import 'package:clean_architecture_app/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class NumberTriviaLocalDataSource {
  // 로컬 데이터 소스에서 마지막으로 캐시된 숫자 정보를 가져오는 메서드를 정의합니다.
  Future<NumberTriviaModel> getLastNumberTrivia();

  // 캐시된 데이터를 가져오는 메서드와 데이터를 캐시에 저장하는 메서드를 정의합니다.
  Future<void> cacheNumberTrivia(NumberTriviaModel triviaToCache);
}

// CACHE KEY FOR NUMBER TRIVIA는 public으로 정의되어 있어 다른 파일에서도 사용할 수 있습니다.
// public으로 간주되는 이유는 _로 시작하지 않았으며 top-level에 정의되어 있기 때문입니다.
const CACHED_NUMBER_TRIVIA = "CACHED_NUMBER_TRIVIA";

class NumberTriviaLocalDataSourceImpl implements NumberTriviaLocalDataSource {
  final SharedPreferences sharedPreferences;

  NumberTriviaLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<NumberTriviaModel> getLastNumberTrivia() {
    // SharedPreferences에서 "CACHED_NUMBER_TRIVIA" 키로 저장된 JSON 문자열을 가져옵니다.
    // JSON 문자열을 가져옵니다.
    // JSON 문자열이 null이 아닌 경우, 이를 디코딩하여 NumberTriviaModel로 변환합니다.
    final jsonString = sharedPreferences.getString(CACHED_NUMBER_TRIVIA);
    if (jsonString != null) {
      return Future.value(NumberTriviaModel.fromJson(json.decode(jsonString)));
    } else {
      throw CacheException();
    }
  }

  @override
  Future<void> cacheNumberTrivia(NumberTriviaModel triviaToCache) async {
    await sharedPreferences.setString(
      CACHED_NUMBER_TRIVIA,
      json.encode(triviaToCache.toJson()),
    );
  }
}
