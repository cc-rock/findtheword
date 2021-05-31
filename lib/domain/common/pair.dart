import 'package:freezed_annotation/freezed_annotation.dart';

part 'pair.freezed.dart';

@freezed
abstract class Pair<A,B> with _$Pair<A,B> {
  factory Pair(A first, B second) = _Pair;
}