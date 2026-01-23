import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pointolio/common/ui/tokens/spacing.dart';
import 'package:pointolio/features/manage/presentation/game_types_management_page.dart';
import 'package:pointolio/features/manage/presentation/players_management_page.dart';

class ManagePage extends StatelessWidget {
  const ManagePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ManageView();
  }
}

class _ManageView extends StatelessWidget {
  const _ManageView();

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
          _ManagementSection(
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
          _ManagementSection(
            title: 'Game Types',
            subtitle: 'Manage your game types',
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
        ],
      ),
    );
  }
}

class _ManagementSection extends StatelessWidget {
  const _ManagementSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: Spacing.page,
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: cs.primary,
                  size: 24,
                ),
              ),
              Spacing.hGap16,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Spacing.gap4,
                    Text(
                      subtitle,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Spacing.hGap12,
              Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
