import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/di/locator.dart';
import 'package:pointolio/features/create_game/presentation/create_game_page.dart';
import 'package:pointolio/features/home/presentation/home_page.dart';
import 'package:pointolio/features/manage/presentation/game_type_form_page.dart';
import 'package:pointolio/features/manage/presentation/game_types_management_page.dart';
import 'package:pointolio/features/manage/presentation/player_form_page.dart';
import 'package:pointolio/features/manage/presentation/players_management_page.dart';
import 'package:pointolio/features/onboarding/data/onboarding_repository.dart';
import 'package:pointolio/features/onboarding/presentation/onboarding_page.dart';
import 'package:pointolio/features/scoring/presentation/scoring_page.dart';
import 'package:pointolio/features/settings/presentation/settings_page.dart';
import 'package:pointolio/router/home_shell.dart';

/// Route path constants for the app.
class AppRouter {
  const AppRouter._();

  static const String onboarding = '/onboarding';

  // Shell branches (floating bottom navbar).
  static const String parties = '/';
  static const String players = '/players';
  static const String games = '/games';

  // Full-screen routes (no navbar).
  static const String createGame = '/create-game';
  static const String gameTypeForm = '/game-form';
  static const String playerForm = '/player-form';
  static const String scoring = '/scoring';
  static const String settings = '/settings';

  /// Builds the scoring path for a given game id.
  static String scoringPath(int gameId) => '$scoring/$gameId';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _partiesNavigatorKey = GlobalKey<NavigatorState>();
final _playersNavigatorKey = GlobalKey<NavigatorState>();
final _gamesNavigatorKey = GlobalKey<NavigatorState>();

/// Creates the app [GoRouter] with the onboarding redirect wired in.
GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRouter.parties,
    redirect: (context, state) {
      final completed =
          locator<OnboardingRepository>().isOnboardingCompleted;
      final goingToOnboarding = state.matchedLocation == AppRouter.onboarding;

      if (!completed && !goingToOnboarding) return AppRouter.onboarding;
      if (completed && goingToOnboarding) return AppRouter.parties;
      return null;
    },
    routes: [
      GoRoute(
        path: AppRouter.onboarding,
        builder: (context, state) => OnboardingPage(
          onComplete: () async {
            await locator<OnboardingRepository>().completeOnboarding();
          },
        ),
      ),
      GoRoute(
        path: AppRouter.createGame,
        builder: (context, state) => const CreateGamePage(),
      ),
      GoRoute(
        path: AppRouter.gameTypeForm,
        builder: (context, state) {
          // A GameType in `extra` puts the form in edit mode; null creates one.
          final initial = state.extra as GameType?;
          return GameTypeFormPage(initial: initial);
        },
      ),
      GoRoute(
        path: AppRouter.playerForm,
        // `extra` carries the player to edit; null means create.
        builder: (context, state) =>
            PlayerFormPage(initial: state.extra as Player?),
      ),
      GoRoute(
        path: AppRouter.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '${AppRouter.scoring}/:gameId',
        builder: (context, state) {
          final gameId = int.tryParse(state.pathParameters['gameId'] ?? '');
          if (gameId == null) {
            return const Scaffold(
              body: Center(child: Text('Missing gameId for scoring route')),
            );
          }
          return ScoringPage(gameId: gameId);
        },
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            HomeShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            navigatorKey: _partiesNavigatorKey,
            routes: [
              GoRoute(
                path: AppRouter.parties,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _playersNavigatorKey,
            routes: [
              GoRoute(
                path: AppRouter.players,
                builder: (context, state) => const PlayersManagementPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _gamesNavigatorKey,
            routes: [
              GoRoute(
                path: AppRouter.games,
                builder: (context, state) => const GameTypesManagementPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
