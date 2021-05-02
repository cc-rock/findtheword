import 'package:freezed_annotation/freezed_annotation.dart';

part 'common_dtos.freezed.dart';
part 'common_dtos.g.dart';

@freezed
abstract class PlayerDTO with _$PlayerDTO {
  factory PlayerDTO(String name, int timestamp, @nullable String password) = _PlayerDTO;
  factory PlayerDTO.fromJson(Map<String, dynamic> json) => _$PlayerDTOFromJson(json);
}