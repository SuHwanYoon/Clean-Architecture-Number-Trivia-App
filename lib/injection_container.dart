import 'package:clean_architecture_app/core/network/network_info.dart';
import 'package:clean_architecture_app/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:clean_architecture_app/features/number_trivia/data/datasources/number_trivia_local_data_source.dart';
import 'package:clean_architecture_app/features/number_trivia/data/repositories/number_trivia_reposiotry_impl.dart';
import 'package:clean_architecture_app/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_architecture_app/core/util/input_converter.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

// GetIt의 전역 인스턴스를 서비스 로케이터로 사용합니다.
// 의존성을 여기 등록해 두면 필요한 객체를 생성자에 직접 전달하지 않고도 가져올 수 있습니다.
final serviceLocator = GetIt.instance;

Future<void> init() async {
  // 앱에서 사용할 객체와 그 객체가 의존하는 항목을 서비스 로케이터에 연결합니다.
  // 등록 시점에는 생성 함수만 저장하고, 실제 객체 생성은 아래 등록 방식에 따라 이뤄집니다.

  // Bloc은 화면이나 기능의 상태를 관리하므로 요청할 때마다 새 인스턴스를 만듭니다.
  // 생성자 매개변수는 아래에 등록한 UseCase와 InputConverter를 로케이터에서 찾아 주입합니다.
  // registerFactory를 사용하여 매번 새로운 Bloc 인스턴스를 생성하도록 합니다.
  serviceLocator.registerFactory(
    () => NumberTriviaBloc(
      getConcreteNumberTrivia: serviceLocator(),
      getRandomNumberTrivia: serviceLocator(),
      inputConverter: serviceLocator(),
    ),
  );

  // UseCase는 저장소를 호출해 기능별 작업을 수행합니다.
  // 처음 요청될 때 한 번 생성한 뒤 같은 인스턴스를 재사용합니다.
  // registerLazySingleton을 사용하여 처음 요청될 때 한 번만 생성하고 이후에는 같은 인스턴스를 재사용하도록 합니다.
  serviceLocator.registerLazySingleton(
    () => GetConcreteNumberTrivia(serviceLocator()),
  );
  serviceLocator.registerLazySingleton(
    () => GetRandomNumberTrivia(serviceLocator()),
  );

  // 호출부는 구현 클래스 대신 Repository 계약에 의존하고,
  // 실제 실행 시에는 이 등록을 통해 구현체가 제공됩니다.
  serviceLocator.registerLazySingleton<NumberTriviaRepository>(
    () => NumberTriviaRepositoryImpl(
      remoteDataSource: serviceLocator(),
      localDataSource: serviceLocator(),
      networkInfo: serviceLocator(),
    ),
  );
  // Data sources등록 코드
  serviceLocator.registerLazySingleton<NumberTriviaRemoteDataSource>(
    () => NumberTriviaRemoteDataSourceImpl(client: serviceLocator()),
  );
  serviceLocator.registerLazySingleton<NumberTriviaLocalDataSource>(
    () => NumberTriviaLocalDataSourceImpl(sharedPreferences: serviceLocator()),
  );

  // Core 등록
  // 입력 변환기는 여러 기능에서 공유할 수 있는 핵심 도구이므로
  // 처음 요청될 때 생성하고 이후에는 같은 인스턴스를 사용합니다.
  serviceLocator.registerLazySingleton(() => InputConverter());
  serviceLocator.registerLazySingleton<NetworkInfo>(
    () => NetworkInfoImpl(internetConnectionChecker: serviceLocator()),
  );

  // 외부 라이브러리 등록
  final sharedPreferences = await SharedPreferences.getInstance();
  serviceLocator.registerLazySingleton<SharedPreferences>(
    () => sharedPreferences,
  );
  serviceLocator.registerLazySingleton<Dio>(() => Dio());
  serviceLocator.registerLazySingleton<InternetConnection>(
    () => InternetConnection(),
  );
}
