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
  factory GameSettingsEvent.durationLostFocus() = DurationLostFocus;
  factory GameSettingsEvent.finishModeCheckboxClicked(bool checked) = CheckboxClicked;
  factory GameSettingsEvent.startClicked() = StartClicked;
  factory GameSettingsEvent.startLoading() = StartLoading;
  factory GameSettingsEvent.settingsUpdateReceived(GameSettings settings) = SettingsUpdateReceived;
  factory GameSettingsEvent.categoriesUpdateReceived(List<String> categories) = CategoriesUpdateReceived;
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
  AmIGameAdmin _amIGameAdmin;
  AddCategory _addCategory;
  DeleteCategory _deleteCategory;
  ChangeSettings _changeSettings;
  GetCategoriesUpdates _getCategoriesUpdates;
  GetGameSettingsUpdates _getGameSettingsUpdates;

  bool _durationValidationStarted = false;

  RegExp _durationRegExp = RegExp(r"^(\d+):(\d\d)$");

  StreamSubscription? _settingsSubscription;
  StreamSubscription? _categoriesSubscription;

  GameSettingsBloc(
      GameSettingsState initialsState,
      this._amIGameAdmin,
      this._addCategory,
      this._deleteCategory,
      this._changeSettings,
      this._getCategoriesUpdates,
      this._getGameSettingsUpdates): super(initialsState) {
    _durationValidationStarted = initialsState.durationText.isNotEmpty;
    add(GameSettingsEvent.startLoading());
  }


  @override
  Future<void> close() {
    _settingsSubscription?.cancel();
    _categoriesSubscription?.cancel();
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
            if (_durationValidationStarted) {
              int? durationSeconds = _parseDuration(newDurationText);
              if (durationSeconds != null && state.settings != null) {
                await _changeSettings.invoke(state.gameId, state.settings!.copyWith(roundDurationSeconds: durationSeconds));
                yield state.copyWith(
                    durationIsValid: true,
                    durationText: newDurationText,
                    error: false
                );
              } else {
                yield state.copyWith(
                    durationIsValid: false,
                    error: false
                );
              }
            }
          },
          durationLostFocus: () async* {
            _durationValidationStarted = true;
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
            state.copyWith(
                categories: cats,
                startButtonEnabled: cats != null && cats.isNotEmpty
            );
          },
          startClicked: () async* {
            yield state.copyWith(goToFirstRound: true);
          });
    } catch (error) {
      return Stream.value(state.copyWith(error: true));
    }
  }
  
  String _formatDuration(int durationSeconds) {
    return "${(durationSeconds /~ 60)}:${durationSeconds.remainder(60)}";
  }

  int? _parseDuration(String durationText) {
    RegExpMatch? match = _durationRegExp.firstMatch(durationText);
    if (match == null) {
      return null;
    }
    return int.parse(match.group(0)!) * 60 + int.parse(match.group(1)!);
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
        injector.getGameSettingsUpdates);
  }
}