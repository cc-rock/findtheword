import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'scoreboard_bloc.freezed.dart';
part 'scoreboard_bloc.g.dart';

@freezed
class ScoreboardEvent with _$ScoreboardEvent {
  factory ScoreboardEvent() = _ScoreboardEvent;
  factory ScoreboardEvent.fromJson(Map<String, dynamic> json) => _$ScoreboardEventFromJson(json);
}

@freezed
class ScoreboardState with _$ScoreboardState {
  factory ScoreboardState() = _ScoreboardState;
  factory ScoreboardState.fromJson(Map<String, dynamic> json) => _$ScoreboardStateFromJson(json);
}

class ScoreboardBloc extends Bloc<ScoreboardEvent, ScoreboardState> {

  ScoreboardBloc(ScoreboardState initialState) : super(initialState);

  @override
  Stream<ScoreboardState> mapEventToState(ScoreboardEvent event) {
    // TODO: implement mapEventToState
    throw UnimplementedError();
  }

  factory ScoreboardBloc.fromContext(BuildContext context, ScoreboardState initialState) {
    return ScoreboardBloc(initialState);
  }

}
