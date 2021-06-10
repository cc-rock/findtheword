import 'package:findtheword/data/converter/common_converters.dart';
import 'package:findtheword/data/converter/game_converters.dart';
import 'package:findtheword/data/dto/game_dtos.dart';
import 'package:findtheword/domain/common/player.dart';
import 'package:findtheword/domain/game/game.dart';
import 'package:findtheword/domain/game/game_repository.dart';
import 'package:findtheword/domain/game/ongoing_round.dart';
import 'package:findtheword/domain/game/round.dart';
import 'package:findtheword/domain/game/word.dart';
import 'package:findtheword/firebase/db_wrapper.dart';

class GameRepositoryImpl implements GameRepository {

  DbWrapper _dbWrapper;

  GameRepositoryImpl(this._dbWrapper);

  @override
  Future<void> createGame(String gameId, String roomName, String adminId,
      List<Player> players, GameSettings settings
  ) {
    return _dbWrapper.set("/games/$gameId", GameDTO(
        roomName,
        playersToDTOs(players),
        adminId,
        [],
        gameSettingsToDTO(settings),
        null,
        {},
        settings.letterPool
    ).toJson());
  }

  @override
  Future<List<String>> getCategories(String gameId) {
    return _dbWrapper.once("games/$gameId/categories").then(categoriesFromRaw);
  }

  @override
  Stream<List<String>> getCategoriesUpdates(String gameId) {
    return _dbWrapper.onValue("games/$gameId/categories").map(categoriesFromRaw);
  }

  @override
  Stream<GameSettings> getSettingsUpdates(String gameId) {
    return _dbWrapper.onValue("games/$gameId/settings").map((json) =>
        gameSettingsFromDTO(GameSettingsDTO.fromJson(json))
    );
  }

  @override
  Future<void> saveCategories(String gameId, List<String> categories) {
    return _dbWrapper.set("games/$gameId/categories", categories);
  }

  @override
  Future<String> getGameAdminId(String gameId) {
    return _dbWrapper.once("games/$gameId/admin").then((value) => value as String);
  }

  @override
  Future<void> saveSettings(String gameId, GameSettings settings) {
    return _dbWrapper.set("games/$gameId/settings", gameSettingsToDTO(settings).toJson());
  }

  @override
  Future<String> getAvailableLetters(String gameId) {
    return _dbWrapper.once("games/$gameId/available_letters").then((value) => value as String);
  }

  @override
  Future<void> saveAvailableLetters(String gameId, String availableLetters) {
    return _dbWrapper.set("games/$gameId/available_letters", availableLetters);
  }

  @override
  Future<GameSettings> getSettings(String gameId) {
    return _dbWrapper.once("games/$gameId/settings").then((json) =>
        gameSettingsFromDTO(GameSettingsDTO.fromJson(json))
    );
  }

  @override
  Future<void> saveOngoingRound(String gameId, OngoingRound ongoingRound) {
    return _dbWrapper.set("games/$gameId/ongoing_round", OngoingRoundDTO(ongoingRound.letter, ongoingRound.startTime, ongoingRound.finishingPlayerId).toJson());
  }

  @override
  Stream<OngoingRound?> getOngoingRoundUpdates(String gameId) {
    return _dbWrapper.onValue("games/$gameId/ongoing_round").map((json) {
      if (json == null) {
        return null;
      }
      final OngoingRoundDTO dto = OngoingRoundDTO.fromJson(json);
      return OngoingRound(dto.letter, dto.startTimestamp, dto.finishingPlayerId);
    });
  }

  @override
  Future<OngoingRound> getOngoingRound(String gameId) {
    return _dbWrapper.once("games/$gameId/ongoing_round").then((json) {
      final OngoingRoundDTO dto = OngoingRoundDTO.fromJson(json);
      return OngoingRound(dto.letter, dto.startTimestamp, dto.finishingPlayerId);
    });
  }

  @override
  Future<void> saveRoundData(String gameId, String playerId, String letter, List<Word> words) {
    return _dbWrapper.set(
        "games/$gameId/rounds/$letter/players_words/$playerId",
        words.map((word) => WordDTO(word.category, word.word, word.valid, "").toJson()).toList()
    );
  }

  @override
  Stream<Round> getAllRoundDataUpdates(String gameId, String letter) {
    return _dbWrapper.onValue("/games/$gameId/rounds/$letter").map((json) {
      final dto = RoundDTO.fromJson(json as Map<String, dynamic>);
      return roundFromDto(letter, dto);
    });
  }

  @override
  Stream<int?> getNextReviewedCategoryUpdates(String gameId, String letter) {
    return _dbWrapper.onValue("/games/$gameId/rounds/$letter/nextReviewedCategory").map((index) => index as int?);
  }

  @override
  Future<void> setNextReviewedCategory(String gameId, String letter, int categoryIndex) {
    return _dbWrapper.set("/games/$gameId/rounds/$letter/nextReviewedCategory", categoryIndex);
  }

}