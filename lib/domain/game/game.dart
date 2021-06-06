import 'package:freezed_annotation/freezed_annotation.dart';
part 'game.freezed.dart';
part 'game.g.dart';

@freezed
class GameSettings with _$GameSettings {
  factory GameSettings(
    int roundDurationSeconds,
    bool finishWhenFirstPlayerFinishes,
    int graceSecondsOnFinish,
    int roundStartDelay,
    String letterPool
  ) = _GameSettings;
  factory GameSettings.fromJson(Map<String, dynamic> json) => _$GameSettingsFromJson(json);
}
