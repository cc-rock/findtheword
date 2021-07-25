import 'package:findtheword/app/navigation/navigation_cubit.dart';
import 'package:findtheword/domain/game/scoreboard.dart';
import 'package:findtheword/pages/game/scoreboard/scoreboard_bloc.dart';
import 'package:flutter/material.dart';
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
                child: BlocBuilder<ScoreboardBloc, ScoreboardState>(builder: (context, state) {
                  if (state.scoreboard == null) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Scoreboard", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                      ),
                      Expanded(child: ListView(children: state.scoreboard!.rows.map((row) => _rowWidget(context, row)).toList(),)),
                      _buttons(context, state.admin),
                      BlocListener<ScoreboardBloc, ScoreboardState>(
                        listener: (context, state) {
                          switch(state.navAction) {
                            case ScoreboardNavAction.goToNextRound:
                              BlocProvider.of<NavigationCubit>(context).goToPlayRound(state.gameId);
                              break;
                            case ScoreboardNavAction.goToHome:
                              BlocProvider.of<NavigationCubit>(context).goToHomePage("", "");
                              break;
                            default:
                              break;
                          }
                        },
                        listenWhen: (prev, next) => next.navAction != null,
                        child: Container(),
                      )
                    ],
                  );
                })
            )
        )
    );
  }

  Widget _rowWidget(BuildContext context, ScoreboardRow row) {
    return Row(
      children: [
        Text(row.playerName),
        Text("  "),
        Text("${row.points}")
      ],
    );
  }

  Widget _buttons(BuildContext context, bool admin) {
    if (!admin) {
      return Container();
    }
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
              onPressed: () {
                BlocProvider.of<ScoreboardBloc>(context).add(ScoreboardEvent.nextRoundClicked());
              },
              child: Text("Next Round")
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
              onPressed: () {
                  BlocProvider.of<ScoreboardBloc>(context).add(ScoreboardEvent.finishGameClicked());
              },
              child: Text("Finish Game")
          ),
        )
      ],
    );
  }

}