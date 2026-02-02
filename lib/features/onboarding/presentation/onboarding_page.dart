import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pointolio/common/ui/tokens/spacing.dart';
import 'package:pointolio/features/onboarding/presentation/widgets/calculator_preview.dart';
import 'package:pointolio/features/onboarding/presentation/widgets/feature_page_content.dart';
import 'package:pointolio/features/onboarding/presentation/widgets/page_indicator.dart';
import 'package:pointolio/features/onboarding/presentation/widgets/quick_actions_preview.dart';
import 'package:pointolio/features/onboarding/presentation/widgets/reorder_preview.dart';
import 'package:pointolio/features/onboarding/presentation/widgets/welcome_page_content.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    required this.onComplete,
    super.key,
  });

  final Future<void> Function() onComplete;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pageCount = 4;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    await widget.onComplete();
    if (mounted) {
      await Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/', (_) => false);
    }
  }

  void _nextPage() {
    if (_currentPage < _pageCount - 1) {
      unawaited(
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        ),
      );
    } else {
      unawaited(_complete());
    }
  }

  void _skip() {
    unawaited(_complete());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isLastPage = _currentPage == _pageCount - 1;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  onPressed: _skip,
                  child: Text(
                    isLastPage ? '' : 'Skip',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                ),
              ),
            ),
            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: const [
                  WelcomePageContent(),
                  FeaturePageContent(
                    preview: CalculatorPreview(),
                    title: 'Smart Score Entry',
                    description:
                        'Add scores with a calculator keyboard. '
                        'Type expressions like 50+30 and get instant results.',
                  ),
                  FeaturePageContent(
                    preview: QuickActionsPreview(),
                    title: 'Quick Actions',
                    description:
                        'Long press any game to edit, complete, or delete it.',
                  ),
                  FeaturePageContent(
                    preview: ReorderPreview(),
                    title: 'Reorder Players',
                    description:
                        'Hold and drag player names to change the order.',
                  ),
                ],
              ),
            ),
            // Indicator and button
            Padding(
              padding: Spacing.page,
              child: Column(
                children: [
                  PageIndicator(
                    pageCount: _pageCount,
                    currentPage: _currentPage,
                  ),
                  Spacing.gap24,
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _nextPage,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(isLastPage ? 'Get Started' : 'Next'),
                    ),
                  ),
                  Spacing.gap16,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
