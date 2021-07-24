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
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(state.category),
                          ),
                          ...state.rows.map((row) => _rowWidget(context, row, state.admin, state.groups)),
                          _nextButton(context, state.admin)
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

  Widget _rowWidget(BuildContext context, RoundReviewRow row, bool admin, List<RoundReviewGroup> groups) {
    final validText = Text(row.valid ? "Valid" : "Not valid");
    return Row(
      children: [
        Column(children: [Text(row.playerName, style: TextStyle(fontWeight: FontWeight.bold),), Text(row.word)]),
        admin ? ElevatedButton(child: validText, onPressed: () {
          BlocProvider.of<ReviewRoundBloc>(context).add(ReviewRoundEvent.wordValidEdited(row.playerId, !row.valid));
        }) : validText,
        Text("Same as: "),
        admin ? DropdownButton<int>(
            value: row.group,
            items: groups.map((grp) => DropdownMenuItem(child: Text(grp.label), value: grp.group,)).toList(),
            onChanged: (value) {BlocProvider.of<ReviewRoundBloc>(context).add(ReviewRoundEvent.wordSameAsEdited(row.playerId, value!)); },
        ) : Container()
      ],
    );
  }

}