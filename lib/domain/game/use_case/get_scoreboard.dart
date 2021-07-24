import 'package:findtheword/domain/game/game_repository.dart';
import 'package:findtheword/domain/game/round.dart';
import 'package:findtheword/domain/game/scoreboard.dart';
import 'package:findtheword/domain/game/use_case/compute_num_duplicates.dart';
import 'package:findtheword/domain/game/use_case/compute_word_points.dart';
import 'package:findtheword/domain/game/word.dart';

class GetScoreboard {
  GameRepository _gameRepository;
  ComputeNumDuplicates _computeNumDuplicates;
  ComputeWordPoints _computeWordPoints;

  GetScoreboard(this._gameRepository, this._computeNumDuplicates, this._computeWordPoints);

  Future<Scoreboard> invoke(String gameId) async {
    final rounds = await _gameRepository.getAllRounds(gameId);
    final players = await _gameRepository.getPlayers(gameId);
    final Map<String, int> scores = {};
    for(Round round in rounds) {
      round = _computeNumDuplicates.invoke(round);
      for (final MapEntry<String, List<Word>> entry in round.playersWords.entries) {
        if (scores[entry.key] == null) {
          scores[entry.key] = 0;
        }
        for (final Word word in entry.value) {
          scores[entry.key] = scores[entry.key]! + _computeWordPoints.invoke(word, players.length);
        }
      }
    }
    return Scoreboard(
        players.map(
                (player) => ScoreboardRow(player.id, player.name, scores[player.id]!)
        ).toList()..sort((row1, row2) => row2.points - row1.points)
    );
  }
}