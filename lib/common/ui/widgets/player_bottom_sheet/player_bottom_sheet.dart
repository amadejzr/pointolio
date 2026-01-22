import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scoreio/common/ui/tokens/spacing.dart';
import 'package:scoreio/common/ui/widgets/player_bottom_sheet/cubit/player_bottom_sheet_cubit.dart';
import 'package:scoreio/common/ui/widgets/player_bottom_sheet/cubit/player_bottom_sheet_state.dart';
import 'package:scoreio/common/ui/widgets/player_bottom_sheet/player_result.dart';

/// A reusable bottom sheet for creating or editing players.
///
/// Supports both create mode (no initial values) and edit mode
/// (with initial values).
/// Returns a [PlayerResult] when confirmed, or null if cancelled.
class PlayerBottomSheet extends StatelessWidget {
  const PlayerBottomSheet._({
    required this.isEditMode,
  });

  final bool isEditMode;

  /// Shows the bottom sheet for creating a new player.
  static Future<PlayerResult?> show(BuildContext context) {
    return _showSheet(context, isEditMode: false);
  }

  /// Shows the bottom sheet for editing an existing player.
  static Future<PlayerResult?> showForEdit(
    BuildContext context, {
    required String firstName,
    String? lastName,
    int? color,
  }) {
    return _showSheet(
      context,
      isEditMode: true,
      initialFirstName: firstName,
      initialLastName: lastName,
      initialColor: color,
    );
  }

  static Future<PlayerResult?> _showSheet(
    BuildContext context, {
    required bool isEditMode,
    String? initialFirstName,
    String? initialLastName,
    int? initialColor,
  }) {
    final cs = Theme.of(context).colorScheme;
    return showModalBottomSheet<PlayerResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => BlocProvider(
        create: (_) => PlayerBottomSheetCubit(
          initialFirstName: initialFirstName,
          initialLastName: initialLastName,
          initialColor: initialColor,
        ),
        child: PlayerBottomSheet._(isEditMode: isEditMode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _PlayerSheetContent(isEditMode: isEditMode);
  }
}

class _PlayerSheetContent extends StatefulWidget {
  const _PlayerSheetContent({required this.isEditMode});

  final bool isEditMode;

  @override
  State<_PlayerSheetContent> createState() => _PlayerSheetContentState();
}

class _PlayerSheetContentState extends State<_PlayerSheetContent> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set initial text from cubit state
    final cubitState = context.read<PlayerBottomSheetCubit>().state;
    _firstNameController.text = cubitState.firstName;
    _lastNameController.text = cubitState.lastName;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _submit() {
    final state = context.read<PlayerBottomSheetCubit>().state;
    if (!state.isValid) return;

    Navigator.pop(
      context,
      PlayerResult(
        firstName: state.firstName,
        lastName: state.lastName.isEmpty ? null : state.lastName,
        color: state.selectedColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cubit = context.read<PlayerBottomSheetCubit>();

    return SafeArea(
      top: false,
      child: AnimatedPadding(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Material(
          color: Colors.transparent,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: Spacing.xs),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Spacing.gap8,
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: cs.outlineVariant,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ),
                Spacing.gap12,

                // Header
                Padding(
                  padding: Spacing.sheetHorizontal,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.isEditMode ? 'Edit Player' : 'New Player',
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),

                Spacing.gap12,

                // Color
                const _SectionTitle('Color'),
                Spacing.gap12,
                BlocBuilder<PlayerBottomSheetCubit,
                    PlayerBottomSheetState>(
                  buildWhen: (prev, curr) =>
                      prev.selectedColor != curr.selectedColor,
                  builder: (context, state) {
                    return SizedBox(
                      height: 48,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: Spacing.sheetHorizontal,
                        itemCount: playerColors.length,
                        separatorBuilder: (_, _) => Spacing.hGap8,
                        itemBuilder: (context, index) {
                          final colorInt = playerColors[index];
                          final isSelected = state.selectedColor == colorInt;

                          return _ColorDot(
                            color: Color(colorInt),
                            isSelected: isSelected,
                            onTap: () => cubit.toggleColor(colorInt),
                          );
                        },
                      ),
                    );
                  },
                ),

                Spacing.gap24,

                // First Name
                const _SectionTitle('First Name'),
                Spacing.gap8,
                Padding(
                  padding: Spacing.sheetHorizontal,
                  child: TextField(
                    controller: _firstNameController,
                    autofocus: true,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      hintText: 'e.g. John, Sarah, Alex',
                    ),
                    textCapitalization: TextCapitalization.words,
                    onChanged: cubit.setFirstName,
                    onSubmitted: (_) => _submit(),
                  ),
                ),

                Spacing.gap24,

                // Last Name
                const _SectionTitle('Last Name (optional)'),
                Spacing.gap8,
                Padding(
                  padding: Spacing.sheetHorizontal,
                  child: TextField(
                    controller: _lastNameController,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Smith, Johnson, Lee',
                    ),
                    textCapitalization: TextCapitalization.words,
                    onChanged: cubit.setLastName,
                    onSubmitted: (_) => _submit(),
                  ),
                ),

                Spacing.gap16,

                // Button
                Padding(
                  padding: Spacing.sheetBottom,
                  child: BlocBuilder<PlayerBottomSheetCubit,
                      PlayerBottomSheetState>(
                    buildWhen: (prev, curr) => prev.isValid != curr.isValid,
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state.isValid ? _submit : null,
                          child: Text(
                            widget.isEditMode ? 'Save Changes' : 'Add Player',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: Spacing.sheetHorizontal,
      child: Text(
        text,
        style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          curve: Curves.easeOut,
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: isSelected
                ? Border.all(color: cs.onSurface, width: 3)
                : null,
          ),
          child: isSelected
              ? const Icon(Icons.check, color: Colors.white)
              : null,
        ),
      ),
    );
  }
}
