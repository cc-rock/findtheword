import 'package:findtheword/pages/game/play_round/play_round_bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PlayRoundPage extends StatelessWidget {
  final PlayRoundState _initialState;

  PlayRoundPage(this._initialState);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PlayRoundBloc>(
        create: (context) => PlayRoundBloc.fromContext(context, _initialState),
        child: Center(
          child: Container(
              constraints: BoxConstraints(maxWidth: 400, maxHeight: 700),
              child: Column()
          )
        )
    );
  }

}
