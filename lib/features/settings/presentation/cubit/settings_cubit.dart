import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pointolio/common/exception/domain_exception.dart';
import 'package:pointolio/common/result/action_result.dart';
import 'package:pointolio/features/settings/data/settings_repository.dart';
import 'package:pointolio/features/settings/presentation/cubit/settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({required SettingsRepository repository})
      : _repository = repository,
        super(const SettingsState());

  final SettingsRepository _repository;

  /// Wipes all local data. Returns an [ActionResult] the page turns into a
  /// toast.
  Future<ActionResult> deleteAllData() async {
    if (state.isDeleting) return const ActionSuccess();
    emit(state.copyWith(status: SettingsStatus.deleting));
    try {
      await _repository.clearAllData();
      return const ActionSuccess('All data deleted');
    } on DomainException {
      return const ActionFailure('Could not delete your data');
    } finally {
      if (!isClosed) emit(state.copyWith(status: SettingsStatus.idle));
    }
  }
}
