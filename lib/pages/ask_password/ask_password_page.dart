import 'package:findtheword/app/navigation/navigation_cubit.dart';
import 'package:findtheword/pages/ask_password/ask_password_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:indent/indent.dart';

class AskPasswordPage extends StatelessWidget {
  final AskPasswordState _initialState;
  AskPasswordPage(this._initialState);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AskPasswordBloc>(
      create: (context) => AskPasswordBloc(_initialState),
      child: BlocBuilder<AskPasswordBloc, AskPasswordState>(
        builder: (context, state) {
          TextEditingController passwordController = TextEditingController();
          if (state.goToJoinPage) {
            BlocProvider.of<NavigationCubit>(context).goToJoinRoom(state.playerName, state.roomName, state.password);
            return Container();
          }
          return Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 400, maxHeight: 700),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('''
                    The room "${state.roomName}" requires a password to be joined.
                    Please enter the password below and then press "Continue".
                    '''.unindent()),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Password',
                      ),
                      controller: passwordController,
                    ),
                  ),
                  Expanded(child: Container()),
                  ElevatedButton(
                    child: Text("Continue"),
                    onPressed: () {
                      BlocProvider.of<AskPasswordBloc>(context).add(PasswordEnteredEvent(passwordController.text));
                    }
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }


}