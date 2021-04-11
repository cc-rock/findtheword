import 'package:findtheword/data/dto/common_dtos.dart';
import 'package:findtheword/domain/common/player.dart';

List<Player> playersFromDTOs(Map<String, PlayerDTO> dtos, String adminId) {
  final sortedEntries = dtos.entries.toList(growable: false)..sort((a, b) => a.value.timestamp - b.value.timestamp);
  return sortedEntries.map((entry) =>
      Player(entry.key, entry.value.name, entry.key == adminId)
  ).toList(growable: false);
}

Map<String, PlayerDTO> playersToDTOs(List<Player> players) {
  var order = 0;
  return Map.fromEntries(players.map((player) =>
    MapEntry(player.id, PlayerDTO(
      player.name,
      order++,
      null
    )
  )));
}