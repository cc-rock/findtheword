import 'package:findtheword/data/dto/room_dtos.dart';
import 'package:findtheword/domain/common/player.dart';
import 'package:findtheword/domain/join_room/room_status.dart';

RoomStatus roomStatusFromDTO(RoomPublicInfoDTO dto) {
  switch(dto.status) {
    case RoomStatusDTO.open:
      return dto.hasPassword ? RoomStatus.availableWithPassword : RoomStatus.available;
    case RoomStatusDTO.closed:
      return RoomStatus.unavailable;
  }
}

List<Player> playersFromDTOs(Map<String, PlayerDTO> dtos, String adminId) {
  final sortedEntries = dtos.entries.toList(growable: false)..sort((a, b) => a.value.timestamp - b.value.timestamp);
  return sortedEntries.map((entry) =>
      Player(entry.key, entry.value.name, entry.key == adminId)
  ).toList(growable: false);
}