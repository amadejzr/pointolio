import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/form/form.dart';
import 'package:pointolio/common/ui/widgets/game_type_bottom_sheet/game_type_bottom_sheet_exports.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';
import 'package:pointolio/common/ui/widgets/notebook_background.dart';

/// Full-screen create / edit form for a game type, in the Notebook/Slate style.
///
/// Pass [initial] to edit an existing game (the header flips to "Edit game" and
/// the fields pre-fill); leave it null to create a new one. The page collects
/// input only and returns the result via `context.pop` - persistence and toast
/// feedback stay with the caller (the Games list + its cubit).
class GameTypeFormPage extends StatefulWidget {
  const GameTypeFormPage({super.key, this.initial});

  final GameType? initial;

  @override
  State<GameTypeFormPage> createState() => _GameTypeFormPageState();
}

class _GameTypeFormPageState extends State<GameTypeFormPage> {
  late final TextEditingController _nameController =
      TextEditingController(text: widget.initial?.name ?? '');
  late bool _lowestScoreWins = widget.initial?.lowestScoreWins ?? false;
  late int? _color = widget.initial?.color;

  bool get _isEditing => widget.initial != null;

  @override
  void initState() {
    super.initState();
    // The app bar action + pinned button dim until a name is entered.
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isValid => _nameController.text.trim().isNotEmpty;

  void _save() {
    if (!_isValid) return;
    context.pop(
      GameTypeResult(
        name: _nameController.text.trim(),
        lowestScoreWins: _lowestScoreWins,
        color: _color,
      ),
    );
  }

  void _toggleColor(int color) {
    setState(() => _color = _color == color ? null : color);
  }

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: pt.bg,
      body: Stack(
        children: [
          const Positioned.fill(child: NotebookBackground()),
          Column(
            children: [
              FormAppBar(
                title: _isEditing ? 'Edit game' : 'New game',
                onCancel: context.pop,
                actionLabel: _isEditing ? 'Save' : 'Add',
                actionEnabled: _isValid,
                onAction: _save,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(S.lg, S.sm, S.lg, S.lg),
                  children: [
                    // Name
                    FormSection(
                      label: 'Game name',
                      child: PtTextField(
                        controller: _nameController,
                        hint: 'e.g. Rummy, Poker, UNO',
                        semanticLabel: 'Game name',
                        autofocus: !_isEditing,
                        onSubmitted: (_) => _save(),
                      ),
                    ),
                    const SectionGap(),

                    // Colour
                    FormSection(
                      label: 'Colour',
                      child: _GameColorPicker(
                        selectedColor: _color,
                        onSelect: _toggleColor,
                      ),
                    ),
                    const SectionGap(),

                    // Who wins
                    FormSection(
                      label: 'Who wins',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          WinRuleSelector(
                            lowestScoreWins: _lowestScoreWins,
                            onChanged: (v) =>
                                setState(() => _lowestScoreWins = v),
                          ),
                          const SizedBox(height: S.md),
                          WinRuleNote(
                            lowestScoreWins: _lowestScoreWins,
                            gameName: _nameController.text,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    EdgeInsets.fromLTRB(S.lg, S.sm, S.lg, bottomInset + S.lg),
                child: PrimaryButton(
                  label: _isEditing ? 'Save game' : 'Add game',
                  enabled: _isValid,
                  onTap: _save,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Swatch picker over the shared [gameTypeColors] palette. Styled like the
/// form kit's `ColorSwatchPicker` but keyed by the raw ARGB int the domain
/// stores, so existing games round-trip. A single horizontally-scrollable row
/// keeps it compact. Tapping the selected swatch clears it (no colour -> the
/// tile falls back to the accent hue).
class _GameColorPicker extends StatelessWidget {
  const _GameColorPicker({required this.selectedColor, required this.onSelect});

  final int? selectedColor;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        // Bleed slightly past the content margin so a swatch can't sit flush
        // against the screen edge while scrolling.
        padding: const EdgeInsets.symmetric(horizontal: 2),
        clipBehavior: Clip.none,
        itemCount: gameTypeColors.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          final colorInt = gameTypeColors[i];
          final c = Color(colorInt);
          final selected = colorInt == selectedColor;
          return Pressable(
            onTap: () => onSelect(colorInt),
            scale: 0.88,
            isButton: true,
            selected: selected,
            semanticLabel: 'Colour ${i + 1}',
            excludeChildSemantics: true,
            // 44x44 hit target around a 30px disc.
            child: SizedBox(
              width: 44,
              height: 44,
              child: Center(
                child: AnimatedContainer(
                  duration: Motion.base,
                  curve: Motion.ease,
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? c : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
