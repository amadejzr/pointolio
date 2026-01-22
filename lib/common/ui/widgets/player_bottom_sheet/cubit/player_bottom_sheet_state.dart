import 'package:equatable/equatable.dart';

/// Available colors for players.
const playerColors = [
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

class PlayerBottomSheetState extends Equatable {
  const PlayerBottomSheetState({
    this.firstName = '',
    this.lastName = '',
    this.selectedColor,
  });

  final String firstName;
  final String lastName;
  final int? selectedColor;

  bool get isValid => firstName.trim().isNotEmpty;

  PlayerBottomSheetState copyWith({
    String? firstName,
    String? lastName,
    int? Function()? selectedColor,
  }) {
    return PlayerBottomSheetState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      selectedColor:
          selectedColor != null ? selectedColor() : this.selectedColor,
    );
  }

  @override
  List<Object?> get props => [firstName, lastName, selectedColor];
}
