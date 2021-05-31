import 'package:freezed_annotation/freezed_annotation.dart';

part 'ongoing_round.freezed.dart';

@freezed
abstract class OngoingRound with _$OngoingRound {
  factory OngoingRound(String letter, int startTime, bool finishing) = _OngoingRound;
}