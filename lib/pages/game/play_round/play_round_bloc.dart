import 'dart:async';

import 'package:findtheword/app/injector.dart';
import 'package:findtheword/domain/game/game.dart';
import 'package:findtheword/domain/game/use_case/am_i_game_admin.dart';
import 'package:findtheword/domain/game/use_case/get_categories.dart';
import 'package:findtheword/domain/game/use_case/get_game_settings.dart';
import 'package:findtheword/domain/game/use_case/get_game_settings_updates.dart';
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
  factory PlayRoundEvent.roundStarted(String letter, int startTime) = RoundStarted;
  factory PlayRoundEvent.tick() = PlayRoundTick;
  factory PlayRoundEvent.wordChanged(String category, String word) = WordChanged;
  factory PlayRoundEvent.doneClicked() = DoneClicked;
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
  final GetCategories _getCategories;
  final GetGameSettings _getGameSettings;
  final AmIGameAdmin _amIGameAdmin;
  final int Function() _getCurrentTimeMillis;

  StreamSubscription? _subscription;

  Timer? _timer;

  PlayRoundBloc(
      PlayRoundState initialState,
      this._startRound,
      this._getUpcomingRoundUpdates,
      this._amIGameAdmin,
      this._getCategories,
      this._getGameSettings,
      this._getCurrentTimeMillis): super(initialState) {
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
          _subscription = _getUpcomingRoundUpdates.invoke(state.gameId).listen((round) {
            if (!round.finishing) {
              add(PlayRoundEvent.roundStarted(round.letter, round.startTime));
            } else {

            }
          });
        },
        roundStarted: (letter, startTime) async* {
          List<String> categories = await _getCategories.invoke(state.gameId);
          GameSettings settings = await _getGameSettings.invoke(state.gameId);
          List<Word> words = categories.map((cat) => Word(cat, "", false, "")).toList();
          int currentTime = _getCurrentTimeMillis();
          int nextSecond = ((currentTime ~/ 1000) + 1) * 1000;
          int toNextSecond = nextSecond - currentTime;
          if (toNextSecond < 100) {
            nextSecond += 1000;
            toNextSecond = nextSecond - currentTime;
          }
          int secondsToStart = (startTime - nextSecond) ~/ 1000;
          int remainingSeconds = settings.roundDurationSeconds;
          if (nextSecond <= startTime) {
            secondsToStart = 0;
            remainingSeconds = settings.roundDurationSeconds - ((startTime - nextSecond) ~/ 1000);
          }
          yield PlayRoundState(
            state.gameId,
            loading: false,
            secondsToStart: secondsToStart,
            remainingSeconds: remainingSeconds,
            letter: letter,
            words: words
          );
          _timer = Timer(Duration(milliseconds: toNextSecond), _timerCallback);
        },
        tick: () async* {

        },
        wordChanged: (category, newWord) async* {

        },
        roundFinished: () async* {

        },
        doneClicked: () async* {

        }
    );
  }

  void _timerCallback() {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: 1), _timerCallback);
    add(PlayRoundEvent.tick());
  }

  factory PlayRoundBloc.fromContext(BuildContext context, PlayRoundState initialState) {
    Injector injector = context.read();
    return PlayRoundBloc(
        initialState,
        injector.startRound,
        injector.getOngoingRoundUpdates,
        injector.amIGameAdmin,
        injector.getCategories,
        injector.getGameSettings,
        () => DateTime.now().millisecondsSinceEpoch
    );
  }

}