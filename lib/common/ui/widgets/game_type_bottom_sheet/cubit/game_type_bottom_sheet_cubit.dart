import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pointolio/common/ui/widgets/game_type_bottom_sheet/cubit/game_type_bottom_sheet_state.dart';

class GameTypeBottomSheetCubit extends Cubit<GameTypeBottomSheetState> {
  GameTypeBottomSheetCubit({
    String? initialName,
    bool? initialLowestScoreWins,
    int? initialColor,
  }) : super(
          GameTypeBottomSheetState(
            name: initialName ?? '',
            lowestScoreWins: initialLowestScoreWins ?? false,
            selectedColor: initialColor,
          ),
        );

  void setName(String name) {
    emit(state.copyWith(name: name));
  }

  // Don't want to complicate it
  // ignore: avoid_positional_boolean_parameters
  void setLowestScoreWins(bool value) {
    emit(state.copyWith(lowestScoreWins: value));
  }

  void selectColor(int? color) {
    emit(state.copyWith(selectedColor: () => color));
  }

  void toggleColor(int color) {
    if (state.selectedColor == color) {
      emit(state.copyWith(selectedColor: () => null));
    } else {
      emit(state.copyWith(selectedColor: () => color));
    }
  }
}
