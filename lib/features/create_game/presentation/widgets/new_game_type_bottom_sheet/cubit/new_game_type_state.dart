import 'package:equatable/equatable.dart';

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

class NewGameTypeState extends Equatable {
  final String name;
  final bool lowestScoreWins;
  final int? selectedColor;

  const NewGameTypeState({
    this.name = '',
    this.lowestScoreWins = false,
    this.selectedColor,
  });

  bool get isValid => name.trim().isNotEmpty;

  NewGameTypeState copyWith({
    String? name,
    bool? lowestScoreWins,
    int? Function()? selectedColor,
  }) {
    return NewGameTypeState(
      name: name ?? this.name,
      lowestScoreWins: lowestScoreWins ?? this.lowestScoreWins,
      selectedColor: selectedColor != null ? selectedColor() : this.selectedColor,
    );
  }

  @override
  List<Object?> get props => [name, lowestScoreWins, selectedColor];
}
