import 'package:findtheword/domain/join_room/room.dart';

abstract class RoomRepository {

  Future<RoomStatus> getRoomStatus(String roomName);

  Future<void> joinRoom(String playerUserId, String playerName, String roomName, [String password]);

  /// Creates a new room with the provided user id as the admin, and returns a game id.
  Future<String> createRoom(String adminUserId, String adminName, String roomName, [String password]);

  Stream<Room> getRoomUpdates(String roomName);

  Future<String> getRoomAdminId(String roomName);

}