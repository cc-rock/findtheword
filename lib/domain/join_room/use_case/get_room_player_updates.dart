import 'package:findtheword/domain/join_room/room_repository.dart';
import '../room.dart';

class GetRoomUpdates {
  final RoomRepository _roomRepository;
  GetRoomUpdates(this._roomRepository);

  Stream<Room> invoke(String roomName) {
    return _roomRepository.getRoomUpdates(roomName);
  }
}