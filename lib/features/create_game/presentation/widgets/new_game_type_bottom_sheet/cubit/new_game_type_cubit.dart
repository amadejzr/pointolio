import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scoreio/features/create_game/presentation/widgets/new_game_type_bottom_sheet/cubit/new_game_type_state.dart';

class NewGameTypeCubit extends Cubit<NewGameTypeState> {
  NewGameTypeCubit() : super(const NewGameTypeState());

  void setName(String name) {
    emit(state.copyWith(name: name));
  }

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
