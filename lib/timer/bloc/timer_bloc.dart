import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:bloc_timer/ticker.dart';
import 'package:equatable/equatable.dart';
part 'timer_event.dart';
part 'timer_state.dart';

class TimerBloc extends Bloc<TimerEvent, TimerState> {
  static const int _duration = 60;
  final Ticker _ticker;

  StreamSubscription<int>? _tickerSub;
  TimerBloc({required Ticker ticker})
      : _ticker = ticker,
        super(TimerInitial(_duration)) {
    on<TimerStarted>(_onStarted);
    on<TimerReset>(_onReset);
    on<TimerPaused>(_onPaused);
    on<TimerResumed>(_onResumed);
    on<_TimerTicked>(_onTicker);
  }

  @override
  Future<void> close() {
    _tickerSub?.cancel();
    return super.close();
  }

  void _onStarted(TimerStarted event, Emitter<TimerState> emit) {
    emit(TimerRunInProgress(event.duration));
    _tickerSub?.cancel();
    _tickerSub = _ticker.tick(ticks: event.duration).listen(
        (remaininDuration) => add(_TimerTicked(duration: remaininDuration)));
  }

  void _onTicker(_TimerTicked event, Emitter<TimerState> emit) {
    emit(
      event.duration > 1
          ? TimerRunInProgress(event.duration)
          : const TimerComplete(),
    );
  }

  void _onPaused(TimerPaused event, Emitter<TimerState> emit) {
    if (state is TimerRunInProgress) {
      _tickerSub?.pause();
      emit(TimerRunPause(state.duration));
    }
  }

  void _onResumed(TimerResumed event, Emitter<TimerState> emit) {
    if (state is TimerRunPause) {
      _tickerSub?.resume();
      emit(TimerRunInProgress(state.duration));
    }
  }

  void _onReset(TimerReset event, Emitter<TimerState> emit) {
    _tickerSub?.cancel();
    emit(const TimerInitial(_duration));
  }
}
