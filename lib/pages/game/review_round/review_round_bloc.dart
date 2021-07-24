import 'dart:async';

import 'package:findtheword/app/injector.dart';
import 'package:findtheword/domain/common/player.dart';
import 'package:findtheword/domain/game/ongoing_round.dart';
import 'package:findtheword/domain/game/round.dart';
import 'package:findtheword/domain/game/use_case/am_i_game_admin.dart';
import 'package:findtheword/domain/game/use_case/compute_word_points.dart';
import 'package:findtheword/domain/game/use_case/finalize_round.dart';
import 'package:findtheword/domain/game/use_case/get_all_round_data_updates.dart';
import 'package:findtheword/domain/game/use_case/get_next_reviewed_category_updates.dart';
import 'package:findtheword/domain/game/use_case/get_ongoing_round.dart';
import 'package:findtheword/domain/game/use_case/get_players.dart';
import 'package:findtheword/domain/game/use_case/save_all_round_data.dart';
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
  factory ReviewRoundEvent.wordSameAsEdited(String playerId, int group) = WordSameAsEdited;
  factory ReviewRoundEvent.nextClicked() = NextClicked;
}

@freezed
class ReviewRoundState with _$ReviewRoundState {
  @JsonSerializable(explicitToJson: true)
  factory ReviewRoundState(
    String gameId,
    bool admin,
    bool loading,
    String category,
    List<RoundReviewRow> rows,
    List<RoundReviewGroup> groups,
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

@freezed
class RoundReviewGroup with _$RoundReviewGroup {
  factory RoundReviewGroup(int group, String label) = _RoundReviewGroup;
  factory RoundReviewGroup.fromJson(Map<String, dynamic> json) => _$RoundReviewGroupFromJson(json);
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
  final SaveAllRoundData _saveAllRoundData;
  final ComputeWordPoints _computeWordPoints;

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
      this._saveRoundData, this._finalizeRound, this._saveAllRoundData,
      this._computeWordPoints
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
        if (!_rebuildGroups()) {
          return _getNewState();
        } else {
          _saveAllRoundData.invoke(state.gameId, _roundData!);
          return Stream.empty();
        }
      },
      wordValidEdited: (playerId, valid) async* {
        String category = _getCategories()[_currentCategory!];
        _saveRoundData.invoke(state.gameId, _ongoingRound.letter, _roundData!.playersWords[playerId]!.map((word) {
          if (word.category == category) {
            return word.copyWith(valid: valid, group: 0);
          } else {
            return word;
          }
        }).toList(), playerId);
      },
        wordSameAsEdited: (playerId, group) async* {
          String category = _getCategories()[_currentCategory!];
          if (group == 0) {
            int maxGroup = 0;
            for(List<Word> words in _roundData!.playersWords.values) {
              int group = words[_currentCategory!].group;
              if (group > maxGroup) {
                maxGroup = group;
              }
            }
            _saveAllRoundData.invoke(state.gameId, _setGroup(_roundData!, category, playerId, maxGroup + 1));
          } else {
            Round newRound = _setGroup(_roundData!, category, playerId, group);
            _saveAllRoundData.invoke(state.gameId, newRound);
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
    Map<int, List<String>> groups = {};
    if (_currentCategory != null && _roundData != null) {
      List<RoundReviewRow> rows = _players.map((player) {
        Word word = _roundData!.playersWords[player.id]![_currentCategory!];
        if (groups[word.group] == null) {
          groups[word.group] = [];
        }
        groups[word.group]!.add(word.word);
        return RoundReviewRow(
          player.id, player.name, word.word, word.valid, word.group, _computeWordPoints.invoke(word, _players.length)
        );
      }).toList();
      rows.sort((a, b) => (b.group ?? 0) - (a.group ?? 0));
      String category = _getCategories()[_currentCategory!];
      List<RoundReviewGroup> groupChoices = groups.entries.map(
              (entry) => RoundReviewGroup(entry.key, entry.value.join(", "))
      ).toList();
      yield ReviewRoundState(state.gameId, _admin, false, category, rows, groupChoices, false);
    }
  }

  bool _rebuildGroups() {
    Map<String, int> maxGroups = {};
    bool changed = false;
    for(List<Word> words in _roundData!.playersWords.values) {
      for(Word word in words) {
        int maxGroup = maxGroups[word.category] ?? 0;
        if (word.group > maxGroup) {
          maxGroups[word.category] = word.group;
        }
      }
    }
    _roundData = _roundData!.copyWith(
        playersWords: _roundData!.playersWords.map((player, words) =>
            MapEntry(
                player,
                words.map(
                   (word) {
                     if (word.group == 0) {
                       changed = true;
                       int newGroup = (maxGroups[word.category] ?? 0) + 1;
                       maxGroups[word.category] = newGroup;
                       return word.copyWith(group: newGroup);
                     }
                     return word;
                   }
                ).toList()
            )
        )
    );
    return changed;
  }

  Round _setGroup(Round round, String category, String playerId, int group) {
    return round.copyWith(
      playersWords: round.playersWords.map((player, words) =>
        MapEntry(
          player,
          (player == playerId ? words.map(
             (word) => word.category == category ? word.copyWith(group: group) : word
          ) : words).toList()
        )
      )
    );
  }

  int _getGroup(Round round, String category, String playerId) {
    int foundGroup = 0;
    int maxGroup = 0;
    round.playersWords.forEach((key, value) {
      value.forEach((word) {
        if (word.category == category) {
          if (key == playerId) {
            foundGroup = word.group;
          }
          if (word.group > maxGroup) {
            maxGroup = word.group;
          }
        }
      });
    });
    return foundGroup != 0 ? foundGroup : maxGroup + 1;
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
      injector.finalizeRound,
      injector.saveAllRoundData,
      injector.computeWordPoints
    );
  }

}
