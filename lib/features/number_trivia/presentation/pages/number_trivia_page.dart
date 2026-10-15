import 'package:clean_architecture_app/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:clean_architecture_app/features/number_trivia/presentation/widgets/loading_widget.dart';
import 'package:clean_architecture_app/features/number_trivia/presentation/widgets/message_display.dart';
import 'package:clean_architecture_app/features/number_trivia/presentation/widgets/trivia_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clean_architecture_app/injection_container.dart';

class NumberTriviaPage extends StatelessWidget {
  const NumberTriviaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Number Trivia')),
      body: buildBody(context),
    );
  }

  BlocProvider<NumberTriviaBloc> buildBody(BuildContext context) {
    return BlocProvider(
      create: (_) => serviceLocator<NumberTriviaBloc>(),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.03),
            BlocBuilder<NumberTriviaBloc, NumberTriviaState>(
              builder: (context, state) {
                // 상태에 따라 화면에 표시할 위젯을 분기별로 처리
                // Empty: 초기 상태, 메시지 표시
                // Loading: 로딩 중, 로딩 위젯 표시
                // Loaded: 데이터 로드 완료, 메시지 표시
                // Error: 에러 발생, 에러 메시지 표시
                switch (state.runtimeType) {
                  case Empty:
                    return MessageDisplay();
                  case Loading:
                    return const LoadingWidget();
                  case Loaded:
                    return TriviaDisplay(
                      numberTrivia: (state as Loaded).numberTrivia,
                    );
                  case Error:
                    return MessageDisplay(message: (state as Error).message);
                  default:
                    return const SizedBox.shrink();
                }
              },
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.08),
            TriviaControls(),
          ],
        ),
      ),
    );
  }
}

class TriviaControls extends StatefulWidget {
  const new({super.key});

  @override
  State<TriviaControls> createState() => _TriviaControlsState();
}

class _TriviaControlsState extends State<TriviaControls> {
  final _inputController = TextEditingController();

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: _inputController,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Enter a number',
          ),
          keyboardType: TextInputType.number,
        ),
        SizedBox(height: MediaQuery.of(context).size.height * 0.02),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 56),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  foregroundColor: Colors.white,
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                onPressed: dispatchSearchTrivia,
                child: const Text('Search', textAlign: TextAlign.center),
              ),
            ),
            SizedBox(width: MediaQuery.of(context).size.width * 0.02),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 56),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
                onPressed: () {
                  _getRandomTrivia();
                },
                child: const Text('Get Random Trivia', textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void dispatchSearchTrivia() {
    context.read<NumberTriviaBloc>().add(
      GetTriviaForConcreteNumber(_inputController.text),
    );
    _inputController.clear();
  }

  void _getRandomTrivia() {
    // Bloc를 사용하여 랜덤 트리비아 검색 이벤트를 디스패치
    context.read<NumberTriviaBloc>().add(GetTriviaForRandomNumber());
  }
}
