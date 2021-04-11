import 'package:findtheword/domain/common/player.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'room.freezed.dart';
part 'room.g.dart';

@freezed
abstract class Room with _$Room {
  factory Room(String name, List<Player> players, RoomStatus status) = _Room;
  factory Room.fromJson(Map<String, dynamic> json) => _$RoomFromJson(json);
}

enum RoomStatus {
  nonExistent,
  available,
  availableWithPassword,
  unavailable
}