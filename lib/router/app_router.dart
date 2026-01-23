import 'package:flutter/material.dart';
import 'package:pointolio/features/create_game/presentation/create_game_page.dart';
import 'package:pointolio/features/home/presentation/home_page.dart';
import 'package:pointolio/features/manage/presentation/manage_page.dart';
import 'package:pointolio/features/scoring/presentation/scoring_page.dart';

class AppRouter {
  static const String home = '/';
  static const String createGame = '/create-game';
  static const String scoring = '/scoring';
  static const String manage = '/manage';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case createGame:
        return MaterialPageRoute(builder: (_) => const CreateGamePage());
      case manage:
        return MaterialPageRoute(builder: (_) => const ManagePage());
      case scoring:
        final arg = settings.arguments;
        final gameId = arg is int ? arg : null;

        if (gameId == null) {
          return MaterialPageRoute(
            builder: (_) => const Scaffold(
              body: Center(child: Text('Missing gameId for scoring route')),
            ),
          );
        }

        return MaterialPageRoute(builder: (_) => ScoringPage(gameId: gameId));
      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
