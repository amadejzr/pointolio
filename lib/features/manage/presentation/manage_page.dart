import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pointolio/common/ui/tokens/spacing.dart';
import 'package:pointolio/features/manage/presentation/cubit/theme_cubit.dart';
import 'package:pointolio/features/manage/presentation/cubit/theme_state.dart';
import 'package:pointolio/features/manage/presentation/game_types_management_page.dart';
import 'package:pointolio/features/manage/presentation/players_management_page.dart';
import 'package:pointolio/features/manage/presentation/widgets/management_section_card.dart';
import 'package:pointolio/features/manage/presentation/widgets/theme_selector.dart';

class ManagePage extends StatelessWidget {
  const ManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Manage'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: Spacing.page,
        children: [
          ManagementSectionCard(
            title: 'Players',
            subtitle: 'Manage your players',
            icon: Icons.people_outline,
            onTap: () {
              unawaited(
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PlayersManagementPage(),
                  ),
                ),
              );
            },
          ),
          Spacing.gap16,
          ManagementSectionCard(
            title: 'Games',
            subtitle: 'Manage your games',
            icon: Icons.category_outlined,
            onTap: () {
              unawaited(
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GameTypesManagementPage(),
                  ),
                ),
              );
            },
          ),
          Spacing.gap24,
          BlocSelector<ThemeCubit, ThemeState, AppThemeMode>(
            selector: (state) => state.themeMode,
            builder: (context, themeMode) {
              return ThemeSelector(
                selectedTheme: themeMode,
                onThemeChanged: (theme) {
                  unawaited(context.read<ThemeCubit>().setTheme(theme));
                },
              );
            },
          ),
          Spacing.gap16,
        ],
      ),
    );
  }
}
