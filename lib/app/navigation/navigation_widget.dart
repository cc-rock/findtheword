import 'package:findtheword/app/navigation/navigation_cubit.dart';
import 'package:findtheword/pages/page_factory.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NavigationWidget extends StatelessWidget {

  final Object _initialPageState;

  NavigationWidget(this._initialPageState);

  @override
  Widget build(BuildContext context) => BlocProvider(
      create: (_) => NavigationCubit(_initialPageState),
      child: BlocBuilder<NavigationCubit, NavigationState>(
        builder: (context, state) => PageFactory.fromPageState(state.pageState),
      ),
  );

}