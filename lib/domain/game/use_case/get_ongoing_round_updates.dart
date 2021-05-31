import 'package:findtheword/domain/common/pair.dart';
import 'package:findtheword/domain/game/game_repository.dart';
import 'package:findtheword/domain/game/ongoing_round.dart';

import '../word.dart';

class GetOngoingRoundUpdates {
  GameRepository _gameRepository;

  GetOngoingRoundUpdates(this._gameRepository);

  Stream<Pair<OngoingRound, List<Word>>> invoke(String gameId) async* {
    final List<String> categories = await _gameRepository.getCategories(gameId);
    final List<Word> initialWords = categories.map((cat) => Word(cat, "", false, "")).toList();
    yield* _gameRepository.getOngoingRoundUpdates(gameId).map((upcoming) => Pair(upcoming, initialWords));
  }
}