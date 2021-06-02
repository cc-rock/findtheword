import 'package:findtheword/domain/common/player.dart';
import 'package:findtheword/domain/common/result.dart';
import 'package:findtheword/domain/common/user_id_repository.dart';
import 'package:findtheword/domain/game/game_repository.dart';
import 'package:findtheword/domain/game/use_case/get_default_settings.dart';
import 'package:findtheword/domain/game/word.dart';

class FinishRound {
  GameRepository _gameRepository;
  UserIdRepository _userIdRepository;

  FinishRound(this._gameRepository, this._userIdRepository);

  Future<Result<void>> invoke(String gameId, List<Word> words) async {
    try {
      String userId = await _userIdRepository.currentUserId;

      return Result.success("");
    } catch (error) {
      return Result.error(error);
    }
  }
}