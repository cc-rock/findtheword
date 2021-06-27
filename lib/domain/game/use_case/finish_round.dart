import 'package:findtheword/domain/common/result.dart';
import 'package:findtheword/domain/game/use_case/save_round_data.dart';
import 'package:findtheword/domain/game/word.dart';

class FinishRound {
  SaveRoundData _saveRoundData;

  FinishRound(this._saveRoundData);

  Future<Result<void>> invoke(String gameId, String letter, List<Word> words) async {
    try {
      await _saveRoundData.invoke(gameId, letter, words);
      return Result.success("");
    } catch (error) {
      return Result.error(error);
    }
  }
}