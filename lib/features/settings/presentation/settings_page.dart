import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pointolio/common/ui/tokens/spacing.dart';
import 'package:pointolio/features/manage/presentation/cubit/theme_cubit.dart';
import 'package:pointolio/features/manage/presentation/cubit/theme_state.dart';
import 'package:pointolio/features/manage/presentation/widgets/theme_selector.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: Spacing.page,
        children: [
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
