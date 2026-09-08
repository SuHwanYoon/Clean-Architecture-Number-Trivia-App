abstract class NumberTriviaRemoteDataSource {
  /// Calls the http://numbersapi.com/[number] endpoint to get trivia for the given [number].
  ///
  /// Throws a [ServerException] for all error codes.
  Future<String> getConcreteNumberTrivia(int number);

  /// Calls the http://numbersapi.com/random endpoint to get trivia for a random number.
  ///
  /// Throws a [ServerException] for all error codes.
  Future<String> getRandomNumberTrivia();
}
