import 'package:equatable/equatable.dart';

enum SettingsStatus { idle, deleting }

class SettingsState extends Equatable {
  const SettingsState({this.status = SettingsStatus.idle});

  final SettingsStatus status;

  bool get isDeleting => status == SettingsStatus.deleting;

  SettingsState copyWith({SettingsStatus? status}) {
    return SettingsState(status: status ?? this.status);
  }

  @override
  List<Object?> get props => [status];
}
