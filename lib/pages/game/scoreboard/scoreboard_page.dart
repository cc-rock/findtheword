import 'package:findtheword/pages/game/scoreboard/scoreboard_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ScoreboardPage extends StatelessWidget {
  final ScoreboardState _initialState;

  ScoreboardPage(this._initialState);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ScoreboardBloc>(
        create: (context) => ScoreboardBloc.fromContext(context, _initialState),
        child: Center(
            child: Container(
                constraints: BoxConstraints(maxWidth: 400, maxHeight: 700),
                child: BlocBuilder<ScoreboardBloc, ScoreboardState>(builder: (context, state) => Container())
            )
        )
    );
  }

}