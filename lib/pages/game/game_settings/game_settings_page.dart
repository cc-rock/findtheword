import 'package:findtheword/pages/game/game_settings/game_settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GameSettingsPage extends StatelessWidget {

  final GameSettingsState _initialState;

  GameSettingsPage(this._initialState);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GameSettingsBloc>(
        create: (context) => GameSettingsBloc.fromContext(context, _initialState),
        child: Center(
          child: Container(
              constraints: BoxConstraints(maxWidth: 400, maxHeight: 700),
              child: Column(
                children: [
                  Text("Game Settings"),
                  Expanded(child: Container())
                ],
              )
          ),
        )
    );
  }

}