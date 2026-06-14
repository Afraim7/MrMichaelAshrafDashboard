import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_assets.dart';
import 'package:mrmichaelashrafdashboard/core/enums/button_state.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/currency_formatter.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/dashboard_helper.dart';
import 'package:mrmichaelashrafdashboard/features/courses/logic/courses_cubit.dart';
import 'package:mrmichaelashrafdashboard/features/courses/logic/courses_state.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/app_sub_button.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/dashboard_card.dart';
import 'package:mrmichaelashrafdashboard/shared/widgets/dashboard_card_visibility_toggle.dart';

class CourseCard extends StatelessWidget {
  final String courseId;
  final String title;
  final String describtion;
  final int numberOfLessons;
  final String grade;
  final int studentsCount;
  final String? imageUrl;
  final VoidCallback? onTap;
  final double price;
  final VoidCallback? onLongPress;
  final VoidCallback? onViewEnrollments;

  /// Admin visibility flag. Hidden courses render dimmed so the admin can
  /// tell at a glance which ones aren't live for students yet.
  final bool isVisible;

  const CourseCard({
    super.key,
    required this.courseId,
    required this.title,
    required this.describtion,
    required this.grade,
    required this.studentsCount,
    this.imageUrl,
    this.onTap,
    this.onLongPress,
    this.onViewEnrollments,
    required this.numberOfLessons,
    required this.price,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasDescription = describtion.trim().isNotEmpty;

    // Hidden → faded. AnimatedOpacity so a toggle visibly fades/brightens.
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 250),
      opacity: isVisible ? 1.0 : 0.55,
      child: DashboardCard(
        backgroundColor: AppColors.surfaceDark,
        clipBehavior: Clip.antiAlias,
        onTap: onTap,
        onLongPress: onLongPress,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── HERO: image + overlays ─────────────────────────────────────
            _CoverHero(
              imageUrl: imageUrl,
              price: price,
              courseId: courseId,
              isVisible: isVisible,
            ),

            // ── BODY: title + description + stat strip ────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.scheherazadeNew(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: AppColors.appWhite,
                      height: 1.3,
                    ),
                  ),
                  if (hasDescription) ...[
                    const SizedBox(height: 6),
                    Text(
                      describtion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.scheherazadeNew(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppColors.textSecondaryDark,
                        height: 1.5,
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // Compact stat strip — three pills, evenly weighted
                  Row(
                    children: [
                      _StatPill(
                        icon: Icons.menu_book_outlined,
                        label: '$numberOfLessons درس',
                        color: AppColors.midBlue,
                      ),
                      const SizedBox(width: 8),
                      _StatPill(
                        icon: Icons.group_rounded,
                        label: '$studentsCount',
                        color: AppColors.skyBlue,
                      ),
                      const Spacer(),
                      _StatPill(
                        icon: Icons.school_outlined,
                        label: grade,
                        color: AppColors.royalBlue,
                        filled: true,
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),
                  _RevenueRow(courseId: courseId),
                  if (onViewEnrollments != null) ...[
                    const SizedBox(height: 15),
                    AppSubButton(
                      title: 'عرض المسجّلين',
                      titleSize: 16,
                      backgroundColor: AppColors.cardDark.withAlpha(90),
                      onTap: onViewEnrollments ?? () {},
                      state: ButtonState.idle,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoverHero extends StatelessWidget {
  final String? imageUrl;
  final double price;
  final String courseId;
  final bool isVisible;

  const _CoverHero({
    required this.imageUrl,
    required this.price,
    required this.courseId,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10),

      height: 170,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl != null && imageUrl!.startsWith('http'))
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage(imageUrl!),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(imageUrl ?? AppAssets.images.courseDefault),
                  fit: BoxFit.cover,
                ),
              ),
            ),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withAlpha(140)],
                ),
              ),
            ),
          ),

          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(90),
                borderRadius: BorderRadius.circular(14),
              ),
              child: _CourseVisibilityToggle(
                courseId: courseId,
                isVisible: isVisible,
              ),
            ),
          ),

          Positioned(
            bottom: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: AppColors.pastelGreen.withAlpha(230),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(90),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sell_outlined,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    CurrencyFormatter.compact(price),
                    style: GoogleFonts.amiri(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool filled;

  const _StatPill({
    required this.icon,
    required this.label,
    required this.color,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? color.withAlpha(45) : AppColors.surfaceAltDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(filled ? 100 : 40), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.amiri(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: filled ? Colors.white : color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RevenueRow extends StatefulWidget {
  final String courseId;
  const _RevenueRow({required this.courseId});

  @override
  State<_RevenueRow> createState() => _RevenueRowState();
}

class _RevenueRowState extends State<_RevenueRow> {
  // Fetched once (not in build) so scrolling the list doesn't re-query. This
  // is the SUM of successful payments — what students actually paid, after
  // discounts — not `price × enrollments`.
  late final Future<double> _revenueFuture = context
      .read<CoursesCubit>()
      .fetchCourseRevenue(widget.courseId);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.payments_rounded,
          size: 16,
          color: AppColors.emeraldGreen,
        ),
        const SizedBox(width: 8),
        Text(
          'الإيرادات',
          style: GoogleFonts.amiri(
            fontSize: 12,
            color: AppColors.neutral500,
            height: 1.2,
          ),
        ),
        const Spacer(),
        FutureBuilder<double>(
          future: _revenueFuture,
          builder: (context, snap) {
            final text = snap.connectionState == ConnectionState.waiting
                ? '…'
                : CurrencyFormatter.egp(snap.data ?? 0);
            return Text(
              text,
              style: GoogleFonts.amiri(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.emeraldGreen,
                height: 1.2,
              ),
            );
          },
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bloc-connected visibility toggle. Reads `isVisible` off the model (the
// center re-fetches the page on a successful toggle, so the glyph + card fade
// update once the write persists) and shows a per-card spinner while the
// matching ToggleCourseVisibilityLoading(id) is in flight.
// ─────────────────────────────────────────────────────────────────────────────

class _CourseVisibilityToggle extends StatefulWidget {
  final String courseId;
  final bool isVisible;

  const _CourseVisibilityToggle({
    required this.courseId,
    required this.isVisible,
  });

  @override
  State<_CourseVisibilityToggle> createState() =>
      _CourseVisibilityToggleState();
}

class _CourseVisibilityToggleState extends State<_CourseVisibilityToggle> {
  late bool _isVisible = widget.isVisible;
  bool _saving = false;

  @override
  void didUpdateWidget(_CourseVisibilityToggle old) {
    super.didUpdateWidget(old);
    // When the center re-fetches and rebuilds the card, sync to the model —
    // but never mid-save (our optimistic value is the source of truth then).
    if (!_saving && widget.isVisible != _isVisible) {
      _isVisible = widget.isVisible;
    }
  }

  Future<void> _toggle() async {
    if (_saving) return;
    final next = !_isVisible;
    // Optimistic: flip immediately so the tap clearly registers.
    setState(() {
      _isVisible = next;
      _saving = true;
    });

    final cubit = context.read<CoursesCubit>();
    await cubit.toggleCourseVisibility(
      courseId: widget.courseId,
      isVisible: next,
    );
    if (!mounted) return;

    final state = cubit.state;
    if (state is ToggleCourseVisibilityError) {
      // Revert + surface the reason loudly (this is how a denied Firestore
      // write becomes visible instead of silently doing nothing).
      setState(() {
        _isVisible = !next;
        _saving = false;
      });
      DashboardHelper.showErrorBar(context, error: state.message);
    } else {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Outer opaque GestureDetector OWNS the tap so it can never be eaten by
    // the card's full-surface onTap (open-manager). The inner toggle is
    // display-only (onChanged: null disables its InkWell).
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _saving ? null : _toggle,
      child: DashboardCardVisibilityToggle(
        isVisible: _isVisible,
        isUpdating: _saving,
        compact: true,
      ),
    );
  }
}
