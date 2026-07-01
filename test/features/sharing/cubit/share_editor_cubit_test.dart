import 'dart:typed_data';
import 'dart:ui';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointolio/features/sharing/domain/share_result.dart';
import 'package:pointolio/features/sharing/presentation/cubit/share_editor_cubit.dart';

/// A [ShareLauncher] the tests fully control: records the last call and returns
/// (or throws) whatever the test configures.
class FakeShareLauncher implements ShareLauncher {
  FakeShareLauncher({
    this.result = ShareActionResult.success,
    this.throwError = false,
  });

  ShareActionResult result;
  bool throwError;

  int calls = 0;
  Uint8List? lastBytes;
  Rect? lastOrigin;
  String? lastText;

  @override
  Future<ShareActionResult> shareImage(
    Uint8List bytes, {
    required Rect origin,
    String? text,
  }) async {
    calls++;
    lastBytes = bytes;
    lastOrigin = origin;
    lastText = text;
    if (throwError) throw Exception('boom');
    return result;
  }
}

void main() {
  final bytes = Uint8List.fromList([1, 2, 3]);
  const origin = Rect.fromLTWH(0, 0, 10, 10);

  group('editor controls', () {
    blocTest<ShareEditorCubit, ShareEditorState>(
      'setStyle emits the new style',
      build: ShareEditorCubit.new,
      act: (cubit) => cubit.setStyle(ShareStyle.podium),
      expect: () => [
        isA<ShareEditorState>().having(
          (s) => s.style,
          'style',
          ShareStyle.podium,
        ),
      ],
    );

    blocTest<ShareEditorCubit, ShareEditorState>(
      'setOpacity clamps below the minimum',
      build: ShareEditorCubit.new,
      act: (cubit) => cubit.setOpacity(0.1),
      expect: () => [
        isA<ShareEditorState>().having(
          (s) => s.opacity,
          'opacity',
          kMinShareOpacity,
        ),
      ],
    );

    blocTest<ShareEditorCubit, ShareEditorState>(
      'setOpacity clamps above the maximum',
      build: ShareEditorCubit.new,
      act: (cubit) => cubit.setOpacity(5),
      expect: () => [
        isA<ShareEditorState>().having(
          (s) => s.opacity,
          'opacity',
          kMaxShareOpacity,
        ),
      ],
    );
  });

  group('share', () {
    test('forwards bytes, origin and text to the launcher', () async {
      final launcher = FakeShareLauncher();
      final cubit = ShareEditorCubit(launcher: launcher);

      final outcome = await cubit.share(bytes, origin: origin, text: 'hi');

      expect(outcome, ShareActionResult.success);
      expect(launcher.calls, 1);
      expect(launcher.lastBytes, bytes);
      expect(launcher.lastOrigin, origin);
      expect(launcher.lastText, 'hi');
      await cubit.close();
    });

    blocTest<ShareEditorCubit, ShareEditorState>(
      'toggles busy true then false around a successful share',
      build: () => ShareEditorCubit(launcher: FakeShareLauncher()),
      act: (cubit) => cubit.share(bytes, origin: origin),
      expect: () => [
        isA<ShareEditorState>().having((s) => s.busy, 'busy', true),
        isA<ShareEditorState>().having((s) => s.busy, 'busy', false),
      ],
    );

    test('returns failed and clears busy when the launcher throws', () async {
      final cubit = ShareEditorCubit(
        launcher: FakeShareLauncher(throwError: true),
      );

      final outcome = await cubit.share(bytes, origin: origin);

      expect(outcome, ShareActionResult.failed);
      expect(cubit.state.busy, isFalse);
      await cubit.close();
    });

    test('propagates a cancelled result', () async {
      final cubit = ShareEditorCubit(
        launcher: FakeShareLauncher(result: ShareActionResult.cancelled),
      );

      final outcome = await cubit.share(bytes, origin: origin);

      expect(outcome, ShareActionResult.cancelled);
      await cubit.close();
    });

    test('ignores a re-entrant share while one is in flight', () async {
      final launcher = FakeShareLauncher();
      final cubit = ShareEditorCubit(launcher: launcher);

      final first = cubit.share(bytes, origin: origin);
      final second = cubit.share(bytes, origin: origin);

      expect(await second, ShareActionResult.cancelled);
      await first;
      expect(launcher.calls, 1);
      await cubit.close();
    });
  });
}
