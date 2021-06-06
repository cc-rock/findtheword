import 'package:findtheword/domain/common/result.dart';
import 'package:findtheword/domain/common/user_id_repository.dart';
import 'package:findtheword/domain/game/game_repository.dart';
import 'package:findtheword/domain/game/ongoing_round.dart';
import 'package:findtheword/domain/game/use_case/finish_round.dart';
import 'package:findtheword/domain/game/word.dart';

class FinishRoundEarly {
  GameRepository _gameRepository;
  UserIdRepository _userIdRepository;
  FinishRound _finishRound;

  FinishRoundEarly(this._gameRepository, this._userIdRepository, this._finishRound);

  Future<Result<void>> invoke(String gameId, String letter, List<Word> words) async {
    try {
      String userId = await _userIdRepository.currentUserId;
      OngoingRound ongoingRound = await _gameRepository.getOngoingRound(gameId);
      if (ongoingRound.finishingPlayerId == null) {
        await _gameRepository.saveOngoingRound(gameId, ongoingRound.copyWith(finishingPlayerId: userId));
      }
      await _finishRound.invoke(gameId, letter, words);
      return Result.success("");
    } catch (error) {
      return Result.error(error);
    }
  }
}