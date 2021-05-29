import 'package:findtheword/domain/common/player.dart';
import 'package:findtheword/domain/common/result.dart';
import 'package:findtheword/domain/common/user_id_repository.dart';
import 'package:findtheword/domain/game/game_repository.dart';
import 'package:findtheword/domain/game/use_case/get_default_settings.dart';

class CreateGame {
  GameRepository _gameRepository;
  GetDefaultSettings _getDefaultSettings;
  UserIdRepository _userIdRepository;

  CreateGame(this._gameRepository, this._getDefaultSettings, this._userIdRepository);

  Future<Result<void>> invoke(String gameId, String roomName, List<Player> players) async {
    try {
      String adminId = await _userIdRepository.currentUserId;
      await _gameRepository.createGame(gameId, roomName, adminId, players, _getDefaultSettings.invoke());
      return Result.success("");
    } catch (error) {
      return Result.error(error);
    }
  }
}