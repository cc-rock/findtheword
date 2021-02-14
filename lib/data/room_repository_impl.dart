import 'package:findtheword/data/converter/room_converters.dart';
import 'package:findtheword/data/dto/room_dtos.dart';
import 'package:findtheword/domain/common/player.dart';
import 'package:findtheword/domain/join_room/room_repository.dart';
import 'package:findtheword/domain/join_room/room_status.dart';
import 'package:findtheword/firebase/db_wrapper.dart';

class RoomRepositoryImpl implements RoomRepository {

  DbWrapper _dbWrapper;

  RoomRepositoryImpl(this._dbWrapper);

  @override
  Future<String> createRoom(String adminUserId, String adminName, String roomName, [String password]) {
    String gameId = _dbWrapper.generateKey("/games");
    return _dbWrapper.set("/rooms/$roomName", RoomDTO(
      gameId,
      adminUserId,
      password,
      {adminUserId: PlayerDTO(adminName, DateTime.now().millisecondsSinceEpoch, password), },
      RoomPublicInfoDTO(RoomStatusDTO.open, password != null)
    ).toJson()).then((_) => gameId);
  }

  @override
  Stream<List<Player>> getRoomPlayersUpdates(String roomName) {
    return _dbWrapper.onValue("rooms/$roomName").map((dbValue) {
      Map<String, PlayerDTO> converted = (dbValue["players"] as Map<String, dynamic>).map((key, value) => MapEntry(key, PlayerDTO.fromJson(value)));
      return playersFromDTOs(converted, dbValue["admin"]);
    });
  }

  @override
  Future<RoomStatus> getRoomStatus(String roomName) {
    return _dbWrapper.once("/rooms/$roomName/public").then((value) {
      if (value == null) {
        return RoomStatus.nonExistent;
      }
      try {
        return roomStatusFromDTO(RoomPublicInfoDTO.fromJson(value));
      } catch (exception) {
        throw Exception("Invalid DB data: ${exception.toString()}");
      }
    });
  }

  @override
  Future<void> joinRoom(String playerUserId, String playerName, String roomName, [String password]) {
    return _dbWrapper.set(
        "/rooms/$roomName/players/$playerUserId",
        PlayerDTO(playerName, DateTime.now().millisecondsSinceEpoch, password).toJson()
    );
  }

}