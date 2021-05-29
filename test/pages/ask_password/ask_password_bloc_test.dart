import 'package:bloc_test/bloc_test.dart';
import 'package:findtheword/pages/ask_password/ask_password_bloc.dart';

void main() {

  blocTest<AskPasswordBloc, AskPasswordState>("When a password is entered, it is passed back in the next state and navigation is triggered",
    build: () => AskPasswordBloc(AskPasswordState("playerName", "roomName")),
    act: (bloc) => bloc.add(PasswordEnteredEvent("thePassword")),
    expect: () => [AskPasswordState("playerName", "roomName", "thePassword", true)]
  );

}