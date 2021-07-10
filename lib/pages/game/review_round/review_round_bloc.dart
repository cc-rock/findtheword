import 'dart:async';

import 'package:findtheword/app/injector.dart';
import 'package:findtheword/domain/common/player.dart';
import 'package:findtheword/domain/game/ongoing_round.dart';
import 'package:findtheword/domain/game/round.dart';
import 'package:findtheword/domain/game/use_case/am_i_game_admin.dart';
import 'package:findtheword/domain/game/use_case/finalize_round.dart';
import 'package:findtheword/domain/game/use_case/get_all_round_data_updates.dart';
import 'package:findtheword/domain/game/use_case/get_next_reviewed_category_updates.dart';
import 'package:findtheword/domain/game/use_case/get_ongoing_round.dart';
import 'package:findtheword/domain/game/use_case/get_players.dart';
import 'package:findtheword/domain/game/use_case/save_next_reviewed_category.dart';
import 'package:findtheword/domain/game/use_case/save_round_data.dart';
import 'package:findtheword/domain/game/word.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_round_bloc.freezed.dart';
part 'review_round_bloc.g.dart';

@freezed
class ReviewRoundEvent with _$ReviewRoundEvent {
  factory ReviewRoundEvent.start() = ReviewRoundStart;
  factory ReviewRoundEvent.nextCategoryReceived(int? nextCategory) = NextCategoryReceived;
  factory ReviewRoundEvent.roundDataReceived(Round round) = RoundDataReceived;
  factory ReviewRoundEvent.wordValidEdited(String playerId, bool valid) = WordValidEdited;
  factory ReviewRoundEvent.wordSameAsEdited(String playerId, String? otherPlayerId) = WordSameAsEdited;
  factory ReviewRoundEvent.nextClicked() = NextClicked;
}

@freezed
class ReviewRoundState with _$ReviewRoundState {
  @JsonSerializable(explicitToJson: true)
  factory ReviewRoundState(
    String gameId,
    bool loading,
    String category,
    List<RoundReviewRow> rows,
    bool goToScoreboard
  ) = _ReviewRoundState;
  factory ReviewRoundState.fromJson(Map<String, dynamic> json) => _$ReviewRoundStateFromJson(json);
}

@freezed
class RoundReviewRow with _$RoundReviewRow {
  factory RoundReviewRow(String playerId, String playerName, String word, bool valid,
       int? group, int points) = _RoundReviewRow;
  factory RoundReviewRow.fromJson(Map<String, dynamic> json) => _$RoundReviewRowFromJson(json);
}

class ReviewRoundBloc extends Bloc<ReviewRoundEvent, ReviewRoundState> {

  final AmIGameAdmin _amIGameAdmin;
  final GetPlayers _getPlayers;
  final GetOngoingRound _getOngoingRound;
  final GetNextReviewedCategoryUpdates _getNextReviewedCategoryUpdates;
  final SaveNextReviewedCategory _saveNextReviewedCategory;
  final GetAllRoundDataUpdates _getAllRoundDataUpdates;
  final SaveRoundData _saveRoundData;
  final FinalizeRound _finalizeRound;

  StreamSubscription? _nextCategorySubscription;
  StreamSubscription? _roundDataSubscription;

  late bool _admin;
  late List<Player> _players;
  late OngoingRound _ongoingRound;
  Round? _roundData;
  int? _currentCategory;

  @override
  Future<void> close() {
    _nextCategorySubscription?.cancel();
    _roundDataSubscription?.cancel();
    return super.close();
  }

  ReviewRoundBloc(
      ReviewRoundState initialState, this._amIGameAdmin, this._getPlayers,
      this._getOngoingRound, this._getNextReviewedCategoryUpdates,
      this._saveNextReviewedCategory, this._getAllRoundDataUpdates,
      this._saveRoundData, this._finalizeRound
  ) : super(initialState) {
    add(ReviewRoundEvent.start());
  }

  @override
  Stream<ReviewRoundState> mapEventToState(ReviewRoundEvent event) {
    return event.when(
      start: () async* {
        yield state.copyWith(loading: true);
        _admin = (await _amIGameAdmin.invoke(state.gameId)).when(success: (value) => value, error: (_) => false);
        _players = await _getPlayers.invoke(state.gameId);
        _ongoingRound = (await _getOngoingRound.invoke(state.gameId))!;
        _nextCategorySubscription = _getNextReviewedCategoryUpdates.invoke(state.gameId, _ongoingRound.letter).listen((nextCategory) {
          add(ReviewRoundEvent.nextCategoryReceived(nextCategory));
        });
        _roundDataSubscription = _getAllRoundDataUpdates.invoke(state.gameId, _ongoingRound.letter).listen((round) {
          add(ReviewRoundEvent.roundDataReceived(round));
        });
      },
      nextCategoryReceived: (nextCategory) {
        if (nextCategory != null) {
          if (_roundData == null) {
            _currentCategory = nextCategory;
            return Stream.empty();
          }
          List<String> categories = _getCategories();
          if (nextCategory < categories.length) {
            _currentCategory = nextCategory;
            return _getNewState();
          } else {
            return Stream.fromFuture(_finalizeRound.invoke(state.gameId).then((_) => state.copyWith(goToScoreboard: true)));
          }
        } else {
          if (_admin) {
            _saveNextReviewedCategory.invoke(state.gameId, _ongoingRound.letter, 0);
          }
          return Stream.empty();
        }
      },
      roundDataReceived: (round) {
        _roundData = round;
        return _getNewState();
      },
      wordValidEdited: (playerId, valid) async* {
        String category = _getCategories()[_currentCategory!];
        _saveRoundData.invoke(state.gameId, _ongoingRound.letter, _roundData!.playersWords[playerId]!.map((word) {
          if (word.category == category) {
            return word.copyWith(valid: valid);
          } else {
            return word;
          }
        }).toList(), playerId);
      },
        wordSameAsEdited: (playerId, otherPlayerId) async* {
          String category = _getCategories()[_currentCategory!];
          if (otherPlayerId == null) {
            // saveAllRoundData(_setGroup(_roundData, _category, playerId, 0))
          } else {
            // otherGroup = getGroup(_roundData, _category, otherPlayerId!); // if null return next available group
            // Round newRound = _setGroup(_roundData, _category, playerId, otherGroup);
            // newRound =  _setGroup(newRound, _category, otherPlayerId, otherGroup);
            // newRound = _rebuildGroups(newRound)
            // saveAllRoundData(newRound);
          }
        },
      nextClicked: () async* {
        int nextCategory = (_currentCategory ?? 0) + 1;
        _saveNextReviewedCategory.invoke(state.gameId, _ongoingRound.letter, nextCategory);
      }
    );
  }

  List<String> _getCategories() {
    return _roundData!.playersWords[_players[0].id]!.map((word) => word.category).toList();
  }

  Stream<ReviewRoundState> _getNewState() async* {
    if (_currentCategory != null && _roundData != null) {
      List<RoundReviewRow> rows = _players.map((player) {
        Word word = _roundData!.playersWords[player.id]![_currentCategory!];
        return RoundReviewRow(
          player.id, player.name, word.word, word.valid, word.group, 0
        );
      }).toList();
      String category = _getCategories()[_currentCategory!];
      yield ReviewRoundState(state.gameId, false, category, rows, false);
    }
  }

  factory ReviewRoundBloc.fromContext(BuildContext context, ReviewRoundState initialState) {
    Injector injector = context.read();
    return ReviewRoundBloc(
      initialState,
      injector.amIGameAdmin,
      injector.getPlayers,
      injector.getOngoingRound,
      injector.getNextReviewedCategoryUpdates,
      injector.saveNextReviewedCategory,
      injector.getAllRoundDataUpdates,
      injector.saveRoundData,
      injector.finalizeRound
    );
  }

}
