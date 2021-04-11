import 'package:findtheword/data/dto/room_dtos.dart';
import 'package:findtheword/domain/join_room/room.dart';

RoomStatus roomStatusFromDTO(RoomPublicInfoDTO dto) {
  switch(dto.status) {
    case RoomStatusDTO.open:
      return dto.hasPassword ? RoomStatus.availableWithPassword : RoomStatus.available;
    case RoomStatusDTO.closed:
      return RoomStatus.unavailable;
  }
}
