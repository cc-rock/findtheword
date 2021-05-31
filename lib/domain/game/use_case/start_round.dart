import 'package:findtheword/domain/common/result.dart';
import 'package:findtheword/domain/game/game_repository.dart';
import 'package:findtheword/domain/game/ongoing_round.dart';

class StartRound {
  GameRepository _gameRepository;
  int Function() _getCurrentTimeMillis;
  int Function(int) _getRandomInteger;

  StartRound(this._gameRepository, this._getCurrentTimeMillis, this._getRandomInteger);

  Future<Result<void>> invoke(String gameId) async {
    try {
      final String availableLetters = await _gameRepository.getAvailableLetters(gameId);
      final int letterIndex = _getRandomInteger(availableLetters.length);
      final String letter = availableLetters.substring(letterIndex, letterIndex + 1);
      final String newAvailableLetters = availableLetters.substring(0, letterIndex) + availableLetters.substring(letterIndex + 1);
      final int startTime = (_getCurrentTimeMillis() + 5000) ~/ 1000;
      await _gameRepository.saveOngoingRound(gameId, OngoingRound(letter, startTime, false));
      await _gameRepository.saveAvailableLetters(gameId, newAvailableLetters);
      return Result.success("");
    } catch (error) {
      return Result.error(error);
    }
  }
}