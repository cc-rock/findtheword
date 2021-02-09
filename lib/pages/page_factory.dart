import 'package:findtheword/pages/ask_password/ask_password_bloc.dart';
import 'package:findtheword/pages/ask_password/ask_password_page.dart';
import 'package:findtheword/pages/create_room/create_room_bloc.dart';
import 'package:findtheword/pages/create_room/create_room_page.dart';
import 'package:findtheword/pages/home/home_page_bloc.dart';
import 'package:findtheword/pages/join_room/join_room_bloc.dart';
import 'package:findtheword/pages/join_room/join_room_page.dart';
import 'package:findtheword/pages/wait_for_players/wait_for_players_bloc.dart';
import 'package:findtheword/pages/wait_for_players/wait_for_players_page.dart';

import 'home/home_page.dart';
import 'package:flutter/material.dart';

class PageFactory {

  static Widget fromPageState(Object pageState) {
    if (pageState is HomePageState) {
      return HomePage(pageState);
    }
    if (pageState is JoinRoomState) {
      return JoinRoomPage(pageState);
    }
    if (pageState is CreateRoomState) {
      return CreateRoomPage(pageState);
    }
    if (pageState is AskPasswordState) {
      return AskPasswordPage(pageState);
    }
    if (pageState is WaitForPlayersState) {
      return WaitForPlayersPage(pageState);
    }
    throw Exception("Unknown page state");
  }

}