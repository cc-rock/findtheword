import 'package:findtheword/domain/common/result.dart';
import 'package:findtheword/domain/game/game_repository.dart';

import '../round.dart';

class SaveAllRoundData {
  GameRepository _gameRepository;

  SaveAllRoundData(this._gameRepository);

  Future<Result<void>> invoke(String gameId, Round round) async {
    try {
      await _gameRepository.saveAllRoundData(gameId, round);
      return Result.success("");
    } catch (error) {
      return Result.error(error);
    }
  }
}