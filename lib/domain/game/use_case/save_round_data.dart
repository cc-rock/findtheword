import 'package:findtheword/domain/common/result.dart';
import 'package:findtheword/domain/common/user_id_repository.dart';
import 'package:findtheword/domain/game/game_repository.dart';
import 'package:findtheword/domain/game/word.dart';

class SaveRoundData {
  GameRepository _gameRepository;
  UserIdRepository _userIdRepository;

  SaveRoundData(this._gameRepository, this._userIdRepository);

  Future<Result<void>> invoke(String gameId, String letter, List<Word> words, [String? playerId]) async {
    try {
      String userId = playerId ?? await _userIdRepository.currentUserId;
      await _gameRepository.saveRoundData(gameId, userId, letter, words);
      return Result.success("");
    } catch (error) {
      return Result.error(error);
    }
  }
}