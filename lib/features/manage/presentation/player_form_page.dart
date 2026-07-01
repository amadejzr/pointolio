import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pointolio/common/data/database/database.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/form/form.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';
import 'package:pointolio/common/ui/widgets/notebook_background.dart';
import 'package:pointolio/common/ui/widgets/player_avatar.dart';

/// The values captured by [PlayerFormPage], returned via `Navigator.pop`.
class PlayerFormResult {
  const PlayerFormResult({
    required this.firstName,
    required this.color,
    this.lastName,
  });

  final String firstName;
  final String? lastName;

  /// Resolved ARGB colour from the theme palette.
  final int color;
}

/// Full-screen create / edit form for a player, in the Notebook/Slate style.
///
/// Pass [initial] to edit an existing player (title flips to "Edit player"
/// and the fields pre-fill); leave it null to create. On save the page pops
/// with a [PlayerFormResult]; the caller persists through its cubit. Cancelling
/// pops with null.
class PlayerFormPage extends StatefulWidget {
  const PlayerFormPage({super.key, this.initial});

  final Player? initial;

  @override
  State<PlayerFormPage> createState() => _PlayerFormPageState();
}

class _PlayerFormPageState extends State<PlayerFormPage> {
  late final TextEditingController _firstName = TextEditingController(
    text: widget.initial?.firstName ?? '',
  );
  late final TextEditingController _lastName = TextEditingController(
    text: widget.initial?.lastName ?? '',
  );

  int _colorIndex = 0;
  bool _colorResolved = false;

  bool get _isEditing => widget.initial != null;

  bool get _isValid => _firstName.text.trim().isNotEmpty;

  String get _initial {
    final name = _firstName.text.trim();
    return name.isEmpty ? '?' : name[0].toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    // Rebuild the avatar preview + Save state as the first name changes.
    _firstName.addListener(_onChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Map a stored colour back to its palette index once the theme is
    // available. Colours outside the current palette (e.g. legacy players)
    // fall back to the first swatch.
    if (!_colorResolved) {
      _colorResolved = true;
      final stored = widget.initial?.color;
      if (stored != null) {
        final palette = context.pt.players;
        final index = palette.indexWhere((c) => c.toARGB32() == stored);
        if (index >= 0) _colorIndex = index;
      }
    }
  }

  @override
  void dispose() {
    _firstName
      ..removeListener(_onChanged)
      ..dispose();
    _lastName.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  void _save() {
    if (!_isValid) return;
    final last = _lastName.text.trim();
    context.pop(
      PlayerFormResult(
        firstName: _firstName.text.trim(),
        lastName: last.isEmpty ? null : last,
        color: context.pt.playerColor(_colorIndex).toARGB32(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final avatarColor = pt.playerColor(_colorIndex);

    return Scaffold(
      backgroundColor: pt.bg,
      body: Stack(
        children: [
          const Positioned.fill(child: NotebookBackground()),
          Column(
            children: [
              FormAppBar(
                title: _isEditing ? 'Edit player' : 'New player',
                onCancel: () => context.pop(),
                actionLabel: 'Save',
                actionEnabled: _isValid,
                onAction: _save,
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(S.lg, S.sm, S.lg, S.lg),
                  children: [
                    // Live avatar preview - recolours + relabels as you type.
                    AnimatedEntrance(
                      child: Center(
                        child: ExcludeSemantics(
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: avatarColor.withValues(alpha: 0.4),
                                  blurRadius: 24,
                                  spreadRadius: -8,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: PlayerAvatar(
                              initial: _initial,
                              color: avatarColor,
                              size: 78,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: S.xl),

                    AnimatedEntrance(
                      delay: const Duration(milliseconds: 50),
                      child: FormSection(
                        label: 'Colour',
                        child: ColorSwatchPicker(
                          selectedIndex: _colorIndex,
                          onSelect: (i) => setState(() => _colorIndex = i),
                        ),
                      ),
                    ),
                    const SectionGap(),

                    AnimatedEntrance(
                      delay: const Duration(milliseconds: 100),
                      child: FormSection(
                        label: 'First name',
                        child: PtTextField(
                          controller: _firstName,
                          hint: 'e.g. John, Sarah, Alex',
                          semanticLabel: 'First name',
                          autofocus: !_isEditing,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                    ),
                    const SectionGap(),

                    AnimatedEntrance(
                      delay: const Duration(milliseconds: 150),
                      child: FormSection(
                        label: 'Last name (optional)',
                        child: PtTextField(
                          controller: _lastName,
                          hint: 'e.g. Smith, Johnson, Lee',
                          semanticLabel: 'Last name',
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _save(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  S.lg,
                  S.sm,
                  S.lg,
                  bottomInset + S.lg,
                ),
                child: PrimaryButton(
                  label: _isEditing ? 'Save changes' : 'Add player',
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
