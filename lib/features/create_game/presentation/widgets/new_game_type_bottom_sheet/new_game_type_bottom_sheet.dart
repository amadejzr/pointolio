import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scoreio/features/create_game/presentation/widgets/new_game_type_bottom_sheet/cubit/new_game_type_cubit.dart';
import 'package:scoreio/features/create_game/presentation/widgets/new_game_type_bottom_sheet/cubit/new_game_type_state.dart';

class GameTypeResult {
  final String name;
  final bool lowestScoreWins;
  final int? color;

  GameTypeResult({
    required this.name,
    required this.lowestScoreWins,
    this.color,
  });
}

class NewGameTypeBottomSheet extends StatelessWidget {
  const NewGameTypeBottomSheet({super.key});

  static Future<GameTypeResult?> show(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return showModalBottomSheet<GameTypeResult>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => BlocProvider(
        create: (_) => NewGameTypeCubit(),
        child: const NewGameTypeBottomSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const _NewGameTypeSheetContent();
  }
}

class _NewGameTypeSheetContent extends StatefulWidget {
  const _NewGameTypeSheetContent();

  @override
  State<_NewGameTypeSheetContent> createState() =>
      _NewGameTypeSheetContentState();
}

class _NewGameTypeSheetContentState extends State<_NewGameTypeSheetContent> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    final state = context.read<NewGameTypeCubit>().state;
    if (!state.isValid) return;

    Navigator.pop(
      context,
      GameTypeResult(
        name: state.name,
        lowestScoreWins: state.lowestScoreWins,
        color: state.selectedColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final cubit = context.read<NewGameTypeCubit>();

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
            padding: const EdgeInsets.only(bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
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
                const SizedBox(height: 12),

                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'New Game Type',
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

                const SizedBox(height: 12),

                // Color
                const _SectionTitle('Color'),
                const SizedBox(height: 12),
                BlocBuilder<NewGameTypeCubit, NewGameTypeState>(
                  buildWhen: (prev, curr) =>
                      prev.selectedColor != curr.selectedColor,
                  builder: (context, state) {
                    return SizedBox(
                      height: 48,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: gameTypeColors.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        itemBuilder: (context, index) {
                          final colorInt = gameTypeColors[index];
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

                const SizedBox(height: 22),

                // Name
                const _SectionTitle('Name'),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: TextField(
                    controller: _nameController,
                    autofocus: true,
                    autocorrect: false,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Rummy, Poker, UNO',
                    ),
                    textCapitalization: TextCapitalization.words,
                    onChanged: cubit.setName,
                    onSubmitted: (_) => _submit(),
                  ),
                ),

                const SizedBox(height: 22),

                // Winning condition
                const _SectionTitle('Winning Condition'),
                const SizedBox(height: 8),
                BlocBuilder<NewGameTypeCubit, NewGameTypeState>(
                  buildWhen: (prev, curr) =>
                      prev.lowestScoreWins != curr.lowestScoreWins,
                  builder: (context, state) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: cs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: cs.outlineVariant),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: Row(
                          children: [
                            Expanded(
                              child: _WinOption(
                                selected: !state.lowestScoreWins,
                                icon: Icons.arrow_upward,
                                label: 'Highest Wins',
                                onTap: () => cubit.setLowestScoreWins(false),
                              ),
                            ),
                            Expanded(
                              child: _WinOption(
                                selected: state.lowestScoreWins,
                                icon: Icons.arrow_downward,
                                label: 'Lowest Wins',
                                onTap: () => cubit.setLowestScoreWins(true),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 18),

                // Button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: BlocBuilder<NewGameTypeCubit, NewGameTypeState>(
                    buildWhen: (prev, curr) => prev.isValid != curr.isValid,
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state.isValid ? _submit : null,
                          child: const Text('Add Game Type'),
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
      padding: const EdgeInsets.symmetric(horizontal: 16),
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

class _WinOption extends StatelessWidget {
  const _WinOption({
    required this.selected,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: selected ? cs.primaryContainer : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: tt.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
