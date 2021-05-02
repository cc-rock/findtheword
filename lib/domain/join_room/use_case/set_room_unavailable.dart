import 'package:findtheword/domain/common/result.dart';
import 'package:findtheword/domain/join_room/room_repository.dart';

class SetRoomUnavailable {
  final RoomRepository _roomRepository;

  SetRoomUnavailable(this._roomRepository);

  Future<Result<void>> invoke(String roomName) async {
    try {
      await _roomRepository.setRoomUnavailable(roomName);
      return Result.success("");
    } catch (error) {
      return Result.error(error);
    }
  }
}