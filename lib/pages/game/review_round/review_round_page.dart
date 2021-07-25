import 'package:findtheword/app/navigation/navigation_cubit.dart';
import 'package:findtheword/pages/game/review_round/review_round_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReviewRoundPage extends StatelessWidget {
  final ReviewRoundState _initialState;

  ReviewRoundPage(this._initialState);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReviewRoundBloc>(
        create: (context) => ReviewRoundBloc.fromContext(context, _initialState),
        child: Center(
            child: Container(
                constraints: BoxConstraints(maxWidth: 400, maxHeight: 700),
                child: BlocBuilder<ReviewRoundBloc, ReviewRoundState>(
                    builder: (context, state) {
                      if (state.loading) {
                        return Center(child: CircularProgressIndicator());
                      }
                      int prevGroup = state.rows[0].group ?? 0;
                      bool altBkg = false;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                                "${state.category[0].toUpperCase()}${state.category.substring(1)}",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              children: [
                                ...state.rows.map((row) {
                                  if (row.group != prevGroup) {
                                    altBkg = !altBkg;
                                    prevGroup = row.group ?? 0;
                                  }
                                  return _rowWidget(context, row, state.admin, altBkg);
                                })
                              ],
                            ),
                          ),
                          _nextButton(context, state.admin),
                          BlocListener<ReviewRoundBloc, ReviewRoundState>(
                            listener: (context, state) {
                              BlocProvider.of<NavigationCubit>(context).goToScoreboard(state.gameId);
                            },
                            listenWhen: (prev, next) => next.goToScoreboard,
                            child: Container(),
                          )
                        ],
                      );
                    }
                )
            )
        )
    );
  }

  Widget _nextButton(BuildContext context, bool admin) {
    if (admin) {
      return ElevatedButton(
          onPressed: () {
            BlocProvider.of<ReviewRoundBloc>(context).add(ReviewRoundEvent.nextClicked());
          },
          child: Text("Next Category")
      );
    } else {
      return Container();
    }
  }

  Widget _rowWidget(BuildContext context, RoundReviewRow row, bool admin, bool altBackground) {
    final validText = row.valid ? "Valid" : "Not valid";
    return Container(
      color: altBackground ? Color.fromARGB(255, 200, 200, 200) : Color.fromARGB(0, 200, 200, 200),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: "${row.playerName}: ", style: TextStyle(fontWeight: FontWeight.bold)),
                        TextSpan(text: row.word)
                      ]
                    ),
                    textAlign: TextAlign.left,
                  ),
                  admin ? Padding(
                    padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 0),
                    child: ElevatedButton(child: Text(validText), onPressed: () {
                      BlocProvider.of<ReviewRoundBloc>(context).add(ReviewRoundEvent.wordValidEdited(row.playerId, !row.valid));
                    }),
                  ) : RichText(text: TextSpan(
                      children: [
                        row.valid ?
                        TextSpan(text: "V ", style: TextStyle(color: Color.fromARGB(255, 0, 255, 0)),) :
                        TextSpan(text: "X ", style: TextStyle(color: Color.fromARGB(255, 255 , 0, 0)),),
                        TextSpan(text: validText)
                      ]
                  ), textAlign: TextAlign.left,),
                  admin ? Row(children: [
                    Text("Same as:  "),
                    DropdownButton<int>(
                      value: row.unique ? -1 : row.group,
                      items: row.groupChoices.map((grp) => DropdownMenuItem(child: Text(grp.label, overflow: TextOverflow.ellipsis,), value: grp.group,)).toList(),
                      onChanged: (value) {BlocProvider.of<ReviewRoundBloc>(context).add(ReviewRoundEvent.wordSameAsEdited(row.playerId, value ?? -1)); },
                    )
                  ]) : Text(row.unique ? "Unique" : "Not unique", textAlign: TextAlign.left,)
                ]
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Points: ${row.points}"),
          )
        ],
      ),
    );
  }

}