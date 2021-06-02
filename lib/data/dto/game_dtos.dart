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
      @JsonKey(name: "upcoming_round") OngoingRoundDTO? upcomingRound,
      Map<String, Map<String, WordDTO>> rounds,
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
abstract class OngoingRoundDTO with _$OngoingRoundDTO {
  factory OngoingRoundDTO(String letter, int startTimestamp, String? finishingPlayerId) = _OngoingRoundDTO;
  factory OngoingRoundDTO.fromJson(Map<String, dynamic> json) => _$OngoingRoundDTOFromJson(json);
}

@freezed
abstract class WordDTO with _$WordDTO {
  factory WordDTO(String category, String word, @JsonKey(name: "is_valid")  isValid, @JsonKey(name: "same_as") String sameAs) = _WordDTO;
  factory WordDTO.fromJson(Map<String, dynamic> json) => _$WordDTOFromJson(json);
}