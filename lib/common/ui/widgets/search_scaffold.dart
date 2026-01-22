import 'package:flutter/material.dart';

/// A Scaffold with an AppBar action that toggles an inline (sticky) search bar.
///
/// - Search bar is shown below the AppBar (inside body).
/// - Holds its own controller + focus.
/// - Calls [onSearchChanged] on every change.
/// - Optional clear & toggle behavior.
///
/// Usage:
/// SearchScaffold(
///   title: Text('Players'),
///   onSearchChanged: (q) => cubit.setSearchQuery(q.isEmpty ? null : q),
///   body: ...,
///   floatingActionButton: ...,
/// )
class SearchScaffold extends StatefulWidget {
  const SearchScaffold({
    required this.title,
    required this.body,
    required this.onSearchChanged,

    this.backgroundColor,
    this.floatingActionButton,
    this.actions,
    this.searchHintText = 'Search...',
    this.initialQuery,
    this.searchInitiallyOpen = false,
    this.searchAnimationDuration = const Duration(milliseconds: 180),
    this.onClear,
    this.collapseOnClear = false,
    super.key,
  });

  final Widget title;
  final Widget body;

  /// Called whenever user types.
  /// You can map empty -> null in the caller if your cubit expects nullable.
  final ValueChanged<String> onSearchChanged;

  /// Optional: override scaffold background.
  final Color? backgroundColor;

  /// Optional: extra AppBar actions (besides search toggle).
  final List<Widget>? actions;

  /// Optional: FAB.
  final Widget? floatingActionButton;

  /// Search hint text.
  final String searchHintText;

  /// Starting query (e.g. from cubit state).
  final String? initialQuery;

  /// Whether search is open by default.
  final bool searchInitiallyOpen;

  final Duration searchAnimationDuration;

  /// Optional: additional callback when clearing.
  final VoidCallback? onClear;

  /// If true, clearing will also close search.
  final bool collapseOnClear;

  @override
  State<SearchScaffold> createState() => _SearchScaffoldState();
}

class _SearchScaffoldState extends State<SearchScaffold> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  late bool _searchOpen;

  @override
  void initState() {
    super.initState();
    _searchOpen = widget.searchInitiallyOpen;
    _controller = TextEditingController(text: widget.initialQuery ?? '');
    _focusNode = FocusNode();

    // If open initially, focus after first frame
    if (_searchOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(covariant SearchScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If parent updates initialQuery (e.g. bloc state change),
    //keep controller in sync.
    final newText = widget.initialQuery ?? '';
    if (oldWidget.initialQuery != widget.initialQuery &&
        _controller.text != newText) {
      _controller.value = _controller.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
        composing: TextRange.empty,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() => _searchOpen = !_searchOpen);

    if (_searchOpen) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    } else {
      _focusNode.unfocus();
    }
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearchChanged('');
    widget.onClear?.call();

    if (widget.collapseOnClear) {
      setState(() => _searchOpen = false);
      _focusNode.unfocus();
    } else {
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: widget.backgroundColor ?? cs.surface,
      appBar: AppBar(
        title: widget.title,
        actions: [
          if (widget.actions != null) ...widget.actions!,
          IconButton(
            icon: Icon(_searchOpen ? Icons.close : Icons.search),
            onPressed: _toggleSearch,
            tooltip: _searchOpen ? 'Close search' : 'Search',
          ),
        ],
      ),
      body: Column(
        children: [
          AnimatedSwitcher(
            duration: widget.searchAnimationDuration,
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            child: _searchOpen
                ? _InlineSearchBar(
                    key: const ValueKey('search-open'),
                    controller: _controller,
                    focusNode: _focusNode,
                    hintText: widget.searchHintText,
                    onChanged: widget.onSearchChanged,
                    onClear: _clearSearch,
                  )
                : const SizedBox.shrink(key: ValueKey('search-closed')),
          ),
          Expanded(child: widget.body),
        ],
      ),
      floatingActionButton: widget.floatingActionButton,
    );
  }
}

/// Internal search bar (same as your _SearchBar but reusable)
class _InlineSearchBar extends StatelessWidget {
  const _InlineSearchBar({
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.onChanged,
    required this.onClear,
    super.key,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: onClear,
                    tooltip: 'Clear',
                  ),
            filled: true,
            fillColor: cs.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: cs.outlineVariant),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }
}
