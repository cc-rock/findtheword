import 'package:findtheword/domain/common/player.dart';
import 'package:findtheword/domain/join_room/room_repository.dart';

class GetRoomPlayerUpdates {
  final RoomRepository _roomRepository;
  GetRoomPlayerUpdates(this._roomRepository);

  Stream<List<Player>> invoke(String roomName) {
    return _roomRepository.getRoomPlayersUpdates(roomName);
  }
}