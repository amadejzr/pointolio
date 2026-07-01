part of 'share_editor_cubit.dart';

class ShareEditorState extends Equatable {
  const ShareEditorState({
    this.style = ShareStyle.spotlight,
    this.opacity = 0.72,
    this.busy = false,
  });

  final ShareStyle style;

  /// Fill opacity of the card, [kMinShareOpacity]..[kMaxShareOpacity].
  final double opacity;

  /// True while a share is in flight.
  final bool busy;

  ShareEditorState copyWith({
    ShareStyle? style,
    double? opacity,
    bool? busy,
  }) {
    return ShareEditorState(
      style: style ?? this.style,
      opacity: opacity ?? this.opacity,
      busy: busy ?? this.busy,
    );
  }

  @override
  List<Object?> get props => [style, opacity, busy];
}
