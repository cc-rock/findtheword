import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'review_round_bloc.freezed.dart';
part 'review_round_bloc.g.dart';

@freezed
class ReviewRoundEvent with _$ReviewRoundEvent {
  factory ReviewRoundEvent() = _ReviewRoundEvent;
  factory ReviewRoundEvent.fromJson(Map<String, dynamic> json) => _$ReviewRoundEventFromJson(json);
}

@freezed
class ReviewRoundState with _$ReviewRoundState {
  factory ReviewRoundState() = _ReviewRoundState;
  factory ReviewRoundState.fromJson(Map<String, dynamic> json) => _$ReviewRoundStateFromJson(json);
}

class ReviewRoundBloc extends Bloc<ReviewRoundEvent, ReviewRoundState> {

  ReviewRoundBloc(ReviewRoundState initialState) : super(initialState);

  @override
  Stream<ReviewRoundState> mapEventToState(ReviewRoundEvent event) {
    // TODO: implement mapEventToState
    throw UnimplementedError();
  }

  factory ReviewRoundBloc.fromContext(BuildContext context, ReviewRoundState initialState) {
    return ReviewRoundBloc(initialState);
  }

}
