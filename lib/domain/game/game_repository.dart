import 'package:findtheword/domain/common/player.dart';
import 'package:findtheword/domain/game/game.dart';
import 'package:findtheword/domain/game/ongoing_round.dart';

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

  Stream<OngoingRound> getOngoingRoundUpdates(String gameId);

}