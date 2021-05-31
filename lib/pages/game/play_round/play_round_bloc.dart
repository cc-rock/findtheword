import 'dart:async';

import 'package:findtheword/app/injector.dart';
import 'package:findtheword/domain/common/pair.dart';
import 'package:findtheword/domain/game/ongoing_round.dart';
import 'package:findtheword/domain/game/use_case/am_i_game_admin.dart';
import 'package:findtheword/domain/game/use_case/get_ongoing_round_updates.dart';
import 'package:findtheword/domain/game/use_case/start_round.dart';
import 'package:findtheword/domain/game/word.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'play_round_bloc.freezed.dart';
part 'play_round_bloc.g.dart';

@freezed
abstract class PlayRoundEvent with _$PlayRoundEvent {
  factory PlayRoundEvent.start() = PlayRoundStart;
  factory PlayRoundEvent.roundStarted(String letter, int startTime, List<Word> words) = RoundStarted;
  factory PlayRoundEvent.tick() = PlayRoundTick;
  factory PlayRoundEvent.wordChanged(String category, String word) = WordChanged;
  factory PlayRoundEvent.roundFinished() = RoundFinished;
}

@freezed
abstract class PlayRoundState with _$PlayRoundState {
  @JsonSerializable(explicitToJson: true)
  factory PlayRoundState(String gameId, {
    @Default(true) bool loading,
    @Default(5) int secondsToStart,
    @Default(180) int remainingSeconds,
    @Default("") String letter,
    @Default([]) List<Word> words
  }) = _PlayRoundState;
  factory PlayRoundState.fromJson(Map<String, dynamic> json) => _$PlayRoundStateFromJson(json);
}

class PlayRoundBloc extends Bloc<PlayRoundEvent, PlayRoundState> {

  final StartRound _startRound;
  final GetOngoingRoundUpdates _getUpcomingRoundUpdates;
  final AmIGameAdmin _amIGameAdmin;

  StreamSubscription<Pair<OngoingRound, List<Word>>>? _subscription;

  PlayRoundBloc(PlayRoundState initialState, this._startRound, this._getUpcomingRoundUpdates, this._amIGameAdmin): super(initialState) {
    add(PlayRoundEvent.start());
  }


  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }

  @override
  Stream<PlayRoundState> mapEventToState(PlayRoundEvent event) {
    return event.when(
        start: () async* {
          final bool admin = (await _amIGameAdmin.invoke(state.gameId)).when(success: (value) => value, error: (_) => false);
          if (admin) {
            _startRound.invoke(state.gameId);
          }
          _subscription = _getUpcomingRoundUpdates.invoke(state.gameId).listen((pair) {
            _subscription?.cancel();
            add(PlayRoundEvent.roundStarted(pair.first.letter, pair.first.startTime, pair.second));
          });
        },
        roundStarted: (letter, startTime, words) async* {

        },
        tick: () async* {

        },
        wordChanged: (category, newWord) async* {

        },
        roundFinished: () async* {

        }
    );
  }

  factory PlayRoundBloc.fromContext(BuildContext context, PlayRoundState initialState) {
    Injector injector = context.read();
    return PlayRoundBloc(
        initialState,
        injector.startRound,
        injector.getOngoingRoundUpdates,
        injector.amIGameAdmin
    );
  }

}