import 'dart:async';
import 'package:findtheword/app/injector.dart';
import 'package:findtheword/domain/game/game.dart';
import 'package:findtheword/domain/game/use_case/finish_round.dart';
import 'package:findtheword/domain/game/use_case/finish_round_early.dart';
import 'package:findtheword/domain/game/use_case/get_categories.dart';
import 'package:findtheword/domain/game/use_case/get_game_settings.dart';
import 'package:findtheword/domain/game/use_case/get_ongoing_round_updates.dart';
import 'package:findtheword/domain/game/use_case/is_other_player_finishing.dart';
import 'package:findtheword/domain/game/word.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'play_round_bloc.freezed.dart';
part 'play_round_bloc.g.dart';

@freezed
class PlayRoundEvent with _$PlayRoundEvent {
  factory PlayRoundEvent.start() = PlayRoundStart;
  factory PlayRoundEvent.roundStarted(String letter, int startTime) = RoundStarted;
  factory PlayRoundEvent.tick() = PlayRoundTick;
  factory PlayRoundEvent.wordChanged(String category, String word) = WordChanged;
  factory PlayRoundEvent.doneClicked() = DoneClicked;
  factory PlayRoundEvent.roundFinishing() = RoundFinishing;
}

@freezed
class PlayRoundState with _$PlayRoundState {
  const PlayRoundState._();
  @JsonSerializable(explicitToJson: true)
  factory PlayRoundState(String gameId, {
    @Default(true) bool loading,
    @Default(5) int secondsToStart,
    @Default(180) int remainingSeconds,
    @Default("") String letter,
    @Default([]) List<Word> words,
    @Default(false) bool goToRoundReview
  }) = _PlayRoundState;
  factory PlayRoundState.fromJson(Map<String, dynamic> json) => _$PlayRoundStateFromJson(json);

  Word wordForCategory(String category) => words.firstWhere((word) => word.category == category);

  String get formattedRemainingSeconds => "${remainingSeconds ~/ 60}:${remainingSeconds.remainder(60).toString().padLeft(2, '0')}";
}

class PlayRoundBloc extends Bloc<PlayRoundEvent, PlayRoundState> {

  final GetOngoingRoundUpdates _getUpcomingRoundUpdates;
  final GetCategories _getCategories;
  final GetGameSettings _getGameSettings;
  final int Function() _getCurrentTimeMillis;
  final IsOtherPlayerFinishing _isOtherPlayerFinishing;
  final FinishRound _finishRound;
  final FinishRoundEarly _finishRoundEarly;

  StreamSubscription? _subscription;

  Timer? _timer;

  PlayRoundBloc(
      PlayRoundState initialState,
      this._getUpcomingRoundUpdates,
      this._getCategories,
      this._getGameSettings,
      this._getCurrentTimeMillis,
      this._isOtherPlayerFinishing,
      this._finishRound,
      this._finishRoundEarly): super(initialState) {
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
          _subscription = _getUpcomingRoundUpdates.invoke(state.gameId).listen((round) async {
            if (round == null) {
              return;
            }
            bool otherPlayerFinishing = (await _isOtherPlayerFinishing.invoke(round)).when(
              success: (value) => value,
              error: (_) => false
            );
            if (otherPlayerFinishing) {
              add(PlayRoundEvent.roundFinishing());
            } else if (round.finishingPlayerId == null) {
              add(PlayRoundEvent.roundStarted(round.letter, round.startTime));
            }
          });
        },
        roundStarted: (letter, startTime) async* {
          List<String> categories = await _getCategories.invoke(state.gameId);
          GameSettings settings = await _getGameSettings.invoke(state.gameId);
          List<Word> words = categories.map((cat) => Word(cat, "", false, 0)).toList();
          int currentTime = _getCurrentTimeMillis();
          int nextSecond = ((currentTime ~/ 1000) + 1) * 1000;
          int toNextSecond = nextSecond - currentTime;
          if (toNextSecond < 100) {
            nextSecond += 1000;
            toNextSecond = nextSecond - currentTime;
          }
          int secondsToStart = (startTime - nextSecond) ~/ 1000;
          int remainingSeconds = settings.roundDurationSeconds;
          if (nextSecond >= startTime) {
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
          if (state.secondsToStart > 0) {
            yield state.copyWith(secondsToStart: state.secondsToStart - 1);
          } else if (state.remainingSeconds > 0)  {
            yield state.copyWith(remainingSeconds: state.remainingSeconds - 1);
          } else {
            await _finishRound.invoke(state.gameId, state.letter, state.words);
            yield state.copyWith(goToRoundReview: true);
          }
        },
        wordChanged: (category, newWord) async* {
          yield state.copyWith(
            words: state.words.map((word) =>
               word.category == category ? Word(
                 category, newWord, _validateWord(newWord, state.letter), 0
               ) : word
            ).toList()
          );
        },
        roundFinishing: () async* {
          if (state.remainingSeconds > 4) {
            yield state.copyWith(remainingSeconds: 4);
          }
        },
        doneClicked: () async* {
          await _finishRoundEarly.invoke(state.gameId, state.letter, state.words);
          yield state.copyWith(goToRoundReview: true);
        }
    );
  }

  void _timerCallback() {
    _timer?.cancel();
    int nextSecond = ((_getCurrentTimeMillis() ~/ 1000) + 1) * 1000;
    int duration = nextSecond - _getCurrentTimeMillis();
    _timer = Timer(Duration(milliseconds: duration), _timerCallback);
    add(PlayRoundEvent.tick());
  }

  bool _validateWord(String word, String letter) {
    return word.isNotEmpty && word.toLowerCase().startsWith(letter.toLowerCase());
  }

  factory PlayRoundBloc.fromContext(BuildContext context, PlayRoundState initialState) {
    Injector injector = context.read();
    return PlayRoundBloc(
        initialState,
        injector.getOngoingRoundUpdates,
        injector.getCategories,
        injector.getGameSettings,
        () => DateTime.now().millisecondsSinceEpoch,
        injector.isOtherPlayerFinishing,
        injector.finishRound,
        injector.finishRoundEarly
    );
  }

}