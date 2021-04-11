import 'package:findtheword/domain/common/player.dart';
import 'package:findtheword/domain/common/result.dart';
import 'package:findtheword/domain/game/game.dart';
import 'package:findtheword/domain/game/game_repository.dart';

class CreateGame {
  GameRepository _gameRepository;

  CreateGame(this._gameRepository);

  Future<Result<void>> invoke(String gameId, String roomName, String adminId, List<Player> players, GameSettings settings) async {
    try {
      await _gameRepository.createGame(gameId, roomName, adminId, players, settings);
      return Result.success("");
    } catch (error) {
      return Result.error(error);
    }
  }
}