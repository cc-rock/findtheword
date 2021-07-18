import 'dart:math';

import 'package:findtheword/domain/game/word.dart';

class ComputeWordPoints {
  int invoke(Word word, int numPlayers) {
    if (!word.valid) {
      return 0;
    }
    return 10 - max(1, 10 ~/ word.numDuplicates);
  }
}