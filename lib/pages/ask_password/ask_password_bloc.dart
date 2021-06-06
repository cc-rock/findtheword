import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ask_password_bloc.freezed.dart';
part 'ask_password_bloc.g.dart';

class PasswordEnteredEvent {
  final String password;
  PasswordEnteredEvent(this.password);
}

@freezed
class AskPasswordState with _$AskPasswordState {
  factory AskPasswordState(String playerName, String roomName, [String? password, @Default(false) bool goToJoinPage]) = _AskPasswordState;
  factory AskPasswordState.fromJson(Map<String, dynamic> json) => _$AskPasswordStateFromJson(json);
}

class AskPasswordBloc extends Bloc<PasswordEnteredEvent, AskPasswordState> {
  AskPasswordBloc(AskPasswordState initialState) : super(initialState);

  @override
  Stream<AskPasswordState> mapEventToState(PasswordEnteredEvent event) {
    return Stream.fromFuture(
      Future.value(state.copyWith(password: event.password, goToJoinPage: true))
    );
  }

}