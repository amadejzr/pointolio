import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scoreio/common/ui/widgets/player_bottom_sheet/cubit/player_bottom_sheet_state.dart';

class PlayerBottomSheetCubit extends Cubit<PlayerBottomSheetState> {
  PlayerBottomSheetCubit({
    String? initialFirstName,
    String? initialLastName,
    int? initialColor,
  }) : super(
          PlayerBottomSheetState(
            firstName: initialFirstName ?? '',
            lastName: initialLastName ?? '',
            selectedColor: initialColor,
          ),
        );

  void setFirstName(String firstName) {
    emit(state.copyWith(firstName: firstName));
  }

  void setLastName(String lastName) {
    emit(state.copyWith(lastName: lastName));
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
