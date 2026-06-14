import 'package:flutter/widgets.dart';

/// Single source of truth for spacing across the dashboard.
///
/// Every center used to define its own `EdgeInsets.all(20)` /
/// `EdgeInsets.symmetric(horizontal: 20)` / `SizedBox(height: 70)` —
/// changing the gutter meant grepping the repo. These constants centralize
/// that so the whole dashboard moves together.
class AppSpacing {
  AppSpacing._();

  // ─── Raw scale ─────────────────────────────────────────────────────────
  // Use these for one-off `SizedBox`es and ad-hoc spacing inside widgets.
  // Doubles, not ints, so they can feed straight into `SizedBox(height:)`.
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 30;
  static const double xxl = 50;
  static const double xxxl = 70;

  // ─── Dashboard chrome reserves ─────────────────────────────────────────
  /// Width the dashboard bar occupies on desktop (rail-style on the right).
  /// Content reserves this so it doesn't slide under the bar.
  static const double barReserveDesktop = 105;

  /// Height the dashboard bar occupies on mobile (chip-style at the top).
  static const double barReserveMobile = 100;

  /// Standard "screen safe area" padding — reserves the bar on the right for
  /// desktop or the top for mobile, then adds a small breathing edge. Use
  /// this on the outer scaffold of every center so the bar never overlaps
  /// content.
  static EdgeInsets screenSafe({required bool isDesktop}) => EdgeInsets.only(
    right: isDesktop ? barReserveDesktop : 0,
    top: isDesktop ? 0 : barReserveMobile,
    left: 20,
  );

  // ─── Semantic padding ──────────────────────────────────────────────────
  // Prefer these when you can — they communicate intent and survive a
  // refactor of the underlying scale.

  /// Horizontal gutter every center's content respects. Use for grids and
  /// any content that should align with the rest of the dashboard.
  static const EdgeInsets screenHorizontal = EdgeInsets.symmetric(
    horizontal: lg,
  );

  /// Standard "empty state / error / success card" padding — sits inside
  /// the screen's horizontal gutter.
  static const EdgeInsets screenBlock = EdgeInsets.all(lg);

  /// Vertical breathing room between distinct sections on a screen
  /// (e.g., header → analytics → filter → grid).
  static const EdgeInsets sectionGap = EdgeInsets.symmetric(vertical: xl);

  /// Card / sheet inner padding — what content sits inside a `DashboardCard`.
  static const EdgeInsets card = EdgeInsets.all(lg);

  /// Common SizedBoxes — saves re-typing the same gap dozens of times.
  static const SizedBox gapSm = SizedBox(height: sm);
  static const SizedBox gapMd = SizedBox(height: md);
  static const SizedBox gapLg = SizedBox(height: lg);
  static const SizedBox gapXl = SizedBox(height: xl);
  static const SizedBox gapXxl = SizedBox(height: xxl);

  static const SizedBox hgapSm = SizedBox(width: sm);
  static const SizedBox hgapMd = SizedBox(width: md);
  static const SizedBox hgapLg = SizedBox(width: lg);
}
