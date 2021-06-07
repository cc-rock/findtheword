import 'package:findtheword/pages/game/review_round/review_round_bloc.dart';
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
                child: BlocBuilder<ReviewRoundBloc, ReviewRoundState>(builder: (context, state) => Container())
            )
        )
    );
  }

}