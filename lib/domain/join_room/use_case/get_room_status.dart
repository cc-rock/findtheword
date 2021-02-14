import 'package:findtheword/domain/common/result.dart';
import 'package:findtheword/domain/join_room/room_repository.dart';

import '../room_status.dart';

class GetRoomStatus {

  RoomRepository _repository;

  GetRoomStatus(this._repository);

  Future<Result<RoomStatus>> invoke(String roomName) async {
    try {
      RoomStatus status = await _repository.getRoomStatus(roomName);
      return Result.success(status);
    } catch (e) {
      return Result.error(e);
    }
  }

}