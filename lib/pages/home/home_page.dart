import 'package:findtheword/app/app_bloc.dart';
import 'package:findtheword/pages/home/home_page_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomePageBloc>(
      create: (context) => HomePageBloc(BlocProvider.of<AppBloc>(context).injector.repository)..add(HomePageEvent.loadHomePage()),
      child: Scaffold(
        appBar: AppBar(title: BlocBuilder<HomePageBloc, HomePageState>(
          builder: (context, state) => state.when(
              loading: () => Text("Loading..."),
              error: (message) => Text("Error"),
              homePageData: (userId, listItems) => Text(userId)
          ),
          buildWhen: (previous, current) {
            return (current is HomePageData && previous is HomePageData && current.userId != previous.userId)
              || (current != previous);
          }
        )),
        body: BlocBuilder<HomePageBloc, HomePageState>(
            builder: (context, state) => state.when(
                loading: () => Center(child: CircularProgressIndicator()),
                error: (message) => Center(child: Text(message)),
                homePageData: (userId, listItems) => ListView(
                  children: listItems.map((item) => Text(item)).toList(),
                )
            ),
            buildWhen: (previous, current) {
              return (current is HomePageData && previous is HomePageData && current.listItems != previous.listItems)
                  || (current != previous);
            }
        ),
      ),
    );
  }

}