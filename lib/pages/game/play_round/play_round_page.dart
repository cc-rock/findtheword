import 'package:findtheword/app/navigation/navigation_cubit.dart';
import 'package:findtheword/domain/game/word.dart';
import 'package:findtheword/pages/game/play_round/play_round_bloc.dart';
import 'package:flutter/material.dart';
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
              child: BlocBuilder<PlayRoundBloc, PlayRoundState> (
                builder: (context, state) => state.loading ? _buildLoadingUi(context) : _buildRoundUi(context),
                buildWhen: (prev, next) => prev.loading != next.loading,
              )
          )
        )
    );
  }

  Widget _buildLoadingUi(BuildContext context) {
    return Center(child: CircularProgressIndicator(),);
  }

  Widget _buildRoundUi(BuildContext context) => BlocBuilder<PlayRoundBloc, PlayRoundState>(
    builder: (context, state) {
      if (state.secondsToStart > 0) {
        return _buildPreStartUi(context, state);
      }
      return _buildRealRoundUi(context, state);
    },
    buildWhen: (prev, next) => prev.secondsToStart != next.secondsToStart,
  );

  Widget _buildPreStartUi(BuildContext context, PlayRoundState state) {
    if (state.secondsToStart > 3) {
      return Center(child: Text("Choosing letter..."),);
    }
    return Column(
      children: [
        Expanded(child: Center(child: Text(state.letter, style: TextStyle(fontSize: 120.0),))),
        Expanded(child: Center(child: Text(state.secondsToStart.toString(), style: TextStyle(fontSize: 120.0, color: Color.fromARGB(255, 255, 0, 0)),)))
      ],
    );
  }

  Widget _buildRealRoundUi(BuildContext context, PlayRoundState state) {
    return Column(children: [
      Row(children: [
        Expanded(child: Container(child: Text(state.letter, style: TextStyle(fontSize: 40),), alignment: Alignment.center,)),
        Expanded(child: BlocBuilder<PlayRoundBloc, PlayRoundState>(
          builder: (context, state) => Container(
            child: Text(
                state.formattedRemainingSeconds,
              style: TextStyle(color: state.remainingSeconds <= 3 ? Color.fromARGB(255, 255, 0, 0) : Color.fromARGB(255, 0, 0, 0) ),
            ),
            alignment: Alignment.center,),
        ))
      ]),
      Expanded(
        child: ListView(
          children: [
            ...state.words.map((word) => _buildCategoryRow(context, word))
          ],
        ),
      ),
      BlocBuilder<PlayRoundBloc, PlayRoundState>(builder: (context, state) => ElevatedButton(
        child: Text("Done"),
        onPressed: () async {
          bool proceed = await _showConfirmDialog(context, state) ?? false;
          if (proceed) {
            BlocProvider.of<PlayRoundBloc>(context).add(PlayRoundEvent.doneClicked());
          }
        }
      )),
      BlocListener<PlayRoundBloc, PlayRoundState>(
        listener: (context, state) {
          BlocProvider.of<NavigationCubit>(context).goToRoundReview(state.gameId);
        },
        listenWhen: (prev, next) => next.goToRoundReview,
        child: Container(),
      )
    ],);
  }

  Widget _buildCategoryRow(BuildContext context, Word word) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
                decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: word.category,
                ),
              onChanged: (text) => BlocProvider.of<PlayRoundBloc>(context).add(PlayRoundEvent.wordChanged(word.category, text)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: BlocBuilder<PlayRoundBloc, PlayRoundState>(
              builder: (context, state) =>
                state.wordForCategory(word.category).valid ?
                  Text("V", style: TextStyle(color: Color.fromARGB(255, 0, 255, 0)),) :
                  Text("X", style: TextStyle(color: Color.fromARGB(255, 255 , 0, 0)),),
              buildWhen: (prev, next) => prev.wordForCategory(word.category).valid != next.wordForCategory(word.category).valid,
            ),
          )
        ],
      ),
    );
  }

  Future<bool?> _showConfirmDialog(BuildContext context, PlayRoundState state) {
    int invalid = state.words.fold(0, (previousValue, word) => word.valid ? 0 : 1);
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        TextEditingController controller = TextEditingController();
        return AlertDialog(
          title: const Text('Finish Round?'),
          content: Text(invalid > 0 ? "You have $invalid invalid/incomplete categories." : "All categories are completed."),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );
  }

}
