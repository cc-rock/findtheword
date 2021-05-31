import 'dart:async';

import 'package:findtheword/app/injector.dart';
import 'package:findtheword/domain/common/result.dart';
import 'package:findtheword/domain/game/game.dart';
import 'package:findtheword/domain/game/use_case/add_category.dart';
import 'package:findtheword/domain/game/use_case/am_i_game_admin.dart';
import 'package:findtheword/domain/game/use_case/change_settings.dart';
import 'package:findtheword/domain/game/use_case/delete_category.dart';
import 'package:findtheword/domain/game/use_case/get_categories_updates.dart';
import 'package:findtheword/domain/game/use_case/get_game_settings_updates.dart';
import 'package:findtheword/domain/game/use_case/get_ongoing_round_updates.dart';
import 'package:findtheword/domain/game/use_case/start_round.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'game_settings_bloc.freezed.dart';
part 'game_settings_bloc.g.dart';

@freezed
abstract class GameSettingsEvent with _$GameSettingsEvent {
  factory GameSettingsEvent.addedCategory(String category) = AddedCategory;
  factory GameSettingsEvent.deletedCategory(String category) = DeletedCategory;
  factory GameSettingsEvent.durationChanged(String duration) = DurationChanged;
  factory GameSettingsEvent.finishModeCheckboxClicked(bool checked) = CheckboxClicked;
  factory GameSettingsEvent.startClicked() = StartClicked;
  factory GameSettingsEvent.startLoading() = StartLoading;
  factory GameSettingsEvent.settingsUpdateReceived(GameSettings settings) = SettingsUpdateReceived;
  factory GameSettingsEvent.categoriesUpdateReceived(List<String> categories) = CategoriesUpdateReceived;
  factory GameSettingsEvent.roundStarted() = RoundStarted;
}

@freezed
abstract class GameSettingsState with _$GameSettingsState {
  factory GameSettingsState(
      String gameId,
      [@Default(false) bool admin,
      @Default([]) List<String> categories,
      @Default("") String durationText,
      @Default(false) bool durationIsValid,
      @Default(false) bool finishWhenFirstFinishes,
      @Default(false) bool startButtonEnabled,
      @Default(false) bool goToFirstRound,
      @Default(false) bool error,
      GameSettings? settings]
  ) = _GameSettingsState;
  factory GameSettingsState.fromJson(Map<String, dynamic> json) => _$GameSettingsStateFromJson(json);
}

class GameSettingsBloc extends Bloc<GameSettingsEvent, GameSettingsState> {
  final AmIGameAdmin _amIGameAdmin;
  final AddCategory _addCategory;
  final DeleteCategory _deleteCategory;
  final ChangeSettings _changeSettings;
  final GetCategoriesUpdates _getCategoriesUpdates;
  final GetGameSettingsUpdates _getGameSettingsUpdates;
  final StartRound _startRound;
  final GetOngoingRoundUpdates _getOngoingRoundUpdates;

  RegExp _durationRegExp = RegExp(r"^(\d+):(\d\d)$");

  StreamSubscription? _settingsSubscription;
  StreamSubscription? _categoriesSubscription;
  StreamSubscription? _ongoingRoundSubscription;

  GameSettingsBloc(
      GameSettingsState initialsState,
      this._amIGameAdmin,
      this._addCategory,
      this._deleteCategory,
      this._changeSettings,
      this._getCategoriesUpdates,
      this._getGameSettingsUpdates,
      this._startRound,
      this._getOngoingRoundUpdates): super(initialsState) {
    add(GameSettingsEvent.startLoading());
  }


  @override
  Future<void> close() {
    _settingsSubscription?.cancel();
    _categoriesSubscription?.cancel();
    _ongoingRoundSubscription?.cancel();
    return super.close();
  }

  @override
  Stream<GameSettingsState> mapEventToState(GameSettingsEvent event) {
    try {
      return event.when(
          startLoading: () async* {
            bool admin = (await _amIGameAdmin.invoke(state.gameId)).when(
                success: (value) => value,
                error: (error) => false
            );
            yield state.copyWith(admin: admin);
            _settingsSubscription = _getGameSettingsUpdates.invoke(state.gameId).listen((settings) {
              add(GameSettingsEvent.settingsUpdateReceived(settings));
            });
            _categoriesSubscription = _getCategoriesUpdates.invoke(state.gameId).listen((cats) {
              add(GameSettingsEvent.categoriesUpdateReceived(cats));
            });
            _ongoingRoundSubscription = _getOngoingRoundUpdates.invoke(state.gameId).listen((pair) {
              add(GameSettingsEvent.roundStarted());
            });
          },
          addedCategory: (newCategory) async* {
            final result = await _addCategory.invoke(state.gameId, newCategory);
            yield state.copyWith(error: result is ResultError);
          },
          deletedCategory: (deletedCategory) async* {
            final result = await _deleteCategory.invoke(state.gameId, deletedCategory);
            yield state.copyWith(error: result is ResultError);
          },
          durationChanged: (newDurationText) async* {
            int? durationSeconds = _parseDuration(newDurationText);
            if (durationSeconds != null && state.settings != null) {
              yield state.copyWith(
                  durationIsValid: true,
                  durationText: newDurationText,
                  startButtonEnabled: state.categories.isNotEmpty,
                  error: false
              );
              await _changeSettings.invoke(state.gameId, state.settings!.copyWith(roundDurationSeconds: durationSeconds));
            } else {
              yield state.copyWith(
                  durationIsValid: false,
                  startButtonEnabled: false,
                  error: false
              );
            }
          },
          finishModeCheckboxClicked: (isChecked) async* {
            if (state.settings == null) {
              return;
            }
            await _changeSettings.invoke(state.gameId, state.settings!.copyWith(finishWhenFirstPlayerFinishes: isChecked));
            yield state.copyWith(
                finishWhenFirstFinishes: isChecked,
                error: false
            );
          },
          settingsUpdateReceived: (settings) async* {
            yield state.copyWith(
                finishWhenFirstFinishes: settings.finishWhenFirstPlayerFinishes,
                durationText: _formatDuration(settings.roundDurationSeconds),
                settings: settings
            );
          },
          categoriesUpdateReceived: (cats) async* {
            yield state.copyWith(
                categories: cats,
                startButtonEnabled: cats.isNotEmpty && state.durationIsValid
            );
          },
          startClicked: () async* {
            await _startRound.invoke(state.gameId);
          },
          roundStarted: () async* {
            yield state.copyWith(goToFirstRound: true);
          });
    } catch (error) {
      return Stream.value(state.copyWith(error: true));
    }
  }
  
  String _formatDuration(int durationSeconds) {
    String remainder = durationSeconds.remainder(60).toString();
    if (remainder.length == 1) {
      remainder = "0$remainder";
    }
    return "${(durationSeconds ~/ 60)}:$remainder";
  }

  int? _parseDuration(String durationText) {
    RegExpMatch? match = _durationRegExp.firstMatch(durationText);
    if (match == null) {
      return null;
    }
    return int.parse(match.group(1)!) * 60 + int.parse(match.group(2)!);
  }

  factory GameSettingsBloc.fromContext(BuildContext context, GameSettingsState initialState) {
    Injector injector = context.read();
    return GameSettingsBloc(
        initialState,
        injector.amIGameAdmin,
        injector.addCategory,
        injector.deleteCategory,
        injector.changeSettings,
        injector.getCategoriesUpdates,
        injector.getGameSettingsUpdates,
        injector.startRound,
        injector.getOngoingRoundUpdates);
  }
}