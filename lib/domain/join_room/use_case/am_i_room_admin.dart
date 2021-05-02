import 'package:findtheword/domain/common/result.dart';
import 'package:findtheword/domain/common/user_id_repository.dart';
import 'package:findtheword/domain/join_room/room_repository.dart';

class AmIRoomAdmin {
  final UserIdRepository _userIdRepository;
  final RoomRepository _roomRepository;

  AmIRoomAdmin(this._userIdRepository, this._roomRepository);

  Future<Result<bool>> invoke(String roomName) async {
    try {
      String currentUserId = await _userIdRepository.currentUserId;
      String roomAdminId = await _roomRepository.getRoomAdminId(roomName);
      return Result.success(currentUserId == roomAdminId);
    } catch(e) {
      return Future.value(Result.error(e));
    }
  }

}
