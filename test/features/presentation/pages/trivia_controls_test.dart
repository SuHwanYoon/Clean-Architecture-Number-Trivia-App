import 'package:clean_architecture_app/core/usecases/usecase.dart';
import 'package:clean_architecture_app/core/util/input_converter.dart';
import 'package:clean_architecture_app/core/util/result.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_app/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_architecture_app/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:clean_architecture_app/features/number_trivia/presentation/pages/number_trivia_page.dart';
import 'package:clean_architecture_app/features/number_trivia/presentation/widgets/message_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

void main() {
  late MockGetConcreteNumberTrivia concreteTrivia;
  late MockGetRandomNumberTrivia randomTrivia;
  late NumberTriviaBloc bloc;

  setUpAll(() {
    registerFallbackValue(const Params(number: 0));
    registerFallbackValue(NoParams());
  });

  setUp(() {
    concreteTrivia = MockGetConcreteNumberTrivia();
    randomTrivia = MockGetRandomNumberTrivia();
    bloc = NumberTriviaBloc(
      getConcreteNumberTrivia: concreteTrivia,
      getRandomNumberTrivia: randomTrivia,
      inputConverter: InputConverter(),
    );
  });

  tearDown(() async {
    await bloc.close();
  });

  Future<void> pumpControls(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider.value(
          value: bloc,
          child: Scaffold(
            body: Column(
              children: [
                BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
                  builder: (context, state) => MessageDisplay(
                    message: state is Error
                        ? state.message
                        : 'Start searching!',
                  ),
                ),
                const TriviaControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  for (final width in [320.0, 800.0]) {
    testWidgets('Buttons are larger without overflow at width $width', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = Size(width, 800);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);
      await pumpControls(tester);

      final buttons = find.byType(ElevatedButton);
      expect(buttons, findsNWidgets(2));
      for (var index = 0; index < 2; index++) {
        final button = buttons.at(index);
        expect(tester.getSize(button).height, greaterThanOrEqualTo(56));
        final label = find.descendant(of: button, matching: find.byType(Text));
        final context = tester.element(label);
        expect(DefaultTextStyle.of(context).style.fontSize, 18);
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Random button has a contrasting background and readable text', (
    tester,
  ) async {
    await pumpControls(tester);
    final finder = find.widgetWithText(ElevatedButton, 'Get Random Trivia');
    final button = tester.widget<ElevatedButton>(finder);
    final theme = Theme.of(tester.element(finder));
    final background = button.style!.backgroundColor!.resolve({});
    final foreground = button.style!.foregroundColor!.resolve({});

    expect(background, theme.colorScheme.secondary);
    expect(foreground, theme.colorScheme.onSecondary);
    expect(background, isNot(theme.scaffoldBackgroundColor));
    final luminances = [
      background!.computeLuminance(),
      foreground!.computeLuminance(),
    ]..sort();
    expect(
      (luminances.last + 0.05) / (luminances.first + 0.05),
      greaterThanOrEqualTo(4.5),
    );
  });

  for (final input in ['', 'abc', '1.5', '-1']) {
    testWidgets('Search displays an input error for "$input"', (tester) async {
      await pumpControls(tester);
      if (input.isNotEmpty) {
        await tester.enterText(find.byType(TextField), input);
      }

      await tester.runAsync(() async {
        final result = bloc.stream.firstWhere((state) => state is Error);
        await tester.tap(find.text('Search'));
        await result.timeout(const Duration(seconds: 5));
      });
      await tester.pumpAndSettle();

      expect(find.text(INVALID_INPUT_FAILURE_MESSAGE), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '',
      );
      verifyZeroInteractions(concreteTrivia);
      verifyZeroInteractions(randomTrivia);
    });
  }

  for (final number in [0, 42]) {
    testWidgets('Search requests trivia for $number', (tester) async {
      final trivia = NumberTrivia(number: number, text: 'Test trivia');
      when(() => concreteTrivia(any()))
          .thenAnswer((_) async => Success(trivia));
      await pumpControls(tester);
      await tester.enterText(find.byType(TextField), '$number');

      await tester.runAsync(() async {
        final result = bloc.stream.firstWhere((state) => state is Loaded);
        await tester.tap(find.text('Search'));
        await result.timeout(const Duration(seconds: 5));
      });
      await tester.pumpAndSettle();

      verify(() => concreteTrivia(Params(number: number))).called(1);
      expect(bloc.state, Loaded(trivia));
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '',
      );
      verifyZeroInteractions(randomTrivia);
    });
  }

  testWidgets('Search does not reuse the cleared input', (tester) async {
    const trivia = NumberTrivia(number: 42, text: 'Test trivia');
    when(() => concreteTrivia(any())).thenAnswer((_) async => Success(trivia));
    await pumpControls(tester);
    await tester.enterText(find.byType(TextField), '42');

    await tester.runAsync(() async {
      final result = bloc.stream.firstWhere((state) => state is Loaded);
      await tester.tap(find.text('Search'));
      await result.timeout(const Duration(seconds: 5));
    });
    await tester.pumpAndSettle();
    verify(() => concreteTrivia(const Params(number: 42))).called(1);

    await tester.runAsync(() async {
      final result = bloc.stream.firstWhere((state) => state is Error);
      await tester.tap(find.text('Search'));
      await result.timeout(const Duration(seconds: 5));
    });
    await tester.pumpAndSettle();

    expect(find.text(INVALID_INPUT_FAILURE_MESSAGE), findsOneWidget);
    verifyNoMoreInteractions(concreteTrivia);
  });

  testWidgets('Random search works without input', (tester) async {
    const trivia = NumberTrivia(number: 42, text: 'Random trivia');
    when(() => randomTrivia(any())).thenAnswer((_) async => Success(trivia));
    await pumpControls(tester);

    await tester.runAsync(() async {
      final result = bloc.stream.firstWhere((state) => state is Loaded);
      await tester.tap(find.text('Get Random Trivia'));
      await result.timeout(const Duration(seconds: 5));
    });
    await tester.pumpAndSettle();

    verify(() => randomTrivia(NoParams())).called(1);
    expect(bloc.state, Loaded(trivia));
    verifyZeroInteractions(concreteTrivia);
  });
}
