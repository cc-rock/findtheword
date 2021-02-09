import 'package:findtheword/domain/common/result.dart';
import 'package:findtheword/domain/common/user_id_repository.dart';
import 'package:findtheword/domain/join_room/room_repository.dart';

class JoinRoom {
  UserIdRepository _userIdRepository;
  RoomRepository _roomRepository;

  JoinRoom(this._userIdRepository, this._roomRepository);

  Future<Result<void>> invoke(
          String playerName,
          String roomName, [String password]) async {
    String currentUserId = await _userIdRepository.currentUserId;
    return _roomRepository.joinRoom(currentUserId, playerName, roomName, password);
  }
}
