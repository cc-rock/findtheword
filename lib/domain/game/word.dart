import 'package:freezed_annotation/freezed_annotation.dart';

part 'word.freezed.dart';
part 'word.g.dart';

@freezed
class Word with _$Word {
  factory Word(
    String category,
    String word,
    bool valid,
    String sameAs,
    [@Default("") String playerId,
    @Default(0) int numDuplicates]
  ) = _Word;
  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);
}