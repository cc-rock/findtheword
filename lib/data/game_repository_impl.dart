import 'package:findtheword/data/converter/common_converters.dart';
import 'package:findtheword/data/converter/game_converters.dart';
import 'package:findtheword/data/dto/game_dtos.dart';
import 'package:findtheword/domain/common/player.dart';
import 'package:findtheword/domain/game/game.dart';
import 'package:findtheword/domain/game/game_repository.dart';
import 'package:findtheword/firebase/db_wrapper.dart';

class GameRepositoryImpl implements GameRepository {

  DbWrapper _dbWrapper;

  GameRepositoryImpl(this._dbWrapper);

  @override
  Future<void> createGame(String gameId, String roomName, String adminId,
      List<Player> players, GameSettings settings
  ) {
    return _dbWrapper.set("/games/$gameId", GameDTO(
        roomName,
        playersToDTOs(players),
        adminId,
        [],
        gameSettingsToDTO(settings),
        null,
        {},
        settings.letterPool
    ).toJson());
  }

  @override
  Future<List<String>> getCategories(String gameId) {
    return _dbWrapper.once("games/$gameId/categories") as Future<List<String>>;
  }

  @override
  Stream<List<String>> getCategoriesUpdates(String gameId) {
    return _dbWrapper.onValue("games/$gameId/categories") as Stream<List<String>>;
  }

  @override
  Stream<GameSettings> getSettingsUpdates(String gameId) {
    return _dbWrapper.onValue("games/$gameId/settings").map((json) =>
        gameSettingsFromDTO(GameSettingsDTO.fromJson(json))
    );
  }

  @override
  Future<void> saveCategories(String gameId, List<String> categories) {
    return _dbWrapper.set("games/$gameId/categories", categories);
  }

  @override
  Future<String> getGameAdminId(String gameId) {
    return _dbWrapper.once("games/$gameId/admin").then((value) => value as String);
  }

  @override
  Future<void> saveSettings(String gameId, GameSettings settings) {
    return _dbWrapper.set("games/$gameId/settings", gameSettingsToDTO(settings).toJson());
  }

}