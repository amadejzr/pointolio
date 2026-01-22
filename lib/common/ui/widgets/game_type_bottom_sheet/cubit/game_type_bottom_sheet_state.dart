import 'package:equatable/equatable.dart';

/// Available colors for game types.
const gameTypeColors = [
  0xFFEF5350,
  0xFFEC407A,
  0xFFAB47BC,
  0xFF7E57C2,
  0xFF5C6BC0,
  0xFF42A5F5,
  0xFF29B6F6,
  0xFF26C6DA,
  0xFF26A69A,
  0xFF66BB6A,
  0xFF9CCC65,
  0xFFD4E157,
  0xFFFFEE58,
  0xFFFFCA28,
  0xFFFFA726,
  0xFFFF7043,
];

class GameTypeBottomSheetState extends Equatable {
  const GameTypeBottomSheetState({
    this.name = '',
    this.lowestScoreWins = false,
    this.selectedColor,
  });

  final String name;
  final bool lowestScoreWins;
  final int? selectedColor;

  bool get isValid => name.trim().isNotEmpty;

  GameTypeBottomSheetState copyWith({
    String? name,
    bool? lowestScoreWins,
    int? Function()? selectedColor,
  }) {
    return GameTypeBottomSheetState(
      name: name ?? this.name,
      lowestScoreWins: lowestScoreWins ?? this.lowestScoreWins,
      selectedColor:
          selectedColor != null ? selectedColor() : this.selectedColor,
    );
  }

  @override
  List<Object?> get props => [name, lowestScoreWins, selectedColor];
}
