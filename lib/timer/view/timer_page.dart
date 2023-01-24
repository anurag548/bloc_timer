import 'package:bloc_timer/ticker.dart';
import 'package:bloc_timer/timer/bloc/timer_bloc.dart';
import 'package:bloc_timer/timer/timer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TimerPage extends StatelessWidget {
  const TimerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TimerBloc(ticker: const Ticker()),
      child: const TimerView(),
    );
  }
}

class TimerView extends StatelessWidget {
  const TimerView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          title: const Text('Timer'),
        ),
        body: Stack(children: [
          const Background(),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 100.0),
                child: TimerText(),
              ),
              Actions(),
            ],
          ),
        ]),
      ),
    );
  }
}

class TimerText extends StatelessWidget {
  const TimerText({super.key});

  @override
  Widget build(BuildContext context) {
    final duration = context.select((TimerBloc bloc) => bloc.state.duration);

    final minutesStr =
        ((duration / 60) % 60).floor().toString().padLeft(2, '0');
    final secondsStr = (duration % 60).floor().toString().padLeft(2, '0');
    return Text(
      '$minutesStr:$secondsStr',
      style: Theme.of(context).textTheme.headline1,
    );
  }
}

class Actions extends StatelessWidget {
  const Actions({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TimerBloc, TimerState>(
      buildWhen: ((previous, current) =>
          previous.runtimeType != current.runtimeType),
      builder: ((context, state) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (state is TimerInitial) ...[
                FloatingActionButton(
                  child: const Icon(Icons.play_arrow),
                  onPressed: () => context.read<TimerBloc>().add(
                        TimerStarted(duration: state.duration),
                      ),
                ),
              ],
              if (state is TimerRunInProgress) ...[
                FloatingActionButton(
                    child: const Icon(Icons.pause),
                    onPressed: () =>
                        context.read<TimerBloc>().add(const TimerPaused())),
                FloatingActionButton(
                  onPressed: () =>
                      context.read<TimerBloc>().add(const TimerReset()),
                  child: const Icon(Icons.restore),
                ),
              ],
              if (state is TimerRunPause) ...[
                FloatingActionButton(
                  onPressed: () =>
                      context.read<TimerBloc>().add(const TimerResumed()),
                  child: const Icon(Icons.play_arrow),
                ),
                FloatingActionButton(
                  onPressed: () =>
                      context.read<TimerBloc>().add(const TimerReset()),
                  child: const Icon(Icons.restore),
                )
              ],
              if (state is TimerComplete) ...[
                FloatingActionButton(
                  onPressed: () => context.read<TimerBloc>().add(
                        const TimerReset(),
                      ),
                )
              ]
            ],
          )),
    );
  }
}
