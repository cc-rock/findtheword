import 'package:findtheword/domain/game/word.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'round.freezed.dart';

@freezed
class Round with _$Round {
  factory Round(
      String letter,
      String? firstToFinish,
      Map<String, List<Word>> playersWords
      ) = _Round;
}