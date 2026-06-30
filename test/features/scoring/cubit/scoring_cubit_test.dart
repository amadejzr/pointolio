import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
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
}
