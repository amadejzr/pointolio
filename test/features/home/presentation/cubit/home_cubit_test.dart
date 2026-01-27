// test/features/home/presentation/cubit/home_cubit_test.dart
import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pointolio/common/exception/domain_exception.dart';
import 'package:pointolio/features/home/data/home_repository.dart';
import 'package:pointolio/features/home/presentation/cubit/home_cubit.dart';
import 'package:pointolio/features/home/presentation/cubit/home_state.dart';

class MockHomeRepository extends Mock implements HomeRepository {}

void main() {
  late MockHomeRepository repo;

  setUp(() {
    repo = MockHomeRepository();
  });

  HomeCubit cubit0() => HomeCubit(homeRepository: repo);

  /// Creates a controller, stubs the repo stream, and schedules either a data
  /// event or an error event.
  StreamController<List<GameWithPlayerCount>> stubWatchGames({
    List<GameWithPlayerCount>? emitData,
    Object? emitError,
  }) {
    assert(
      (emitData == null) != (emitError == null),
      'Provide either data or error',
    );

    final controller = StreamController<List<GameWithPlayerCount>>();
    when(
      () => repo.watchGamesWithMetadata(),
    ).thenAnswer((_) => controller.stream);

    // its for the stream
    // ignore: discarded_futures
    Future<void>.microtask(() {
      if (emitError != null) {
        controller.addError(emitError);
      } else {
        controller.add(emitData!);
      }
    });

    return controller;
  }

  /// Generic helper for “repo call throws DomainException -> snackbarMessage”.
  void snackbarOnDomainExceptionTest({
    required String description,
    required Future<void> Function(HomeCubit cubit) act,
    required void Function() stubThrow,
    required String expectedMessage,
  }) {
    blocTest<HomeCubit, HomeState>(
      description,
      build: () {
        stubThrow();
        return cubit0();
      },
      act: act,
      expect: () => [
        HomeState.initial().copyWith(snackbarMessage: expectedMessage),
      ],
    );
  }

  group('HomeCubit.loadGames', () {
    blocTest<HomeCubit, HomeState>(
      'emits loading then loaded when repository stream emits data',
      build: () {
        final controller = stubWatchGames(
          emitData: const <GameWithPlayerCount>[],
        );
        addTearDown(() async => controller.close());
        return cubit0();
      },
      act: (cubit) => cubit.loadGames(),
      expect: () => [
        HomeState.initial().copyWith(status: HomeStatus.loading),
        HomeState.initial().copyWith(
          status: HomeStatus.loaded,
          games: const <GameWithPlayerCount>[],
        ),
      ],
      verify: (_) => verify(() => repo.watchGamesWithMetadata()).called(1),
    );

    blocTest<HomeCubit, HomeState>(
      'emits loading then error when repository stream errors',
      build: () {
        final controller = stubWatchGames(emitError: Exception('boom'));
        addTearDown(() async => controller.close());
        return cubit0();
      },
      act: (cubit) => cubit.loadGames(),
      expect: () => [
        HomeState.initial().copyWith(status: HomeStatus.loading),
        HomeState.initial().copyWith(
          status: HomeStatus.error,
          errorMessage: 'Failed to load games. Please reload.',
        ),
      ],
    );

    test(
      'cancels previous subscription when loadGames is called again',
      () async {
        final controller1 = StreamController<List<GameWithPlayerCount>>();
        final controller2 = StreamController<List<GameWithPlayerCount>>();

        var call = 0;
        when(() => repo.watchGamesWithMetadata()).thenAnswer((_) {
          call++;
          return call == 1 ? controller1.stream : controller2.stream;
        });

        final cubit = cubit0()..loadGames();
        expect(controller1.hasListener, isTrue);

        cubit.loadGames();
        await Future<void>.delayed(Duration.zero);

        expect(controller1.hasListener, isFalse);
        expect(controller2.hasListener, isTrue);

        await cubit.close();
        await controller1.close();
        await controller2.close();
      },
    );
  });

  group('HomeCubit.deleteGame', () {
    blocTest<HomeCubit, HomeState>(
      'does not emit snackbar message on success',
      build: () {
        when(() => repo.deleteGame(any())).thenAnswer((_) async {});
        return cubit0();
      },
      act: (cubit) => cubit.deleteGame(1),
      expect: () => <HomeState>[],
      verify: (_) => verify(() => repo.deleteGame(1)).called(1),
    );

    snackbarOnDomainExceptionTest(
      description:
          'emits snackbar "Game not found" when deleteGame throws notFound',
      stubThrow: () {
        when(() => repo.deleteGame(any())).thenThrow(
          const DomainException(
            DomainErrorCode.notFound,
            context: {'op': 'deleteGame', 'gameId': 123},
          ),
        );
      },
      act: (cubit) => cubit.deleteGame(123),
      expectedMessage: 'Game not found',
    );

    snackbarOnDomainExceptionTest(
      description:
          'emits snackbar "Failed to delete game" when deleteGame'
          ' throws other DomainException',
      stubThrow: () {
        when(() => repo.deleteGame(any())).thenThrow(
          const DomainException(
            DomainErrorCode.storage,
            context: {'op': 'deleteGame', 'gameId': 123},
          ),
        );
      },
      act: (cubit) => cubit.deleteGame(123),
      expectedMessage: 'Failed to delete game',
    );
  });

  group('HomeCubit.setFinished', () {
    blocTest<HomeCubit, HomeState>(
      'does not emit snackbar message on success',
      build: () {
        when(
          () => repo.setGameFinished(any(), finished: any(named: 'finished')),
        ).thenAnswer((_) async {});
        return cubit0();
      },
      act: (cubit) => cubit.setFinished(1, isFinished: true),
      expect: () => <HomeState>[],
      verify: (_) =>
          verify(() => repo.setGameFinished(1, finished: true)).called(1),
    );

    snackbarOnDomainExceptionTest(
      description:
          'emits snackbar "Game not found" when setFinished throws notFound',
      stubThrow: () {
        when(
          () => repo.setGameFinished(any(), finished: any(named: 'finished')),
        ).thenThrow(
          const DomainException(
            DomainErrorCode.notFound,
            context: {
              'op': 'setGameFinished',
              'gameId': 999,
              'finished': false,
            },
          ),
        );
      },
      act: (cubit) => cubit.setFinished(999, isFinished: false),
      expectedMessage: 'Game not found',
    );

    snackbarOnDomainExceptionTest(
      description:
          'emits snackbar "Failed to update game status" when setFinished '
          'throws other DomainException',
      stubThrow: () {
        when(
          () => repo.setGameFinished(any(), finished: any(named: 'finished')),
        ).thenThrow(
          const DomainException(
            DomainErrorCode.storage,
            context: {
              'op': 'setGameFinished',
              'gameId': 999,
              'finished': false,
            },
          ),
        );
      },
      act: (cubit) => cubit.setFinished(999, isFinished: false),
      expectedMessage: 'Failed to update game status',
    );
  });

  group('HomeCubit simple state transitions', () {
    blocTest<HomeCubit, HomeState>(
      'clearSnackbar sets clearSnackbar=true',
      build: cubit0,
      act: (cubit) => cubit.clearSnackbar(),
      expect: () => [HomeState.initial().copyWith(clearSnackbar: true)],
    );

    blocTest<HomeCubit, HomeState>(
      'toggleEditMode toggles isEditing',
      build: cubit0,
      act: (cubit) {
        cubit
          ..toggleEditMode()
          ..toggleEditMode();
      },
      expect: () => [
        HomeState.initial().copyWith(isEditing: true),
        HomeState.initial().copyWith(isEditing: false),
      ],
    );

    blocTest<HomeCubit, HomeState>(
      'exitEditMode sets isEditing=false',
      build: cubit0,
      seed: () => HomeState.initial().copyWith(isEditing: true),
      act: (cubit) => cubit.exitEditMode(),
      expect: () => [HomeState.initial().copyWith(isEditing: false)],
    );

    blocTest<HomeCubit, HomeState>(
      'toggleShowCompleted toggles showCompleted',
      build: cubit0,
      act: (cubit) {
        cubit
          ..toggleShowCompleted()
          ..toggleShowCompleted();
      },
      expect: () => [
        HomeState.initial().copyWith(showCompleted: true),
        HomeState.initial().copyWith(showCompleted: false),
      ],
    );
  });

  test('close cancels active games subscription', () async {
    final controller = StreamController<List<GameWithPlayerCount>>();
    when(
      () => repo.watchGamesWithMetadata(),
    ).thenAnswer((_) => controller.stream);

    final cubit = cubit0()..loadGames();
    expect(controller.hasListener, isTrue);

    await cubit.close();
    await Future<void>.delayed(Duration.zero);

    expect(controller.hasListener, isFalse);
    await controller.close();
  });
}
