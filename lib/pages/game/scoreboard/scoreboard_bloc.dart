import 'dart:async';

import 'package:findtheword/app/injector.dart';
import 'package:findtheword/domain/game/scoreboard.dart';
import 'package:findtheword/domain/game/use_case/am_i_game_admin.dart';
import 'package:findtheword/domain/game/use_case/get_ongoing_round_updates.dart';
import 'package:findtheword/domain/game/use_case/get_scoreboard.dart';
import 'package:findtheword/domain/game/use_case/start_round.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'scoreboard_bloc.freezed.dart';
part 'scoreboard_bloc.g.dart';

@freezed
class ScoreboardEvent with _$ScoreboardEvent {
  factory ScoreboardEvent.start() = ScoreboardStart;
  factory ScoreboardEvent.nextRoundClicked() = ScoreboardNextRound;
  factory ScoreboardEvent.finishGameClicked() = ScoreboardFinish;
  factory ScoreboardEvent.goToNextRound() = ScoreboardGoToNextRound;
  factory ScoreboardEvent.gameFinished() = ScoreboardGameFinished;
  factory ScoreboardEvent.fromJson(Map<String, dynamic> json) => _$ScoreboardEventFromJson(json);
}

enum ScoreboardNavAction { goToNextRound, goToHome }

@freezed
class ScoreboardState with _$ScoreboardState {
  @JsonSerializable(explicitToJson: true)
  factory ScoreboardState(
      String gameId,
      bool admin,
      [Scoreboard? scoreboard,
      ScoreboardNavAction? navAction]
      ) = _ScoreboardState;
  factory ScoreboardState.fromJson(Map<String, dynamic> json) => _$ScoreboardStateFromJson(json);
}

class ScoreboardBloc extends Bloc<ScoreboardEvent, ScoreboardState> {

  final GetScoreboard _getScoreboard;
  final AmIGameAdmin _amIGameAdmin;
  final StartRound _startRound;
  final GetOngoingRoundUpdates _getOngoingRoundUpdates;

  StreamSubscription? subscription;

  ScoreboardBloc(ScoreboardState initialState,
      this._getScoreboard, this._amIGameAdmin, this._startRound,
      this._getOngoingRoundUpdates) : super(initialState) {
    add(ScoreboardEvent.start());
  }


  @override
  Future<void> close() {
    subscription?.cancel();
    return super.close();
  }

  @override
  Stream<ScoreboardState> mapEventToState(ScoreboardEvent event) {
    return event.when(
        start: () async* {
          final scoreboard = await _getScoreboard.invoke(state.gameId);
          final admin = (await _amIGameAdmin.invoke(state.gameId)).when<bool>(success: (value) => value, error: (_) => false);
          subscription = _getOngoingRoundUpdates.invoke(state.gameId).listen((ongoingRound) {
            if (ongoingRound != null) {
              add(ScoreboardEvent.goToNextRound());
            }
          });
          yield ScoreboardState(state.gameId, admin, scoreboard);
        },
        nextRoundClicked: () async* {
          _startRound.invoke(state.gameId);
        },
        finishGameClicked: () async* {
        },
        goToNextRound: () async* {
          yield state.copyWith(navAction: ScoreboardNavAction.goToNextRound);
        },
        gameFinished: () async* {
          yield state.copyWith(navAction: ScoreboardNavAction.goToHome);
        }
    );
  }

  factory ScoreboardBloc.fromContext(BuildContext context, ScoreboardState initialState) {
    Injector injector = context.read();
    return ScoreboardBloc(
      initialState,
      injector.getScoreboard,
      injector.amIGameAdmin,
      injector.startRound,
      injector.getOngoingRoundUpdates
    );
  }

}
