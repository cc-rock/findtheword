import 'package:findtheword/domain/common/result.dart';
import 'package:findtheword/domain/common/user_id_repository.dart';
import 'package:findtheword/domain/join_room/room_repository.dart';

class CreateRoom {
  UserIdRepository _userIdRepository;
  RoomRepository _roomRepository;

  CreateRoom(this._roomRepository, this._userIdRepository);

  Future<Result<String>> invoke(
          String adminName, String roomName, [String password]) async {
    try {
      String currentUserId = await _userIdRepository.currentUserId;
      String gameId = await _roomRepository.createRoom(currentUserId, adminName, roomName, password);
      return Result.success(gameId);
    } catch(e) {
      return Future.value(Result.error(e));
    }
  }
}
