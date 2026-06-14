import 'package:flutter/material.dart';

/// Width-aware grid used by every center + the home preview sections.
///
/// Replaces the `LayoutBuilder → crossAxisCount → MasonryGridView.count`
/// triple that used to be copy-pasted across 5 centers. Stays a leaf widget
/// (no bloc / fetch / filter knowledge) so it's safe to drop into any layout.
///
/// Implementation is a `LayoutBuilder + Wrap` rather than a `MasonryGridView`
/// — the staggered grid's `shrinkWrap + NeverScrollableScrollPhysics` pair
/// was tripping "RenderBox was not laid out" / "hit test with no size"
/// assertions when nested in a `SingleChildScrollView > Column`. Wrap gives
/// us responsive columns with a single layout pass and no Sliver/ScrollView
/// interaction; the trade-off is row-aligned heights instead of true masonry
/// packing (gaps below shorter tiles in mixed-height rows).
///
/// Usage:
/// ```dart
/// ResponsiveGrid<Course>(
///   items: courses,
///   itemBuilder: (ctx, c) => AdminCourseCard(course: c),
/// )
/// ```
class ResponsiveGrid<T> extends StatelessWidget {
  /// Data to render. Empty list renders an empty SizedBox — the caller is
  /// responsible for showing an empty state when appropriate (so this widget
  /// stays a layout primitive, not a UX policy enforcer).
  final List<T> items;

  /// Renders a single tile. Receives the standard build context + item.
  final Widget Function(BuildContext context, T item) itemBuilder;

  /// Horizontal padding around the grid. Defaults match the existing
  /// hand-rolled centers so the migration is a visual no-op.
  final EdgeInsetsGeometry padding;

  final double mainAxisSpacing;
  final double crossAxisSpacing;

  /// Width breakpoints → column count. Default `[600, 1000, 1400]` gives the
  /// 1 / 2 / 3 / 4 progression every center currently rolls by hand.
  ///
  /// Rule: `crossAxisCount = breakpoints.indexWhere((w) => maxWidth < w) + 1`,
  /// falling back to `breakpoints.length + 1` when none match (largest tier).
  final List<int> breakpoints;

  /// Whether to use `NeverScrollableScrollPhysics` so the grid plays nicely
  /// inside an outer scroll view (`SingleChildScrollView`). 99% of dashboard
  /// uses want this; opt out only when the grid is the sole scroll target.
  final bool insideScrollView;

  const ResponsiveGrid({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.mainAxisSpacing = 20,
    this.crossAxisSpacing = 20,
    this.breakpoints = const [600, 1000, 1400],
    this.insideScrollView = true,
  });

  /// Resolves a layout width to the column count using [breakpoints].
  /// Pure function — exposed so callers can pre-compute the tile width when
  /// they need to size something to match (e.g., a sibling skeleton row).
  int columnsFor(double maxWidth) {
    for (var i = 0; i < breakpoints.length; i++) {
      if (maxWidth < breakpoints[i]) return i + 1;
    }
    return breakpoints.length + 1;
  }

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    // Padding is applied OUTSIDE the LayoutBuilder so the builder sees the
    // post-padding constraint width (matches the actual tile area). Previously
    // [padding] was declared on the widget but never honored — every caller
    // assumed it worked, so its absence is what produced the missing horizontal
    // gutters across centers.
    return Padding(
      padding: padding,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cols = columnsFor(constraints.maxWidth);
          // Subtract the (cols - 1) inter-column gaps from the available
          // width and divide evenly. Each tile gets an explicit width so
          // children never collapse to zero (which is what produced the
          // "hit test on render box with no size" assertion on hover).
          final tileWidth = cols == 1
              ? constraints.maxWidth
              : (constraints.maxWidth - crossAxisSpacing * (cols - 1)) / cols;
          return Wrap(
            spacing: crossAxisSpacing,
            runSpacing: mainAxisSpacing,
            children: [
              for (final item in items)
                SizedBox(
                  width: tileWidth,
                  child: itemBuilder(context, item),
                ),
            ],
          );
        },
      ),
    );
  }
}
