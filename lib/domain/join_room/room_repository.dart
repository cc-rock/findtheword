import 'package:findtheword/domain/common/player.dart';
import 'package:findtheword/domain/common/result.dart';
import 'package:findtheword/domain/join_room/room_status.dart';

abstract class RoomRepository {

  Future<Result<RoomStatus>> getRoomStatus(String roomName);

  Future<Result<void>> joinRoom(String playerUserId, String playerName, String roomName, [String password]);

  /// Creates a new room with the provided user id as the admin, and returns a game id.
  Future<Result<String>> createRoom(String adminUserId, String adminName, String roomName, [String password]);

  Stream<List<Player>> getRoomPlayersUpdates(String roomName);

}