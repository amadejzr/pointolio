import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/exception/domain_exception.dart';
import 'package:pointolio/common/result/action_result.dart';
import 'package:pointolio/features/manage/data/players_management_repository.dart';
import 'package:pointolio/features/manage/presentation/cubit/players_management_cubit.dart';

import '../../../utils/fixtures.dart';

class MockPlayersRepository extends Mock
    implements PlayersManagementRepository {}

void main() {
  late MockPlayersRepository repo;

  setUp(() {
    repo = MockPlayersRepository();
  });

  PlayersManagementCubit build() =>
      PlayersManagementCubit(repository: repo);

  group('loadPlayers', () {
    blocTest<PlayersManagementCubit, PlayersManagementState>(
      'emits loading then loaded with the streamed players',
      build: () {
        when(() => repo.watchAllPlayers()).thenAnswer(
          (_) => Stream.value([playerRow(id: 1, firstName: 'Amy')]),
        );
        return build();
      },
      act: (cubit) => cubit.loadPlayers(),
      expect: () => [
        isA<PlayersManagementState>()
            .having((s) => s.status, 'status', PlayersManagementStatus.loading),
        isA<PlayersManagementState>()
            .having((s) => s.status, 'status', PlayersManagementStatus.loaded)
            .having((s) => s.players.length, 'players', 1),
      ],
    );

    blocTest<PlayersManagementCubit, PlayersManagementState>(
      'emits loading then error when the stream errors',
      build: () {
        when(() => repo.watchAllPlayers()).thenAnswer(
          (_) => Stream.error(const DomainException(DomainErrorCode.storage)),
        );
        return build();
      },
      act: (cubit) => cubit.loadPlayers(),
      expect: () => [
        isA<PlayersManagementState>()
            .having((s) => s.status, 'status', PlayersManagementStatus.loading),
        isA<PlayersManagementState>()
            .having((s) => s.status, 'status', PlayersManagementStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );
  });

  group('addPlayer', () {
    test('returns ActionSuccess when the repository succeeds', () async {
      when(
        () => repo.addPlayer(
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          color: any(named: 'color'),
        ),
      ).thenAnswer((_) async {});
      final cubit = build();

      final result = await cubit.addPlayer('Amy', null, null);

      expect(result, isA<ActionSuccess>());
      await cubit.close();
    });

    test('maps a conflict to a friendly ActionFailure', () async {
      when(
        () => repo.addPlayer(
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          color: any(named: 'color'),
        ),
      ).thenThrow(const DomainException(DomainErrorCode.conflict));
      final cubit = build();

      final result = await cubit.addPlayer('Amy', null, null);

      expect(result, isA<ActionFailure>());
      expect(
        (result as ActionFailure).message,
        'A player with this name already exists',
      );
      await cubit.close();
    });
  });

  group('updatePlayer', () {
    blocTest<PlayersManagementCubit, PlayersManagementState>(
      'clears the player-to-edit on success',
      build: () {
        when(
          () => repo.updatePlayer(
            any(),
            firstName: any(named: 'firstName'),
            lastName: any(named: 'lastName'),
            color: any(named: 'color'),
          ),
        ).thenAnswer((_) async {});
        return build();
      },
      seed: () => PlayersManagementState.initial()
          .copyWith(playerToEdit: playerRow(id: 1, firstName: 'Amy')),
      act: (cubit) => cubit.updatePlayer(1, 'Amy', null, null),
      expect: () => [
        isA<PlayersManagementState>()
            .having((s) => s.playerToEdit, 'playerToEdit', isNull),
      ],
    );

    test('maps notFound to "Player not found"', () async {
      when(
        () => repo.updatePlayer(
          any(),
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          color: any(named: 'color'),
        ),
      ).thenThrow(const DomainException(DomainErrorCode.notFound));
      final cubit = build();

      final result = await cubit.updatePlayer(1, 'Amy', null, null);

      expect((result as ActionFailure).message, 'Player not found');
      await cubit.close();
    });
  });

  group('deletePlayer', () {
    blocTest<PlayersManagementCubit, PlayersManagementState>(
      'clears the delete confirmation and returns success',
      build: () {
        when(() => repo.deletePlayer(any())).thenAnswer((_) async {});
        return build();
      },
      seed: () =>
          PlayersManagementState.initial().copyWith(playerToDeleteId: 1),
      act: (cubit) async {
        final result = await cubit.deletePlayer(1);
        expect(result, isA<ActionSuccess>());
      },
      expect: () => [
        isA<PlayersManagementState>()
            .having((s) => s.playerToDeleteId, 'playerToDeleteId', isNull),
      ],
    );
  });

  group('search & dialog state', () {
    blocTest<PlayersManagementCubit, PlayersManagementState>(
      'setSearchQuery stores the query, then clears it on blank input',
      build: build,
      act: (cubit) {
        cubit
          ..setSearchQuery('am')
          ..setSearchQuery('   ');
      },
      expect: () => [
        isA<PlayersManagementState>()
            .having((s) => s.searchQuery, 'searchQuery', 'am'),
        isA<PlayersManagementState>()
            .having((s) => s.searchQuery, 'searchQuery', isNull),
      ],
    );

    test('filteredPlayers matches first name, last name and full name', () {
      const state = PlayersManagementState();
      final populated = state.copyWith(
        players: [
          playerRow(id: 1, firstName: 'Amy', lastName: 'Adams'),
          playerRow(id: 2, firstName: 'Bob', lastName: 'Smith'),
        ],
      );

      expect(
        populated.copyWith(searchQuery: 'amy').filteredPlayers.single.id,
        1,
      );
      expect(
        populated.copyWith(searchQuery: 'smith').filteredPlayers.single.id,
        2,
      );
      expect(
        populated.copyWith(searchQuery: 'bob smith').filteredPlayers.single.id,
        2,
      );
      expect(populated.copyWith(searchQuery: 'zzz').filteredPlayers, isEmpty);
    });
  });

  test('close cancels the players subscription', () async {
    final controller = StreamController<List<Player>>();
    when(() => repo.watchAllPlayers()).thenAnswer((_) => controller.stream);

    final cubit = build()..loadPlayers();
    await Future<void>.delayed(Duration.zero);
    expect(controller.hasListener, isTrue);

    await cubit.close();
    expect(controller.hasListener, isFalse);
    await controller.close();
  });
}
