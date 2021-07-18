import '../round.dart';
import '../word.dart';

class ComputeNumDuplicates {

  Round invoke(Round inputRound) {
    Map<String, int> numDup = {};
    inputRound.playersWords.values.forEach((list) {
      list.forEach((word) {
        _incrementEntry(word, numDup);
      });
    });
    Iterable<MapEntry<String, List<Word>>> newPlayersWords = inputRound.playersWords.entries.map(
            (entry) => MapEntry(entry.key, entry.value.map((word) => word.copyWith(numDuplicates: _getNumDuplicates(word, numDup))).toList())
    );
    return inputRound.copyWith(playersWords: Map.fromEntries(newPlayersWords));
  }

  int _getNumDuplicates(Word word, Map<String, int> numDup) {
    return numDup[_getTag(word)]!;
  }

  void _ensureEntry(String tag, Map<String, int> numDup) {
    if (!numDup.containsKey(tag)) {
      numDup[tag] = 0;
    }
  }

  void _incrementEntry(Word word, Map<String, int> numDup) {
    final tag = _getTag(word);
    _ensureEntry(tag, numDup);
    if (word.valid) {
      numDup[tag] = numDup[tag]! + 1;
    }
  }

  String _getTag(Word word) => "${word.group}-${word.category}";

}