import '../round.dart';
import '../word.dart';

class ComputeNumDuplicates {

  Round invoke(Round inputRound) {
    Map<String, int> numDup = {};
    inputRound.playersWords.values.forEach((list) {
      list.forEach((word) {
        String tag = _getTag(word);
        _ensureEntry(tag, numDup);
        if (word.sameAs.isNotEmpty) {
          _incrementEntry("${word.sameAs}-${word.category}", numDup);
        }
      });
    });
    Iterable<MapEntry<String, List<Word>>> newPlayersWords = inputRound.playersWords.entries.map(
            (entry) => MapEntry(entry.key, entry.value.map((word) => word.copyWith(numDuplicates: _getNumDuplicates(word, numDup))).toList())
    );
    return inputRound.copyWith(playersWords: Map.fromEntries(newPlayersWords));
  }

  int _getNumDuplicates(Word word, Map<String, int> numDup) {
    int numDuplicates = numDup[_getTag(word)]!;
    if (numDuplicates == 0) {
      numDuplicates = numDup["${word.sameAs}-${word.category}"]!;
    }
    return numDuplicates;
  }

  void _ensureEntry(String tag, Map<String, int> numDup) {
    if (!numDup.containsKey(tag)) {
      numDup[tag] = 0;
    }
  }

  void _incrementEntry(String tag, Map<String, int> numDup) {
    _ensureEntry(tag, numDup);
    numDup[tag] = numDup[tag]! + 1;
  }

  String _getTag(Word word) => "${word.playerId}-${word.category}";

}