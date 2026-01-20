import 'package:flutter/material.dart';
import 'package:scoreio/common/ui/tokens/spacing.dart';

typedef PickerItemLabel<T> = String Function(T item);
typedef PickerItemSearchText<T> = String Function(T item);
typedef PickerItemBuilder<T> = Widget Function(BuildContext context, T item);
typedef PickerItemKey<T> = Object Function(T item);

class PickerSheet<T> extends StatefulWidget {
  const PickerSheet({
    required this.title,
    required this.items,
    required this.itemLabel,
    this.itemBuilder,
    this.itemKey,
    this.searchText,
    this.searchHintText = 'Search...',
    this.emptyTitle,
    this.emptySubtitle,
    this.initialQuery,
    this.maxHeightFactor = 0.82,
    super.key,
  });

  final String title;
  final List<T> items;

  /// Used for:
  /// - default row label
  /// - filtering (unless [searchText] is provided)
  final PickerItemLabel<T> itemLabel;

  /// If provided, controls how rows look.
  /// If not provided, a simple default tile is used.
  final PickerItemBuilder<T>? itemBuilder;

  /// Optional stable key extractor for list rows.
  final PickerItemKey<T>? itemKey;

  /// Optional search string extractor (defaults to [itemLabel]).
  final PickerItemSearchText<T>? searchText;

  final String searchHintText;
  final String? emptyTitle;
  final String? emptySubtitle;
  final String? initialQuery;

  /// Height = screenHeight * factor
  final double maxHeightFactor;

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required String Function(T item) itemLabel,
    Widget Function(BuildContext context, T item)? itemBuilder,
    Object Function(T item)? itemKey,
    String Function(T item)? searchText,
    String searchHintText = 'Search...',
    String? emptyTitle,
    String? emptySubtitle,
    String? initialQuery,
    double maxHeightFactor = 0.82,
  }) {
    final cs = Theme.of(context).colorScheme;

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (_) => PickerSheet<T>(
        title: title,
        items: items,
        itemLabel: itemLabel,
        itemBuilder: itemBuilder,
        itemKey: itemKey,
        searchText: searchText,
        searchHintText: searchHintText,
        emptyTitle: emptyTitle,
        emptySubtitle: emptySubtitle,
        initialQuery: initialQuery,
        maxHeightFactor: maxHeightFactor,
      ),
    );
  }

  @override
  State<PickerSheet<T>> createState() => _PickerSheetState<T>();
}

class _PickerSheetState<T> extends State<PickerSheet<T>> {
  late final TextEditingController _search;

  @override
  void initState() {
    super.initState();
    _search = TextEditingController(text: widget.initialQuery ?? '');
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<T> get _filteredItems {
    final query = _search.text.trim().toLowerCase();
    if (query.isEmpty) return widget.items;

    final textOf = widget.searchText ?? widget.itemLabel;

    return widget.items.where((e) {
      final haystack = textOf(e).toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final maxHeight =
        MediaQuery.sizeOf(context).height * widget.maxHeightFactor;
    final filtered = _filteredItems;

    return SizedBox(
      height: maxHeight,
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: cs.outlineVariant,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          Spacing.gap12,

          // Header
          Padding(
            padding: Spacing.sheetHorizontal,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: tt.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),

          // Search
          Padding(
            padding: Spacing.search,
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: widget.searchHintText,
                prefixIcon: const Icon(Icons.search),
              ),
              textInputAction: TextInputAction.search,
            ),
          ),

          // List
          Expanded(
            child: filtered.isEmpty
                ? _EmptySheetState(
                    title: widget.emptyTitle ?? 'Nothing here',
                    subtitle:
                        widget.emptySubtitle ?? 'Try changing your search.',
                  )
                : ListView.separated(
                    padding: Spacing.list,
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => Spacing.gap12,
                    itemBuilder: (context, index) {
                      final item = filtered[index];

                      final child = widget.itemBuilder != null
                          ? widget.itemBuilder!(context, item)
                          : _DefaultPickerTile(
                              label: widget.itemLabel(item),
                            );

                      final key = widget.itemKey != null
                          ? ValueKey<Object>(widget.itemKey!(item))
                          : null;

                      return KeyedSubtree(
                        key: key,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () => Navigator.pop<T>(context, item),
                            child: child,
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DefaultPickerTile extends StatelessWidget {
  const _DefaultPickerTile({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: tt.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _EmptySheetState extends StatelessWidget {
  const _EmptySheetState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, size: 44, color: cs.onSurfaceVariant),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
