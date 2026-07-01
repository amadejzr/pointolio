import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pointolio/common/di/locator.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';
import 'package:pointolio/common/ui/widgets/motion.dart';
import 'package:pointolio/common/ui/widgets/notebook_background.dart';
import 'package:pointolio/common/ui/widgets/page_app_bar.dart';
import 'package:pointolio/common/ui/widgets/toast_message.dart';
import 'package:pointolio/features/manage/presentation/cubit/theme_cubit.dart';
import 'package:pointolio/features/manage/presentation/cubit/theme_state.dart';
import 'package:pointolio/features/settings/data/settings_repository.dart';
import 'package:pointolio/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:pointolio/features/settings/presentation/cubit/settings_state.dart';
import 'package:pointolio/features/settings/presentation/widgets/app_version_footer.dart';
import 'package:pointolio/features/settings/presentation/widgets/appearance_selector.dart';
import 'package:pointolio/features/settings/presentation/widgets/delete_all_data_dialog.dart';
import 'package:pointolio/features/settings/presentation/widgets/settings_section.dart';
import 'package:pointolio/features/settings/presentation/widgets/settings_tile.dart';
import 'package:url_launcher/url_launcher.dart';

const _privacyUrl = 'https://amadejzr.github.io/pointolio/privacy';
const _supportUrl = 'https://amadejzr.github.io/pointolio/support';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          SettingsCubit(repository: locator<SettingsRepository>()),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  Future<void> _openUrl(BuildContext context, String url) async {
    final launched = await launchUrl(
      Uri.parse(url),
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      ToastMessage.error(context, 'Could not open link');
    }
  }

  Future<void> _deleteAll(BuildContext context) async {
    final confirmed = await showDeleteAllDataDialog(context);
    if (!confirmed || !context.mounted) return;
    final result = await context.read<SettingsCubit>().deleteAllData();
    if (context.mounted) result.showToast(context);
  }

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;

    return Scaffold(
      backgroundColor: pt.bg,
      body: Stack(
        children: [
          const Positioned.fill(child: NotebookBackground()),
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageAppBar(title: 'Settings'),
                Expanded(
                  child: ListView(
                    physics: const ClampingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(S.lg, 0, S.lg, S.md),
                    children: [
                      AnimatedEntrance(
                        child: BlocSelector<ThemeCubit, ThemeState,
                            AppThemeMode>(
                          selector: (state) => state.themeMode,
                          builder: (context, themeMode) {
                            return AppearanceSelector(
                              selected: themeMode,
                              onChanged: (mode) => unawaited(
                                context.read<ThemeCubit>().setTheme(mode),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: S.xl),
                      AnimatedEntrance(
                        delay: const Duration(milliseconds: 60),
                        child: SettingsSection(
                          title: 'About',
                          children: [
                            SettingsTile(
                              icon: Icons.shield_outlined,
                              title: 'Privacy Policy',
                              subtitle: 'How your data is handled',
                              trailing: _ExternalGlyph(color: pt.textFaint),
                              semanticHint: 'Opens in your browser',
                              onTap: () =>
                                  unawaited(_openUrl(context, _privacyUrl)),
                            ),
                            SettingsTile(
                              icon: Icons.help_outline_rounded,
                              title: 'Support',
                              subtitle: 'Get help and usage info',
                              trailing: _ExternalGlyph(color: pt.textFaint),
                              semanticHint: 'Opens in your browser',
                              onTap: () =>
                                  unawaited(_openUrl(context, _supportUrl)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: S.xl),
                      AnimatedEntrance(
                        delay: const Duration(milliseconds: 120),
                        child: SettingsSection(
                          title: 'Data',
                          children: [
                            BlocBuilder<SettingsCubit, SettingsState>(
                              builder: (context, state) {
                                return SettingsTile(
                                  icon: Icons.delete_outline_rounded,
                                  title: 'Delete all data',
                                  subtitle:
                                      'Erase every party, player and score',
                                  destructive: true,
                                  semanticHint: 'Cannot be undone',
                                  trailing: state.isDeleting
                                      ? _TileSpinner(color: pt.players[3])
                                      : null,
                                  onTap: state.isDeleting
                                      ? null
                                      : () => unawaited(_deleteAll(context)),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(
                    top: S.md,
                    bottom: MediaQuery.paddingOf(context).bottom + S.xl,
                  ),
                  child: const Center(child: AppVersionFooter()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExternalGlyph extends StatelessWidget {
  const _ExternalGlyph({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.open_in_new_rounded, size: 16, color: color);
  }
}

class _TileSpinner extends StatelessWidget {
  const _TileSpinner({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: CircularProgressIndicator(strokeWidth: 2, color: color),
    );
  }
}
