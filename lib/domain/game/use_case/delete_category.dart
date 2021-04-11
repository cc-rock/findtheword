import 'package:findtheword/domain/common/result.dart';

import '../game_repository.dart';

class DeleteCategory {

  GameRepository _repository;

  DeleteCategory(this._repository);

  Future<Result<void>> invoke(String gameId, String category) async {
    try {
      String normalizedCategory = category.toLowerCase();
      List<String> categories = await _repository.getCategories(gameId);
      if (categories.contains(normalizedCategory)) {
        categories.remove(normalizedCategory);
        await _repository.saveCategories(gameId, categories);
      }
      return Result.success("");
    } catch (e) {
      return Result.error(e);
    }
  }

}