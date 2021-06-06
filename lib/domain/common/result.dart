import 'package:freezed_annotation/freezed_annotation.dart';

part 'result.freezed.dart';

@freezed
class Result<T> with _$Result {
  factory Result.success(T value) = ResultSuccess;
  factory Result.error(Object error) = ResultError;
}