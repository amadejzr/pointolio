import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pointolio/common/exception/domain_exception.dart';
import 'package:pointolio/features/create_game/data/create_game_repository.dart';
import 'package:pointolio/features/create_game/presentation/cubit/create_game_cubit.dart';
import 'package:pointolio/features/create_game/presentation/cubit/create_game_state.dart';
import 'package:pointolio/features/create_game/presentation/cubit/create_game_validation.dart';

import '../../../utils/fixtures.dart';

class MockCreateGameRepository extends Mock implements CreateGameRepository {}

void main() {
  late MockCreateGameRepository repo;

  setUpAll(() {
    // Needed for `any(named: 'playerIds')` (non-primitive type).
    registerFallbackValue(<int>[]);
  });

  setUp(() {
    repo = MockCreateGameRepository();
  });

  CreateGameCubit build() => CreateGameCubit(createGameRepository: repo);

  // A ready-to-submit state (valid form) with a fixed date for determinism.
  CreateGameState validState() => CreateGameState(
        gameDate: DateTime(2025),
        gameName: 'Friday Night',
        selectedGameType: gameTypeRow(id: 1),
        selectedPlayers: [
          playerRow(id: 1, firstName: 'Amy'),
          playerRow(id: 2, firstName: 'Bob'),
        ],
      );

  Matcher hasStatus(CreateGameStatus status) =>
      isA<CreateGameState>().having((s) => s.status, 'status', status);

  group('loadData', () {
    blocTest<CreateGameCubit, CreateGameState>(
      'emits loading then populates available types and players',
      build: () {
        when(repo.getAllGameTypes)
            .thenAnswer((_) async => [gameTypeRow(id: 1)]);
        when(repo.getAllPlayers)
            .thenAnswer((_) async => [playerRow(id: 1, firstName: 'Amy')]);
        return build();
      },
      act: (cubit) => cubit.loadData(),
      expect: () => [
        hasStatus(CreateGameStatus.loading),
        isA<CreateGameState>()
            .having((s) => s.status, 'status', CreateGameStatus.initial)
            .having((s) => s.availableGameTypes.length, 'gameTypes', 1)
            .having((s) => s.availablePlayers.length, 'players', 1),
      ],
    );

    blocTest<CreateGameCubit, CreateGameState>(
      'maps a DomainException to a blocking error message',
      build: () {
        when(repo.getAllGameTypes).thenThrow(
          const DomainException(DomainErrorCode.storage),
        );
        return build();
      },
      act: (cubit) => cubit.loadData(),
      expect: () => [
        hasStatus(CreateGameStatus.loading),
        isA<CreateGameState>()
            .having((s) => s.status, 'status', CreateGameStatus.error)
            .having((s) => s.errorMessage, 'errorMessage', isNotNull),
      ],
    );
  });

  group('player selection', () {
    blocTest<CreateGameCubit, CreateGameState>(
      'addPlayer ignores duplicates by id',
      build: build,
      act: (cubit) {
        final amy = playerRow(id: 1, firstName: 'Amy');
        cubit
          ..addPlayer(amy)
          ..addPlayer(amy);
      },
      expect: () => [
        isA<CreateGameState>()
            .having((s) => s.selectedPlayers.length, 'count', 1),
      ],
    );

    blocTest<CreateGameCubit, CreateGameState>(
      'removePlayer removes by id',
      build: build,
      seed: validState,
      act: (cubit) => cubit.removePlayer(1),
      expect: () => [
        isA<CreateGameState>().having(
          (s) => s.selectedPlayers.map((p) => p.id),
          'remaining ids',
          [2],
        ),
      ],
    );

    blocTest<CreateGameCubit, CreateGameState>(
      'reorderPlayers moves a player to the new index',
      build: build,
      seed: validState,
      act: (cubit) => cubit.reorderPlayers(0, 2),
      expect: () => [
        isA<CreateGameState>().having(
          (s) => s.selectedPlayers.map((p) => p.firstName),
          'order',
          ['Bob', 'Amy'],
        ),
      ],
    );
  });

  group('createGame validation', () {
    blocTest<CreateGameCubit, CreateGameState>(
      'surfaces field errors and does not call the repository',
      build: build,
      act: (cubit) => cubit.createGame(),
      expect: () => [
        isA<CreateGameState>()
            .having((s) => s.showValidationErrors, 'showValidationErrors', true)
            .having(
              (s) => s.fieldErrors.keys.toSet(),
              'error fields',
              {
                CreateGameValidation.gameNameField,
                CreateGameValidation.gameTypeField,
                CreateGameValidation.playersField,
              },
            ),
      ],
      verify: (_) => verifyNever(
        () => repo.createGame(
          name: any(named: 'name'),
          gameTypeId: any(named: 'gameTypeId'),
          gameTypeName: any(named: 'gameTypeName'),
          playerIds: any(named: 'playerIds'),
        ),
      ),
    );

    blocTest<CreateGameCubit, CreateGameState>(
      'on a valid form emits loading then success with the new game id',
      build: () {
        when(
          () => repo.createGame(
            name: 'Friday Night',
            gameTypeId: 1,
            gameTypeName: 'Poker',
            playerIds: [1, 2],
            gameDate: any(named: 'gameDate'),
          ),
        ).thenAnswer((_) async => 42);
        return build();
      },
      seed: validState,
      act: (cubit) => cubit.createGame(),
      expect: () => [
        hasStatus(CreateGameStatus.loading),
        isA<CreateGameState>()
            .having((s) => s.status, 'status', CreateGameStatus.success)
            .having((s) => s.createdGameId, 'createdGameId', 42),
      ],
    );

    blocTest<CreateGameCubit, CreateGameState>(
      'maps a DomainException to a snackbar and stays on the form',
      build: () {
        when(
          () => repo.createGame(
            name: any(named: 'name'),
            gameTypeId: any(named: 'gameTypeId'),
            gameTypeName: any(named: 'gameTypeName'),
            playerIds: any(named: 'playerIds'),
            gameDate: any(named: 'gameDate'),
          ),
        ).thenThrow(const DomainException(DomainErrorCode.conflict));
        return build();
      },
      seed: validState,
      act: (cubit) => cubit.createGame(),
      expect: () => [
        hasStatus(CreateGameStatus.loading),
        isA<CreateGameState>()
            .having((s) => s.status, 'status', CreateGameStatus.initial)
            .having((s) => s.snackbarMessage, 'snackbarMessage', isNotNull),
      ],
    );
  });

  group('addNewGameType', () {
    blocTest<CreateGameCubit, CreateGameState>(
      'ignores blank names',
      build: build,
      act: (cubit) => cubit.addNewGameType('   '),
      expect: () => <CreateGameState>[],
      verify: (_) => verifyNever(
        () => repo.addGameType(name: any(named: 'name')),
      ),
    );

    blocTest<CreateGameCubit, CreateGameState>(
      'adds the new type to available and selects it',
      build: () {
        when(() => repo.addGameType(name: 'Chess'))
            .thenAnswer((_) async => 7);
        when(() => repo.getGameTypeById(7))
            .thenAnswer((_) async => gameTypeRow(id: 7, name: 'Chess'));
        return build();
      },
      act: (cubit) => cubit.addNewGameType('Chess'),
      expect: () => [
        isA<CreateGameState>()
            .having(
              (s) => s.availableGameTypes.map((t) => t.name),
              'available',
              contains('Chess'),
            )
            .having((s) => s.selectedGameType?.id, 'selected id', 7),
      ],
    );
  });
}
