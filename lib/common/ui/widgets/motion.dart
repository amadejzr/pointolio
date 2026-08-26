import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pointolio/common/theme/pointolio_tokens.dart';

/// Fade + rise entrance. Wrap list items and pass a staggered [delay]
/// (e.g. index * 60ms) for a clean cascade. Replays whenever remounted
/// (so switching tabs re-animates the incoming page).
class AnimatedEntrance extends StatefulWidget {
  const AnimatedEntrance({
    required this.child,
    super.key,
    this.delay = Duration.zero,
    this.duration = Motion.slow,
    this.offsetY = 14,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double offsetY;

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final Animation<double> _t = CurvedAnimation(
    parent: _controller,
    curve: Motion.ease,
  );

  @override
  void initState() {
    super.initState();
    unawaited(
      Future.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      }),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Respect the platform "reduce motion" setting.
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;

    return AnimatedBuilder(
      animation: _t,
      builder: (_, child) => Opacity(
        opacity: _t.value,
        child: Transform.translate(
          offset: Offset(0, (1 - _t.value) * widget.offsetY),
          child: child,
        ),
      ),
      child: widget.child,
    );
  }
}

/// Tap feedback: gently scales down while pressed. Use everywhere instead
/// of Material ink for the calm, tactile feel of the Notebook/Slate theme.
///
/// Accessibility: pass [semanticLabel] (and [isButton]/[selected]) to expose a
/// single, correctly-labelled semantics node. When labelled, the internal
/// gesture is excluded from semantics and the tap action is advertised on the
/// [Semantics] node itself. Set [excludeChildSemantics] to drop decorative
/// descendant labels (e.g. an icon-only button, or a tab whose label you set
/// explicitly).
class Pressable extends StatefulWidget {
  const Pressable({
    required this.child,
    super.key,
    this.onTap,
    this.onLongPress,
    this.scale = 0.96,
    this.semanticLabel,
    this.semanticHint,
    this.isButton = false,
    this.selected,
    this.excludeChildSemantics = false,
  });

  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double scale;
  final String? semanticLabel;
  final String? semanticHint;
  final bool isButton;
  final bool? selected;
  final bool excludeChildSemantics;

  @override
  State<Pressable> createState() => _PressableState();
}

class _PressableState extends State<Pressable> {
  bool _down = false;

  void _set(bool value) {
    if (_down != value) setState(() => _down = value);
  }

  @override
  Widget build(BuildContext context) {
    final hasSemantics =
        widget.isButton ||
        widget.semanticLabel != null ||
        widget.selected != null;

    var content = widget.child;
    if (widget.excludeChildSemantics) {
      content = ExcludeSemantics(child: content);
    }

    final gesture = GestureDetector(
      behavior: HitTestBehavior.opaque,
      excludeFromSemantics: hasSemantics,
      onTapDown: (_) => _set(true),
      onTapUp: (_) => _set(false),
      onTapCancel: () => _set(false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: Motion.fast,
        curve: Motion.ease,
        child: content,
      ),
    );

    if (!hasSemantics) return gesture;

    return Semantics(
      button: widget.isButton,
      selected: widget.selected,
      label: widget.semanticLabel,
      hint: widget.semanticHint,
      onTap: widget.onTap,
      child: gesture,
    );
  }
}
