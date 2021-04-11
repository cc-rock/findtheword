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
}