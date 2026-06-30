import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/exception/domain_exception.dart';
import 'package:pointolio/features/scoring/data/scoring_repository.dart';
import 'package:pointolio/features/scoring/domain/models.dart';
import 'package:pointolio/features/scoring/presentation/cubit/scoring_cubit.dart';

import '../../../utils/fixtures.dart';

class MockScoringRepository extends Mock implements ScoringRepository {}

void main() {
  late MockScoringRepository repo;
  const gameId = 1;

  setUpAll(() {
    registerFallbackValue(<int, int>{});
    registerFallbackValue(<int>[]);
  });

  setUp(() {
    repo = MockScoringRepository();
  });

  ScoringCubit build() =>
      ScoringCubit(gameId: gameId, scoringRepository: repo);

  PlayerScore playerScore(int playerId, {int order = 0}) {
    return PlayerScore(
      player: playerRow(id: playerId, firstName: 'P$playerId'),
      gamePlayer:
          gamePlayerRow(id: playerId, playerId: playerId, orderIndex: order),
      roundScores: const {},
      total: 0,
    );
  }

  Matcher hasStatus(ScoringStatus status) =>
      isA<ScoringState>().having((s) => s.status, 'status', status);

  group('addRound', () {
    blocTest<ScoringCubit, ScoringState>(
      'submits the next round number based on roundCount',
      build: () {
        when(
          () => repo.addRound(
            roundNumber: any(named: 'roundNumber'),
            scores: any(named: 'scores'),
          ),
        ).thenAnswer((_) async {});
        return build();
      },
      seed: () => ScoringState.initial(gameId).copyWith(roundCount: 2),
      act: (cubit) => cubit.addRound({10: 5, 11: 7}),
      expect: () => <ScoringState>[],
      verify: (_) => verify(
        () => repo.addRound(roundNumber: 3, scores: {10: 5, 11: 7}),
      ).called(1),
    );

    blocTest<ScoringCubit, ScoringState>(
      'emits an error state when the repository throws',
      build: () {
        when(
          () => repo.addRound(
            roundNumber: any(named: 'roundNumber'),
            scores: any(named: 'scores'),
          ),
        ).thenThrow(const DomainException(DomainErrorCode.storage));
        return build();
      },
      act: (cubit) => cubit.addRound({10: 5}),
      expect: () => [
        isA<ScoringState>()
            .having((s) => s.status, 'status', ScoringStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );
  });

  group('updateScore / deleteRound', () {
    blocTest<ScoringCubit, ScoringState>(
      'updateScore forwards to the repository',
      build: () {
        when(
          () => repo.updateScore(
            scoreEntryId: any(named: 'scoreEntryId'),
            points: any(named: 'points'),
          ),
        ).thenAnswer((_) async {});
        return build();
      },
      act: (cubit) => cubit.updateScore(5, 42),
      expect: () => <ScoringState>[],
      verify: (_) => verify(
        () => repo.updateScore(scoreEntryId: 5, points: 42),
      ).called(1),
    );

    blocTest<ScoringCubit, ScoringState>(
      'deleteRound forwards game id and round number',
      build: () {
        when(
          () => repo.deleteRound(
            gameId: any(named: 'gameId'),
            roundNumber: any(named: 'roundNumber'),
          ),
        ).thenAnswer((_) async => 1);
        return build();
      },
      act: (cubit) => cubit.deleteRound(2),
      expect: () => <ScoringState>[],
      verify: (_) => verify(
        () => repo.deleteRound(gameId: gameId, roundNumber: 2),
      ).called(1),
    );
  });

  group('finishGame / restoreGame', () {
    blocTest<ScoringCubit, ScoringState>(
      'finishGame persists and reloads the game with finishedAt set',
      build: () {
        when(() => repo.setGameFinished(gameId, finished: true))
            .thenAnswer((_) async {});
        when(() => repo.getGame(gameId)).thenAnswer(
          (_) async => gameRow(id: gameId, finishedAt: DateTime(2025, 6)),
        );
        return build();
      },
      act: (cubit) => cubit.finishGame(),
      expect: () => [
        isA<ScoringState>()
            .having((s) => s.game?.finishedAt, 'finishedAt', isNotNull),
      ],
    );

    blocTest<ScoringCubit, ScoringState>(
      'restoreGame clears finishedAt',
      build: () {
        when(() => repo.setGameFinished(gameId, finished: false))
            .thenAnswer((_) async {});
        when(() => repo.getGame(gameId))
            .thenAnswer((_) async => gameRow(id: gameId));
        return build();
      },
      act: (cubit) => cubit.restoreGame(),
      expect: () => [
        isA<ScoringState>()
            .having((s) => s.game?.finishedAt, 'finishedAt', isNull),
      ],
    );
  });

  group('reorderPlayers', () {
    blocTest<ScoringCubit, ScoringState>(
      'is a no-op when indices are equal',
      build: build,
      act: (cubit) => cubit.reorderPlayers(1, 1),
      expect: () => <ScoringState>[],
      verify: (_) => verifyNever(() => repo.reorderPlayers(any())),
    );

    blocTest<ScoringCubit, ScoringState>(
      'optimistically reorders, then persists the new order',
      build: () {
        when(() => repo.reorderPlayers(any())).thenAnswer((_) async {});
        return build();
      },
      seed: () => ScoringState.initial(gameId).copyWith(
        playerScores: [
          playerScore(1),
          playerScore(2, order: 1),
        ],
      ),
      act: (cubit) => cubit.reorderPlayers(0, 1),
      expect: () => [
        isA<ScoringState>().having(
          (s) => s.playerScores.map((p) => p.player.id),
          'optimistic order',
          [2, 1],
        ),
      ],
      verify: (_) => verify(() => repo.reorderPlayers([2, 1])).called(1),
    );

    blocTest<ScoringCubit, ScoringState>(
      'reverts to the original order when persistence fails',
      build: () {
        when(() => repo.reorderPlayers(any()))
            .thenThrow(const DomainException(DomainErrorCode.storage));
        return build();
      },
      seed: () => ScoringState.initial(gameId).copyWith(
        playerScores: [
          playerScore(1),
          playerScore(2, order: 1),
        ],
      ),
      act: (cubit) => cubit.reorderPlayers(0, 1),
      expect: () => [
        // optimistic swap
        isA<ScoringState>().having(
          (s) => s.playerScores.map((p) => p.player.id),
          'optimistic order',
          [2, 1],
        ),
        // reverted + error
        isA<ScoringState>()
            .having(
              (s) => s.playerScores.map((p) => p.player.id),
              'reverted order',
              [1, 2],
            )
            .having((s) => s.status, 'status', ScoringStatus.error),
      ],
    );
  });

  group('getAllPlayers', () {
    test('returns players from the repository', () async {
      when(repo.getAllPlayers)
          .thenAnswer((_) async => [playerRow(id: 1, firstName: 'Amy')]);
      final cubit = build();

      final players = await cubit.getAllPlayers();
      expect(players.map((p) => p.firstName), ['Amy']);
      await cubit.close();
    });

    test('returns an empty list on a DomainException', () async {
      when(repo.getAllPlayers)
          .thenThrow(const DomainException(DomainErrorCode.storage));
      final cubit = build();

      expect(await cubit.getAllPlayers(), isEmpty);
      await cubit.close();
    });
  });

  group('loadData', () {
    ScoreEntry entry(int round) => ScoreEntry(
          id: round,
          gamePlayerId: 1,
          roundNumber: round,
          points: 1,
          createdAt: DateTime(2025),
        );

    PlayerScore scoresWithRounds() => PlayerScore(
          player: playerRow(id: 1, firstName: 'Amy'),
          gamePlayer: gamePlayerRow(id: 1),
          roundScores: {1: entry(1), 2: entry(2)},
          total: 2,
        );

    // Wires up getGame/getGameType and both watch streams for a happy path.
    void stubHappyLoad() {
      when(() => repo.getGame(gameId))
          .thenAnswer((_) async => gameRow(id: gameId));
      when(() => repo.getGameType(any()))
          .thenAnswer((_) async => gameTypeRow(id: 1, lowestScoreWins: true));
      when(() => repo.watchGamePlayers(gameId)).thenAnswer(
        (_) => Stream.value([
          (playerRow(id: 1, firstName: 'Amy'), gamePlayerRow(id: 1)),
        ]),
      );
      when(() => repo.watchScoreEntries(gameId))
          .thenAnswer((_) => Stream.value([entry(1), entry(2)]));
      when(() => repo.getPlayerScores(gameId))
          .thenAnswer((_) async => [scoresWithRounds()]);
    }

    test('loads the game, type, scores and derived round count', () async {
      stubHappyLoad();
      final cubit = build();

      await cubit.loadData();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, ScoringStatus.loaded);
      expect(cubit.state.game?.id, gameId);
      expect(cubit.state.lowestScoreWins, isTrue);
      expect(cubit.state.playerScores, isNotEmpty);
      expect(cubit.state.roundCount, 2); // max round across player scores
      await cubit.close();
    });

    test('surfaces an error when the players stream fails', () async {
      when(() => repo.getGame(gameId))
          .thenAnswer((_) async => gameRow(id: gameId));
      when(() => repo.getGameType(any())).thenAnswer((_) async => null);
      when(() => repo.watchGamePlayers(gameId)).thenAnswer(
        (_) => Stream.error(const DomainException(DomainErrorCode.storage)),
      );
      when(() => repo.watchScoreEntries(gameId))
          .thenAnswer((_) => const Stream.empty());
      final cubit = build();

      await cubit.loadData();
      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.status, ScoringStatus.error);
      expect(cubit.state.errorMessage, isNotNull);
      await cubit.close();
    });

    blocTest<ScoringCubit, ScoringState>(
      'maps a DomainException while loading the game to an error state',
      build: () {
        when(() => repo.getGame(gameId))
            .thenThrow(const DomainException(DomainErrorCode.notFound));
        return build();
      },
      act: (cubit) => cubit.loadData(),
      expect: () => [
        hasStatus(ScoringStatus.loading),
        hasStatus(ScoringStatus.error),
      ],
    );
  });

  group('updateParty', () {
    blocTest<ScoringCubit, ScoringState>(
      'persists the party then reloads the game',
      build: () {
        when(
          () => repo.updateGameParty(
            gameId: any(named: 'gameId'),
            name: any(named: 'name'),
            playerIds: any(named: 'playerIds'),
          ),
        ).thenAnswer((_) async {});
        when(() => repo.getGame(gameId))
            .thenAnswer((_) async => gameRow(id: gameId, name: 'Renamed'));
        return build();
      },
      act: (cubit) => cubit.updateParty(
        name: 'Renamed',
        players: [playerRow(id: 1, firstName: 'Amy')],
      ),
      expect: () => [
        isA<ScoringState>().having((s) => s.game?.name, 'name', 'Renamed'),
      ],
      verify: (_) => verify(
        () => repo.updateGameParty(
          gameId: gameId,
          name: 'Renamed',
          playerIds: [1],
        ),
      ).called(1),
    );
  });
}
