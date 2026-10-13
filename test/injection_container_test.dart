import 'package:clean_architecture_app/core/network/network_info.dart';
import 'package:clean_architecture_app/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_architecture_app/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture_app/features/number_trivia/data/repositories/number_trivia_reposiotry_impl.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_architecture_app/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:clean_architecture_app/injection_container.dart' as di;
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await di.init();
  });

  tearDown(() async {
    di.serviceLocator<Dio>().close();
    await di.serviceLocator.reset();
  });

  test(
    'resolves the dependency graph and preserves instance lifetimes',
    () async {
      final preferences = di.serviceLocator<SharedPreferences>();
      final client = di.serviceLocator<Dio>();
      final connection = di.serviceLocator<InternetConnection>();
      final remote = di.serviceLocator<NumberTriviaRemoteDataSource>();
      final local = di.serviceLocator<NumberTriviaLocalDataSource>();
      final network = di.serviceLocator<NetworkInfo>();
      final repository = di.serviceLocator<NumberTriviaRepository>();

      expect(preferences, same(await SharedPreferences.getInstance()));
      expect(di.serviceLocator<Dio>(), same(client));
      expect(di.serviceLocator<InternetConnection>(), same(connection));
      expect((remote as NumberTriviaRemoteDataSourceImpl).client, same(client));
      expect(
        (local as NumberTriviaLocalDataSourceImpl).sharedPreferences,
        same(preferences),
      );
      expect(
        (network as NetworkInfoImpl).internetConnectionChecker,
        same(connection),
      );
      final repositoryImpl = repository as NumberTriviaRepositoryImpl;
      expect(repositoryImpl.remoteDataSource, same(remote));
      expect(repositoryImpl.localDataSource, same(local));
      expect(repositoryImpl.networkInfo, same(network));
      expect(di.serviceLocator<NumberTriviaRepository>(), same(repository));

      final firstBloc = di.serviceLocator<NumberTriviaBloc>();
      final secondBloc = di.serviceLocator<NumberTriviaBloc>();
      addTearDown(firstBloc.close);
      addTearDown(secondBloc.close);

      expect(secondBloc, isNot(same(firstBloc)));
      expect(
        firstBloc.getConcreteNumberTrivia,
        same(di.serviceLocator<GetConcreteNumberTrivia>()),
      );
      expect(
        firstBloc.getRandomNumberTrivia,
        same(di.serviceLocator<GetRandomNumberTrivia>()),
      );
      expect(secondBloc.inputConverter, same(firstBloc.inputConverter));
    },
  );
}
