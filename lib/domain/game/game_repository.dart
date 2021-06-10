import 'package:findtheword/domain/common/player.dart';
import 'package:findtheword/domain/game/game.dart';
import 'package:findtheword/domain/game/ongoing_round.dart';
import 'package:findtheword/domain/game/round.dart';
import 'package:findtheword/domain/game/word.dart';

abstract class GameRepository {

  Future<void> createGame(
      String gameId, String roomName, String adminId,
      List<Player> players, GameSettings settings
  );

  Future<void> saveCategories(String gameId, List<String> categories);

  Future<List<String>> getCategories(String gameId);

  Stream<List<String>> getCategoriesUpdates(String gameId);

  Stream<GameSettings> getSettingsUpdates(String gameId);

  Future<GameSettings> getSettings(String gameId);

  Future<String> getAvailableLetters(String gameId);

  Future<void> saveAvailableLetters(String gameId, String availableLetters);

  Future<String> getGameAdminId(String gameId);

  Future<void> saveSettings(String gameId, GameSettings settings);

  Future<void> saveOngoingRound(String gameId, OngoingRound ongoingRound);

  Stream<OngoingRound?> getOngoingRoundUpdates(String gameId);

  Future<OngoingRound> getOngoingRound(String gameId);

  Future<void> saveRoundData(String gameId, String playerId, String letter, List<Word> words);

  Future<void> setNextReviewedCategory(String gameId, String letter, int categoryIndex);

  Stream<int?> getNextReviewedCategoryUpdates(String gameId, String letter);

  Stream<Round> getAllRoundDataUpdates(String gameId, String letter);

}