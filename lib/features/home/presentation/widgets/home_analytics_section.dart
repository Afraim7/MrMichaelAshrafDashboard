import 'package:flutter/material.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/currency_formatter.dart';
import 'package:mrmichaelashrafdashboard/features/home/presentation/widgets/home_stat_card.dart';
import 'package:mrmichaelashrafdashboard/features/users/logic/users_cubit.dart';

/// Home analytics grid — 12 stat cards summarizing the whole platform.
///
/// Pure presentation: receives every number as a prop, doesn't fetch or
/// listen to anything. The parent (the Control Panel) handles loading the
/// data and passes it down here. Nulls render as `—` so the grid layout
/// stays stable while individual stats are still arriving.
///
/// Cards (in display order):
///   1. إجمالي الطلاب
///   2. طلاب أونلاين
///   3. طلاب السنتر
///   4. طلاب
///   5. طالبات
///   6. حسابات مفعّلة
///   7. حسابات غير مفعّلة
///   8. إجمالي الإيرادات
///   9. إجمالي الاشتراكات
///  10. إجمالي الكورسات
///  11. إجمالي الامتحانات
///  12. امتحانات نشطة
///  13. إجمالي الملاحظات
///  14. ملاحظات نشطة
class HomeAnalyticsSection extends StatelessWidget {
  final UsersBreakdown? studentsBreakdown;
  final int? coursesCount;
  final int? totalExamsCount;
  final int? activeExamsCount;
  final int? totalHighlightsCount;
  final int? activeHighlightsCount;
  final int? totalEnrollmentsCount;
  final double? totalRevenue;

  const HomeAnalyticsSection({
    super.key,
    required this.studentsBreakdown,
    required this.coursesCount,
    required this.totalExamsCount,
    required this.activeExamsCount,
    required this.totalHighlightsCount,
    required this.activeHighlightsCount,
    required this.totalEnrollmentsCount,
    required this.totalRevenue,
  });

  /// Renders an int as `'$n'` or em-dash when null. Keeps every stat tile's
  /// fallback identical so the grid never shows mixed loading states.
  String _n(int? n) => n == null ? '—' : '$n';
  String _money(double? v) => v == null ? '—' : CurrencyFormatter.compact(v);

  @override
  Widget build(BuildContext context) {
    final b = studentsBreakdown;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.start,
      children: [
        HomeStatCard(
          icon: Icons.groups_rounded,
          title: 'إجمالي الطلاب',
          value: _n(b?.total),
          accent: AppColors.royalBlue,
        ),
        HomeStatCard(
          icon: Icons.wifi_rounded,
          title: 'طلاب أونلاين',
          value: _n(b?.online),
          accent: AppColors.midBlue,
        ),
        HomeStatCard(
          icon: Icons.business_rounded,
          title: 'طلاب السنتر',
          value: _n(b?.center),
          accent: AppColors.energyOrange,
        ),
        HomeStatCard(
          icon: Icons.man,
          title: 'طلاب',
          value: _n(b?.male),
          accent: AppColors.skyBlue,
        ),
        HomeStatCard(
          icon: Icons.woman,
          title: 'طالبات',
          value: _n(b?.female),
          accent: AppColors.posterRed,
        ),
        HomeStatCard(
          icon: Icons.verified_user_rounded,
          title: 'حسابات مفعّلة',
          value: _n(b?.verified),
          accent: AppColors.pastelGreen,
        ),
        HomeStatCard(
          icon: Icons.person_off_rounded,
          title: 'حسابات غير مفعّلة',
          value: _n(b?.unverified),
          accent: AppColors.tomatoRed,
        ),
        HomeStatCard(
          icon: Icons.savings_rounded,
          title: 'إجمالي الإيرادات',
          value: _money(totalRevenue),
          accent: AppColors.emeraldGreen,
        ),
        HomeStatCard(
          icon: Icons.person_add_alt_1_rounded,
          title: 'إجمالي الاشتراكات',
          value: _n(totalEnrollmentsCount),
          accent: AppColors.midBlue,
        ),
        HomeStatCard(
          icon: Icons.menu_book_rounded,
          title: 'إجمالي الكورسات',
          value: _n(coursesCount),
          accent: AppColors.royalYellow,
        ),
        HomeStatCard(
          icon: Icons.description_rounded,
          title: 'إجمالي الامتحانات',
          value: _n(totalExamsCount),
          accent: AppColors.skyBlue,
        ),
        HomeStatCard(
          icon: Icons.edit_note_rounded,
          title: 'امتحانات نشطة',
          value: _n(activeExamsCount),
          accent: AppColors.pastelGreen,
        ),
        HomeStatCard(
          icon: Icons.campaign_rounded,
          title: 'إجمالي الملاحظات',
          value: _n(totalHighlightsCount),
          accent: AppColors.energyOrange,
        ),
        HomeStatCard(
          icon: Icons.notifications_rounded,
          title: 'ملاحظات نشطة',
          value: _n(activeHighlightsCount),
          accent: AppColors.royalYellow,
        ),
      ],
    );
  }
}
