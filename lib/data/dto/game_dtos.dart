import 'package:freezed_annotation/freezed_annotation.dart';

import 'common_dtos.dart';

part 'game_dtos.freezed.dart';
part 'game_dtos.g.dart';

@freezed
abstract class GameDTO with _$GameDTO {
  @JsonSerializable(explicitToJson: true)
  factory GameDTO(
      @JsonKey(name: "room_name") String roomName,
      Map<String, PlayerDTO> players,
      String admin,
      List<String> categories,
      GameSettingsDTO settings,
      @nullable @JsonKey(name: "upcoming_round") UpcomingRoundDTO upcomingRound,
      Map<String, Map<String, Map<String, WordDTO>>> rounds,
      @JsonKey(name: "available_letters") String availableLetters
  ) = _GameDTO;
  factory GameDTO.fromJson(Map<String, dynamic> json) => _$GameDTOFromJson(json);
}

@freezed
abstract class GameSettingsDTO with _$GameSettingsDTO {
  factory GameSettingsDTO(
      int roundDurationSeconds,
      bool finishWhenFirstPlayerFinishes,
      int graceSecondsOnFinish,
      int roundStartDelay,
      String letterPool
      ) = _GameSettingsDTO;
  factory GameSettingsDTO.fromJson(Map<String, dynamic> json) => _$GameSettingsDTOFromJson(json);
}

@freezed
abstract class UpcomingRoundDTO with _$UpcomingRoundDTO {
  factory UpcomingRoundDTO(String letter, int startTimestamp) = _UpcomingRoundDTO;
  factory UpcomingRoundDTO.fromJson(Map<String, dynamic> json) => _$UpcomingRoundDTOFromJson(json);
}

@freezed
abstract class WordDTO with _$WordDTO {
  factory WordDTO(String word, bool isValid, String sameAsPlayerId) = _WordDTO;
  factory WordDTO.fromJson(Map<String, dynamic> json) => _$WordDTOFromJson(json);
}