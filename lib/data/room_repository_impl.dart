import 'package:findtheword/data/converter/room_converters.dart';
import 'package:findtheword/data/dto/room_dtos.dart';
import 'package:findtheword/domain/common/player.dart';
import 'package:findtheword/domain/common/result.dart';
import 'package:findtheword/domain/join_room/room_repository.dart';
import 'package:findtheword/domain/join_room/room_status.dart';
import 'package:findtheword/firebase/db_wrapper.dart';

class RoomRepositoryImpl implements RoomRepository {

  DbWrapper _dbWrapper;

  RoomRepositoryImpl(this._dbWrapper);

  @override
  Future<Result<String>> createRoom(String adminUserId, String adminName, String roomName, [String password]) {
    String gameId = _dbWrapper.generateKey("/games");
    return _dbWrapper.set("/rooms/$roomName", RoomDTO(
      gameId,
      adminUserId,
      password,
      {adminUserId: PlayerDTO(adminName, DateTime.now().millisecondsSinceEpoch, password), },
      RoomPublicInfoDTO(RoomStatusDTO.open, password != null)
    ).toJson()).catchError((error) => Result.error(error)).then((_) => Result.success(gameId));
  }

  @override
  Stream<List<Player>> getRoomPlayersUpdates(String roomName) {
    return _dbWrapper.onValue("rooms/$roomName").map((dbValue) {
      Map<String, PlayerDTO> converted = (dbValue["players"] as Map<String, dynamic>).map((key, value) => MapEntry(key, PlayerDTO.fromJson(value)));
      return playersFromDTOs(converted, dbValue["admin"]);
    });
  }

  @override
  Future<Result<RoomStatus>> getRoomStatus(String roomName) {
    return _dbWrapper.once("/rooms/$roomName/public").then((value) {
      if (value == null) {
        return Result.success(RoomStatus.nonExistent);
      }
      try {
        return Result.success(roomStatusFromDTO(RoomPublicInfoDTO.fromJson(value)));
      } catch (exception) {
        return Result.error(Exception("Invalid DB data."));
      }
    });
  }

  @override
  Future<Result<void>> joinRoom(String playerUserId, String playerName, String roomName, [String password]) {
    return _dbWrapper.set(
        "/rooms/$roomName/players/$playerUserId",
        PlayerDTO(playerName, DateTime.now().millisecondsSinceEpoch, password).toJson()
    ).then((_) => Result.success("")).catchError((error) => Result.error(error));
  }

}