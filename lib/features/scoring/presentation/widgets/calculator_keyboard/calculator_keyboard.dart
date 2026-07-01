import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pointolio/common/theme/pointolio_theme.dart';
import 'package:pointolio/common/ui/tokens/spacing.dart';
import 'package:pointolio/features/scoring/presentation/widgets/calculator_keyboard/calculator_logic.dart';

/// A TextField that shows a calculator overlay above the keyboard.
/// - TextField displays the calculated result (e.g., "80")
/// - Overlay displays the expression (e.g., "50+30")
class CalculatorTextField extends StatefulWidget {
  const CalculatorTextField({
    required this.controller,
    required this.onFocusChanged,
    this.focusNode,
    this.autofocus = false,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.decoration = const InputDecoration(),
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<bool> onFocusChanged;
  final FocusNode? focusNode;
  final bool autofocus;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final InputDecoration decoration;

  @override
  State<CalculatorTextField> createState() => _CalculatorTextFieldState();
}

class _CalculatorTextFieldState extends State<CalculatorTextField> {
  late final FocusNode _focusNode;
  late final bool _isInternalFocusNode;
  final _calculator = CalculatorLogic();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    // Use external focus node if provided, otherwise create internal one
    _isInternalFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onControllerChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChange);
    _focusNode.removeListener(_onFocusChange);
    // Only dispose if we created the focus node internally
    if (_isInternalFocusNode) {
      _focusNode.dispose();
    }
    _removeOverlay();
    super.dispose();
  }

  void _onControllerChange() {
    // Detect if controller was cleared externally (by Reset button)
    if (widget.controller.text.isEmpty && !_calculator.isEmpty) {
      _calculator.clear();
      _overlayEntry?.markNeedsBuild();
    }
  }

  void _onFocusChange() {
    final hasFocus = _focusNode.hasFocus;
    widget.onFocusChanged(hasFocus);

    if (hasFocus) {
      _showOverlay();
    } else {
      _finalizeAndClose();
    }
  }

  void _showOverlay() {
    _removeOverlay();

    // Initialize expression from controller if not empty
    final controllerText = widget.controller.text.trim();
    if (controllerText.isEmpty || controllerText == '0') {
      _calculator.clear();
    } else {
      _calculator.expression = controllerText;
    }

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: NumericKeyboard(
          expression: _calculator.expression,
          onDigitPressed: _onDigitPressed,
          onOperatorPressed: _onOperatorPressed,
          onBackspacePressed: _onBackspace,
          onActionPressed: _onActionPressed,
          textInputAction: widget.textInputAction,
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
  }

  void _onDigitPressed(String digit) {
    unawaited(HapticFeedback.lightImpact());
    _calculator.appendDigit(digit);
    _updateDisplay();
    _overlayEntry?.markNeedsBuild();
  }

  void _onOperatorPressed(String op) {
    unawaited(HapticFeedback.lightImpact());
    _calculator.appendOperator(op);
    _updateDisplay();
    _overlayEntry?.markNeedsBuild();
  }

  void _onBackspace() {
    unawaited(HapticFeedback.lightImpact());
    _calculator.backspace();
    _updateDisplay();
    _overlayEntry?.markNeedsBuild();
  }

  void _onActionPressed() {
    unawaited(HapticFeedback.mediumImpact());
    _finalizeExpression();

    if (widget.textInputAction == TextInputAction.next) {
      FocusScope.of(context).nextFocus();
    } else {
      widget.onSubmitted?.call(widget.controller.text);
      _focusNode.unfocus();
    }
  }

  void _updateDisplay() {
    final displayValue = _calculator.displayValue;
    widget.controller
      ..text = displayValue
      ..selection = TextSelection.collapsed(offset: displayValue.length);
  }

  void _finalizeExpression() {
    final result = _calculator.finalize();
    if (result != null) {
      widget.controller.text = result.toString();
    }
  }

  void _finalizeAndClose() {
    _finalizeExpression();
    _removeOverlay();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      focusNode: _focusNode,
      readOnly: true,
      showCursor: true,
      autofocus: widget.autofocus,
      autocorrect: false,
      textInputAction: widget.textInputAction,
      decoration: widget.decoration,
      onSubmitted: (value) {
        _finalizeExpression();
        widget.onSubmitted?.call(value);
      },
    );
  }
}

// =================== Numeric Keyboard ===================

/// Custom numeric keyboard with calculator toolbar.
/// Adapts layout for phones (compact) and tablets (wider buttons).
class NumericKeyboard extends StatelessWidget {
  const NumericKeyboard({
    required this.expression,
    required this.onDigitPressed,
    required this.onOperatorPressed,
    required this.onBackspacePressed,
    required this.onActionPressed,
    required this.textInputAction,
    super.key,
  });

  final String expression;
  final ValueChanged<String> onDigitPressed;
  final ValueChanged<String> onOperatorPressed;
  final VoidCallback onBackspacePressed;
  final VoidCallback onActionPressed;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Detect a real tablet by the shortest side, not raw width - otherwise
        // a landscape phone reads as a "tablet" and gets an oversized keyboard
        // that is taller than the screen.
        final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;
        return _KeyboardContainer(
          isTablet: isTablet,
          child: _KeyboardContent(
            expression: expression,
            onDigitPressed: onDigitPressed,
            onOperatorPressed: onOperatorPressed,
            onBackspacePressed: onBackspacePressed,
            onActionPressed: onActionPressed,
            textInputAction: textInputAction,
            isTablet: isTablet,
          ),
        );
      },
    );
  }
}

class _KeyboardContainer extends StatelessWidget {
  const _KeyboardContainer({
    required this.isTablet,
    required this.child,
  });

  final bool isTablet;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;

    return Material(
      color: pt.surface,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: pt.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? Spacing.xl : Spacing.sm,
              vertical: Spacing.sm,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isTablet ? 480 : 400),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _KeyboardContent extends StatelessWidget {
  const _KeyboardContent({
    required this.expression,
    required this.onDigitPressed,
    required this.onOperatorPressed,
    required this.onBackspacePressed,
    required this.onActionPressed,
    required this.textInputAction,
    required this.isTablet,
  });

  final String expression;
  final ValueChanged<String> onDigitPressed;
  final ValueChanged<String> onOperatorPressed;
  final VoidCallback onBackspacePressed;
  final VoidCallback onActionPressed;
  final TextInputAction textInputAction;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final buttonHeight = calculatorKeyButtonHeight(context, isTablet: isTablet);
    final gap = isTablet ? Spacing.sm : Spacing.xs;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Expression display & operator row
        _ExpressionToolbar(
          expression: expression,
          onOperatorPressed: onOperatorPressed,
          onBackspacePressed: onBackspacePressed,
          isTablet: isTablet,
        ),
        SizedBox(height: gap),
        // Number grid (4 rows)
        _NumberGrid(
          onDigitPressed: onDigitPressed,
          onActionPressed: onActionPressed,
          textInputAction: textInputAction,
          buttonHeight: buttonHeight,
          gap: gap,
          isTablet: isTablet,
        ),
      ],
    );
  }
}

// =================== Expression Toolbar ===================

class _ExpressionToolbar extends StatelessWidget {
  const _ExpressionToolbar({
    required this.expression,
    required this.onOperatorPressed,
    required this.onBackspacePressed,
    required this.isTablet,
  });

  final String expression;
  final ValueChanged<String> onOperatorPressed;
  final VoidCallback onBackspacePressed;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final tt = Theme.of(context).textTheme;
    final buttonSize = isTablet ? 52.0 : 44.0;

    return Row(
      children: [
        // Expression display
        Expanded(
          child: Container(
            height: buttonSize,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: pt.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: pt.border),
            ),
            alignment: Alignment.centerRight,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse: true,
              child: Text(
                expression.isEmpty ? '0' : expression,
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Operators
        _OperatorButton(
          label: '+',
          onPressed: () => onOperatorPressed('+'),
          size: buttonSize,
        ),
        const SizedBox(width: 6),
        _OperatorButton(
          label: '−',
          onPressed: () => onOperatorPressed('-'),
          size: buttonSize,
        ),
        const SizedBox(width: 10),
        // Backspace
        _IconActionButton(
          icon: Icons.backspace_outlined,
          onPressed: onBackspacePressed,
          isDestructive: true,
          size: buttonSize,
        ),
      ],
    );
  }
}

// =================== Number Grid ===================

class _NumberGrid extends StatelessWidget {
  const _NumberGrid({
    required this.onDigitPressed,
    required this.onActionPressed,
    required this.textInputAction,
    required this.buttonHeight,
    required this.gap,
    required this.isTablet,
  });

  final ValueChanged<String> onDigitPressed;
  final VoidCallback onActionPressed;
  final TextInputAction textInputAction;
  final double buttonHeight;
  final double gap;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final actionLabel = textInputAction == TextInputAction.next
        ? 'Next'
        : 'Done';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Row 1: 1 2 3
        _buildRow(['1', '2', '3'], context),
        SizedBox(height: gap),
        // Row 2: 4 5 6
        _buildRow(['4', '5', '6'], context),
        SizedBox(height: gap),
        // Row 3: 7 8 9
        _buildRow(['7', '8', '9'], context),
        SizedBox(height: gap),
        // Row 4: empty 0 action
        Row(
          children: [
            Expanded(
              child: SizedBox(height: buttonHeight),
            ),
            SizedBox(width: gap),
            Expanded(
              child: _KeyButton(
                label: '0',
                onPressed: () => onDigitPressed('0'),
                height: buttonHeight,
                isTablet: isTablet,
              ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: _KeyButton(
                label: actionLabel,
                onPressed: onActionPressed,
                isAction: true,
                height: buttonHeight,
                isTablet: isTablet,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRow(List<String> digits, BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < digits.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          Expanded(
            child: _KeyButton(
              label: digits[i],
              onPressed: () => onDigitPressed(digits[i]),
              height: buttonHeight,
              isTablet: isTablet,
            ),
          ),
        ],
      ],
    );
  }
}

// =================== Button Widgets ===================

class _OperatorButton extends StatelessWidget {
  const _OperatorButton({
    required this.label,
    required this.onPressed,
    required this.size,
  });

  final String label;
  final VoidCallback onPressed;
  final double size;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;

    return Material(
      color: pt.accent.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: pt.accent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconActionButton extends StatelessWidget {
  const _IconActionButton({
    required this.icon,
    required this.onPressed,
    required this.size,
    this.isDestructive = false,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final double size;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final danger = pt.players[3];
    final bgColor = isDestructive
        ? danger.withValues(alpha: 0.12)
        : pt.accent.withValues(alpha: 0.12);
    final iconColor = isDestructive ? danger : pt.accent;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Center(
            child: Icon(icon, size: 20, color: iconColor),
          ),
        ),
      ),
    );
  }
}

class _KeyButton extends StatelessWidget {
  const _KeyButton({
    required this.onPressed,
    required this.height,
    required this.isTablet,
    this.label,
    this.isAction = false,
  });

  final VoidCallback onPressed;
  final double height;
  final bool isTablet;
  final String? label;
  final bool isAction;

  @override
  Widget build(BuildContext context) {
    final pt = context.pt;
    final tt = Theme.of(context).textTheme;

    final bgColor = isAction ? pt.accent : pt.surface;
    final fgColor = isAction ? pt.accentText : pt.text;
    final fontSize = isTablet ? 22.0 : 20.0;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(14),
      elevation: isAction ? 0 : 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onPressed,
        child: Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: isAction
                ? null
                : Border.all(color: pt.border, width: 0.5),
          ),
          alignment: Alignment.center,
          child: Text(
            label ?? '',
            style: (isAction ? tt.titleMedium : tt.titleLarge)?.copyWith(
              fontWeight: FontWeight.w600,
              color: fgColor,
              fontSize: fontSize,
            ),
          ),
        ),
      ),
    );
  }
}

// =================== Keyboard Height Helper ===================

/// Height of a single number-key button. Shrinks on short viewports (landscape
/// phones) so the whole keyboard still fits above the fold. Shared by the
/// keyboard layout and [getCalculatorKeyboardHeight] so they stay in sync.
double calculatorKeyButtonHeight(
  BuildContext context, {
  required bool isTablet,
}) {
  if (isTablet) return 64;
  // Landscape phones are short - use a compact key so the keyboard does not
  // eat the whole screen and hide the inputs.
  final isShort = MediaQuery.sizeOf(context).height < 500;
  return isShort ? 40 : 52;
}

/// Returns the total height of the calculator keyboard for layout calculations.
double getCalculatorKeyboardHeight(BuildContext context) {
  final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;
  final buttonHeight = calculatorKeyButtonHeight(context, isTablet: isTablet);
  final gap = isTablet ? Spacing.sm : Spacing.xs;

  // toolbar (buttonHeight) + 4 rows + gaps + padding
  final toolbarHeight = isTablet ? 52.0 : 44.0;
  final gridHeight = (buttonHeight * 4) + (gap * 3);
  const verticalPadding = Spacing.sm * 2;

  return toolbarHeight + gap + gridHeight + verticalPadding;
}
