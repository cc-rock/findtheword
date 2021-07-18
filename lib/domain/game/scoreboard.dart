import 'package:freezed_annotation/freezed_annotation.dart';

part 'scoreboard.freezed.dart';
part 'scoreboard.g.dart';

@freezed
class Scoreboard with _$Scoreboard {
  factory Scoreboard(List<ScoreboardRow> rows) = _Scoreboard;
  factory Scoreboard.fromJson(Map<String, dynamic> json) => _$ScoreboardFromJson(json);
}

@freezed
class ScoreboardRow with _$ScoreboardRow {
  factory ScoreboardRow(String playerId, String playerName, int points) = _ScoreboardRow;
  factory ScoreboardRow.fromJson(Map<String, dynamic> json) => _$ScoreboardRowFromJson(json);
}