import 'dart:async';

import 'package:flutter/material.dart';

enum ToastType { info, error, warning, success }

class ToastMessage {
  static OverlayEntry? _currentToast;
  static Timer? _dismissTimer;

  static void show(
    BuildContext context, {
    required String message,
    ToastType type = ToastType.info,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onDismissed,
  }) {
    _dismissCurrentToast();

    final overlay = Overlay.of(context, rootOverlay: true);
    final animationController = AnimationController(
      vsync: overlay,
      duration: const Duration(milliseconds: 300),
    );

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _ToastOverlay(
        message: message,
        type: type,
        animation: animationController,
        onDismiss: () => _dismissToast(entry, animationController, onDismissed),
      ),
    );

    _currentToast = entry;
    overlay.insert(entry);
    unawaited(animationController.forward());

    _dismissTimer = Timer(duration, () {
      _dismissToast(entry, animationController, onDismissed);
    });
  }

  static void _dismissCurrentToast() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentToast?.remove();
    _currentToast = null;
  }

  static void _dismissToast(
    OverlayEntry entry,
    AnimationController controller,
    VoidCallback? onDismissed,
  ) {
    if (_currentToast != entry) return;

    unawaited(
      controller.reverse().then((_) {
        if (_currentToast == entry) {
          entry.remove();
          _currentToast = null;
          controller.dispose();
          onDismissed?.call();
        }
      }),
    );
  }

  static void info(BuildContext context, String message) {
    show(context, message: message);
  }

  static void error(BuildContext context, String message) {
    show(context, message: message, type: ToastType.error);
  }

  static void warning(BuildContext context, String message) {
    show(context, message: message, type: ToastType.warning);
  }

  static void success(BuildContext context, String message) {
    show(context, message: message, type: ToastType.success);
  }
}

class _ToastOverlay extends StatelessWidget {
  const _ToastOverlay({
    required this.message,
    required this.type,
    required this.animation,
    required this.onDismiss,
  });

  final String message;
  final ToastType type;
  final Animation<double> animation;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final slideAnimation =
        Tween<Offset>(
          begin: const Offset(0, -1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
        );

    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
    );

    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: GestureDetector(
            onTap: onDismiss,
            onHorizontalDragEnd: (_) => onDismiss(),
            child: _ToastContent(
              message: message,
              type: type,
              onDismiss: onDismiss,
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastContent extends StatelessWidget {
  const _ToastContent({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  final String message;
  final ToastType type;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = _getColors(theme);

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildIcon(colors),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.foreground,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close_rounded,
                size: 20,
                color: colors.foreground.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(_ToastColors colors) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: colors.iconBackground,
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getIcon(),
        size: 18,
        color: colors.icon,
      ),
    );
  }

  IconData _getIcon() {
    return switch (type) {
      ToastType.info => Icons.info_outline_rounded,
      ToastType.error => Icons.error_outline_rounded,
      ToastType.warning => Icons.warning_amber_rounded,
      ToastType.success => Icons.check_circle_outline_rounded,
    };
  }

  _ToastColors _getColors(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return switch (type) {
      ToastType.info => _ToastColors(
        background: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE8F4FD),
        border: isDark ? const Color(0xFF2E5A8F) : const Color(0xFFB8D8F8),
        foreground: isDark ? const Color(0xFFE8F4FD) : const Color(0xFF1E3A5F),
        icon: isDark ? const Color(0xFF64B5F6) : const Color(0xFF1976D2),
        iconBackground: isDark
            ? const Color(0xFF0D47A1).withValues(alpha: 0.3)
            : const Color(0xFFBBDEFB),
      ),
      ToastType.error => _ToastColors(
        background: isDark ? const Color(0xFF5F1E1E) : const Color(0xFFFDECEC),
        border: isDark ? const Color(0xFF8F2E2E) : const Color(0xFFF8B8B8),
        foreground: isDark ? const Color(0xFFFDECEC) : const Color(0xFF5F1E1E),
        icon: isDark ? const Color(0xFFEF5350) : const Color(0xFFD32F2F),
        iconBackground: isDark
            ? const Color(0xFFB71C1C).withValues(alpha: 0.3)
            : const Color(0xFFFFCDD2),
      ),
      ToastType.warning => _ToastColors(
        background: isDark ? const Color(0xFF5F4A1E) : const Color(0xFFFFF8E1),
        border: isDark ? const Color(0xFF8F6A2E) : const Color(0xFFFFE082),
        foreground: isDark ? const Color(0xFFFFF8E1) : const Color(0xFF5F4A1E),
        icon: isDark ? const Color(0xFFFFCA28) : const Color(0xFFF9A825),
        iconBackground: isDark
            ? const Color(0xFFF57F17).withValues(alpha: 0.3)
            : const Color(0xFFFFECB3),
      ),
      ToastType.success => _ToastColors(
        background: isDark ? const Color(0xFF1E5F2E) : const Color(0xFFE8F5E9),
        border: isDark ? const Color(0xFF2E8F4A) : const Color(0xFFA5D6A7),
        foreground: isDark ? const Color(0xFFE8F5E9) : const Color(0xFF1E5F2E),
        icon: isDark ? const Color(0xFF66BB6A) : const Color(0xFF388E3C),
        iconBackground: isDark
            ? const Color(0xFF1B5E20).withValues(alpha: 0.3)
            : const Color(0xFFC8E6C9),
      ),
    };
  }
}

class _ToastColors {
  const _ToastColors({
    required this.background,
    required this.border,
    required this.foreground,
    required this.icon,
    required this.iconBackground,
  });

  final Color background;
  final Color border;
  final Color foreground;
  final Color icon;
  final Color iconBackground;
}
