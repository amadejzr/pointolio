import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/exception/domain_exception.dart';
import 'package:pointolio/common/result/action_result.dart';
import 'package:pointolio/features/manage/data/game_types_management_repository.dart';
import 'package:pointolio/features/manage/presentation/cubit/game_types_management_cubit.dart';

import '../../../utils/fixtures.dart';

class MockGameTypesRepository extends Mock
    implements GameTypesManagementRepository {}

void main() {
  late MockGameTypesRepository repo;

  setUp(() {
    repo = MockGameTypesRepository();
  });

  GameTypesManagementCubit build() =>
      GameTypesManagementCubit(repository: repo);

  group('loadGameTypes', () {
    blocTest<GameTypesManagementCubit, GameTypesManagementState>(
      'emits loading then loaded with the streamed types',
      build: () {
        when(() => repo.watchAllGameTypes()).thenAnswer(
          (_) => Stream.value([gameTypeRow(id: 1)]),
        );
        return build();
      },
      act: (cubit) => cubit.loadGameTypes(),
      expect: () => [
        isA<GameTypesManagementState>().having(
            (s) => s.status, 'status', GameTypesManagementStatus.loading),
        isA<GameTypesManagementState>()
            .having(
                (s) => s.status, 'status', GameTypesManagementStatus.loaded)
            .having((s) => s.gameTypes.length, 'count', 1),
      ],
    );

    blocTest<GameTypesManagementCubit, GameTypesManagementState>(
      'emits error when the stream fails',
      build: () {
        when(() => repo.watchAllGameTypes()).thenAnswer(
          (_) => Stream.error(const DomainException(DomainErrorCode.storage)),
        );
        return build();
      },
      act: (cubit) => cubit.loadGameTypes(),
      expect: () => [
        isA<GameTypesManagementState>().having(
            (s) => s.status, 'status', GameTypesManagementStatus.loading),
        isA<GameTypesManagementState>()
            .having((s) => s.status, 'status', GameTypesManagementStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );
  });

  group('addGameType', () {
    test('returns ActionSuccess on success', () async {
      when(
        () => repo.addGameType(
          name: any(named: 'name'),
          lowestScoreWins: any(named: 'lowestScoreWins'),
          color: any(named: 'color'),
        ),
      ).thenAnswer((_) async {});
      final cubit = build();

      final result =
          await cubit.addGameType(name: 'Poker', lowestScoreWins: false);
      expect(result, isA<ActionSuccess>());
      await cubit.close();
    });

    test('maps a conflict to a friendly failure', () async {
      when(
        () => repo.addGameType(
          name: any(named: 'name'),
          lowestScoreWins: any(named: 'lowestScoreWins'),
          color: any(named: 'color'),
        ),
      ).thenThrow(const DomainException(DomainErrorCode.conflict));
      final cubit = build();

      final result =
          await cubit.addGameType(name: 'Poker', lowestScoreWins: false);
      expect((result as ActionFailure).message,
          'A game with this name already exists');
      await cubit.close();
    });
  });

  group('updateGameType', () {
    blocTest<GameTypesManagementCubit, GameTypesManagementState>(
      'clears the edit target on success',
      build: () {
        when(
          () => repo.updateGameType(
            any(),
            name: any(named: 'name'),
            lowestScoreWins: any(named: 'lowestScoreWins'),
            color: any(named: 'color'),
          ),
        ).thenAnswer((_) async {});
        return build();
      },
      seed: () => GameTypesManagementState.initial()
          .copyWith(gameTypeToEdit: gameTypeRow(id: 1)),
      act: (cubit) =>
          cubit.updateGameType(1, name: 'Chess', lowestScoreWins: true),
      expect: () => [
        isA<GameTypesManagementState>()
            .having((s) => s.gameTypeToEdit, 'gameTypeToEdit', isNull),
      ],
    );

    test('maps notFound to "Game not found"', () async {
      when(
        () => repo.updateGameType(
          any(),
          name: any(named: 'name'),
          lowestScoreWins: any(named: 'lowestScoreWins'),
          color: any(named: 'color'),
        ),
      ).thenThrow(const DomainException(DomainErrorCode.notFound));
      final cubit = build();

      final result =
          await cubit.updateGameType(1, name: 'Chess', lowestScoreWins: true);
      expect((result as ActionFailure).message, 'Game not found');
      await cubit.close();
    });
  });

  group('deleteGameType', () {
    blocTest<GameTypesManagementCubit, GameTypesManagementState>(
      'clears the delete confirmation and returns success',
      build: () {
        when(() => repo.deleteGameType(any())).thenAnswer((_) async {});
        return build();
      },
      seed: () => GameTypesManagementState.initial()
          .copyWith(gameTypeToDeleteId: 1),
      act: (cubit) async {
        final result = await cubit.deleteGameType(1);
        expect(result, isA<ActionSuccess>());
      },
      expect: () => [
        isA<GameTypesManagementState>()
            .having((s) => s.gameTypeToDeleteId, 'gameTypeToDeleteId', isNull),
      ],
    );
  });

  group('search & filtering', () {
    test('filteredGameTypes matches the name (case-insensitive)', () {
      const state = GameTypesManagementState();
      final populated = state.copyWith(
        gameTypes: [
          gameTypeRow(id: 1),
          gameTypeRow(id: 2, name: 'Chess'),
        ],
      );

      expect(
        populated.copyWith(searchQuery: 'che').filteredGameTypes.single.name,
        'Chess',
      );
      expect(populated.copyWith(searchQuery: 'zzz').filteredGameTypes, isEmpty);
      expect(populated.filteredGameTypes, hasLength(2)); // no query
    });

    blocTest<GameTypesManagementCubit, GameTypesManagementState>(
      'setSearchQuery stores then clears on blank',
      build: build,
      act: (cubit) {
        cubit
          ..setSearchQuery('po')
          ..setSearchQuery('  ');
      },
      expect: () => [
        isA<GameTypesManagementState>()
            .having((s) => s.searchQuery, 'searchQuery', 'po'),
        isA<GameTypesManagementState>()
            .having((s) => s.searchQuery, 'searchQuery', isNull),
      ],
    );
  });

  test('close cancels the game-types subscription', () async {
    final controller = StreamController<List<GameType>>();
    when(() => repo.watchAllGameTypes()).thenAnswer((_) => controller.stream);

    final cubit = build()..loadGameTypes();
    await Future<void>.delayed(Duration.zero);
    expect(controller.hasListener, isTrue);

    await cubit.close();
    expect(controller.hasListener, isFalse);
    await controller.close();
  });
}
