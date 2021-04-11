import 'package:freezed_annotation/freezed_annotation.dart';

import 'common_dtos.dart';

part 'room_dtos.freezed.dart';
part 'room_dtos.g.dart';

enum RoomStatusDTO { open, closed }

@freezed
abstract class RoomPublicInfoDTO with _$RoomPublicInfoDTO {
  factory RoomPublicInfoDTO(RoomStatusDTO status, bool hasPassword) = _RoomPublicInfoDTO;
  factory RoomPublicInfoDTO.fromJson(Map<String, dynamic> json) => _$RoomPublicInfoDTOFromJson(json);
}

@freezed
abstract class RoomDTO with _$RoomDTO {
  @JsonSerializable(explicitToJson: true)
  factory RoomDTO(
      @JsonKey(name: "game_id") String gameId,
      String admin,
      @nullable String password,
      Map<String, PlayerDTO> players,
      RoomPublicInfoDTO public
      ) = _RoomDTO;
  factory RoomDTO.fromJson(Map<String , dynamic> json) => _$RoomDTOFromJson(json);
}