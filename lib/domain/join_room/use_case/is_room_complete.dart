import 'package:findtheword/domain/join_room/room.dart';

/// Checks if the room is complete and we can move on to game settings
class IsRoomComplete {
  bool invoke(Room room) => (room.status == RoomStatus.unavailable);
}