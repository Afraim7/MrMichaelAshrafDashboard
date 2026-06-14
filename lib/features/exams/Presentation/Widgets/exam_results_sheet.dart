import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_strings.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/firebase_error_messages.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/exam.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/exam_result.dart';
import 'package:mrmichaelashrafdashboard/features/exams/logic/exams_cubit.dart';

/// Rich exam-results bottom-sheet matching the reference design.
///
/// Fetches its own data (results + student names + emails) when it opens, so
/// the loading state is shown INSIDE the sheet — the caller doesn't need to
/// pre-fetch or show a separate loading dialog.
class ExamResultsSheet extends StatefulWidget {
  final Exam exam;

  const ExamResultsSheet({super.key, required this.exam});

  @override
  State<ExamResultsSheet> createState() => _ExamResultsSheetState();
}

class _ExamResultsSheetState extends State<ExamResultsSheet> {
  // ─── State ─────────────────────────────────────────────────────────────────
  bool _isLoading = true;
  bool _hasError = false;

  /// Human-readable Arabic message — populated from the translator so admins
  /// see "تعذّر الاتصال بالإنترنت" or "ليس لديك صلاحية..." instead of a
  /// generic "something went wrong".
  String _errorMessage = '';

  List<ExamResult> _results = const [];
  Map<String, String> _namesMap = const {};
  Map<String, String> _emailsMap = const {};

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = '';
    });

    try {
      final cubit = context.read<ExamsCubit>();

      // 1) Fetch results first — we need the studentIDs before we can look up
      //    names/emails.
      final results = await cubit.fetchExamResults(widget.exam.examID);
      final userIds = results
          .map((r) => r.studentID)
          .where((id) => id.isNotEmpty)
          .toSet()
          .toList();

      // 2) Single batched `whereIn` lookup returns both name + email — one
      //    round-trip per 30 students instead of N parallel single-doc gets.
      final lookup = await cubit.fetchUserNamesAndEmails(userIds);

      if (!mounted) return;

      setState(() {
        _results = results;
        _namesMap = lookup.names;
        _emailsMap = lookup.emails;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      // Translate via the shared utility so the sheet shows the same kind of
      // typed Arabic messages every other surface uses (network / permission
      // / not-found etc.) — instead of swallowing the cause.
      final translated = FirebaseErrorTranslator.translate(
        e,
        fallback: AppStrings.errors.examAnswersLoadFailed,
      );
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = translated.message;
      });
    }
  }

  // ─── Computed stats ────────────────────────────────────────────────────────

  int get _totalUsers => _results.length;
  double get _fullMark => widget.exam.fullExamMark();

  int get _passedCount {
    if (_fullMark == 0) return 0;
    return _results.where((r) => (r.score ?? 0) >= _fullMark * 0.5).length;
  }

  int get _failedCount => _totalUsers - _passedCount;

  double get _passRate {
    if (_totalUsers == 0) return 0.0;
    return (_passedCount / _totalUsers) * 100;
  }

  double get _avgScorePercent {
    if (_results.isEmpty || _fullMark == 0) return 0.0;
    final total = _results.fold<double>(0, (s, r) => s + (r.score ?? 0));
    return (total / _results.length / _fullMark) * 100;
  }

  // ─── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SheetHeader(exam: widget.exam),
            const SizedBox(height: 20),

            if (_isLoading)
              const _LoadingState()
            else if (_hasError)
              _ErrorState(message: _errorMessage, onRetry: _loadResults)
            else
              _LoadedContent(
                results: _results,
                namesMap: _namesMap,
                emailsMap: _emailsMap,
                fullMark: _fullMark,
                passRate: _passRate,
                avgScorePercent: _avgScorePercent,
                passedCount: _passedCount,
                failedCount: _failedCount,
                totalUsers: _totalUsers,
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Header — visible in all three states (loading / error / loaded)
// ─────────────────────────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  final Exam exam;
  const _SheetHeader({required this.exam});

  @override
  Widget build(BuildContext context) {
    final shahr = GoogleFonts.scheherazadeNew();
    final amiri = GoogleFonts.amiri();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'نتائج الامتحان',
                style: shahr.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                exam.title,
                style: amiri.copyWith(
                  fontSize: 14,
                  color: AppColors.neutral500,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.midBlue.withAlpha(28),
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.bar_chart_rounded,
            color: AppColors.midBlue,
            size: 22,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loading state — skeleton placeholders + spinner
// ─────────────────────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    final amiri = GoogleFonts.amiri();

    return Column(
      children: [
        // Skeleton pass-rate bar
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surfaceAltDark,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(height: 12),
        // Skeleton stat boxes
        Row(
          children: List.generate(
            4,
            (i) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i == 3 ? 0 : 8),
                child: Container(
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAltDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        // Spinner + label
        const SizedBox(
          width: 28,
          height: 28,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.midBlue),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'جاري تحميل النتائج...',
          style: amiri.copyWith(fontSize: 14, color: AppColors.neutral500),
        ),
        const SizedBox(height: 40),
        // Skeleton result tiles
        ...List.generate(
          3,
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              height: 76,
              decoration: BoxDecoration(
                color: AppColors.surfaceAltDark.withAlpha(120),
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Error state — retry button
// ─────────────────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final shahr = GoogleFonts.scheherazadeNew();
    final amiri = GoogleFonts.amiri();
    // Empty message → fall back to a sane generic so the box never reads
    // blank. The translator should always supply something though.
    final detail = message.isNotEmpty
        ? message
        : 'تعذّر الاتصال بالخادم — حاول مرة أخرى';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 50),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.tomatoRed.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.tomatoRed,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'فشل تحميل النتائج',
              style: shahr.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                detail,
                textAlign: TextAlign.center,
                style: amiri.copyWith(
                  fontSize: 13,
                  color: AppColors.neutral500,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(
                'إعادة المحاولة',
                style: shahr.copyWith(fontSize: 14),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.midBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Loaded content — pass-rate bar + stat boxes + result tiles
// ─────────────────────────────────────────────────────────────────────────────

class _LoadedContent extends StatelessWidget {
  final List<ExamResult> results;
  final Map<String, String> namesMap;
  final Map<String, String> emailsMap;
  final double fullMark;
  final double passRate;
  final double avgScorePercent;
  final int passedCount;
  final int failedCount;
  final int totalUsers;

  const _LoadedContent({
    required this.results,
    required this.namesMap,
    required this.emailsMap,
    required this.fullMark,
    required this.passRate,
    required this.avgScorePercent,
    required this.passedCount,
    required this.failedCount,
    required this.totalUsers,
  });

  @override
  Widget build(BuildContext context) {
    final shahr = GoogleFonts.scheherazadeNew();
    final amiri = GoogleFonts.amiri();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Pass-rate progress bar ─────────────────────────────────────────
        _PassRateBar(passRate: passRate),
        const SizedBox(height: 12),

        // ── 4 Stat boxes ──────────────────────────────────────────────────
        Row(
          children: [
            _StatBox(
              icon: Icons.people_alt_outlined,
              iconColor: AppColors.midBlue,
              value: '$totalUsers',
              label: 'إجمالي\nالمتقدمين',
            ),
            const SizedBox(width: 8),
            _StatBox(
              icon: Icons.bar_chart_rounded,
              iconColor: AppColors.royalYellow,
              value: '${avgScorePercent.toStringAsFixed(1)}%',
              label: 'متوسط\nالدرجات',
            ),
            const SizedBox(width: 8),
            _StatBox(
              icon: Icons.cancel_outlined,
              iconColor: AppColors.tomatoRed,
              value: '$failedCount',
              label: 'راسبون',
            ),
            const SizedBox(width: 8),
            _StatBox(
              icon: Icons.check_circle_outline,
              iconColor: AppColors.pastelGreen,
              value: '$passedCount',
              label: 'ناجحون',
            ),
          ],
        ),

        const SizedBox(height: 24),

        // ── Section label + student count ─────────────────────────────────
        Row(
          children: [
            const Icon(
              Icons.people_alt_rounded,
              color: AppColors.neutral500,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'نتائج الطلاب',
              style: shahr.copyWith(
                fontSize: 18,
                color: AppColors.neutral300,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.surfaceAltDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$totalUsers طالب',
                style: amiri.copyWith(
                  fontSize: 13,
                  color: AppColors.neutral500,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // ── User tiles ─────────────────────────────────────────────────
        if (results.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: Center(
              child: Text(
                'لا توجد نتائج متاحة',
                style: shahr.copyWith(fontSize: 16, color: Colors.white60),
              ),
            ),
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: results.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (_, i) {
              final r = results[i];
              final name = namesMap[r.studentID] ?? 'طالب غير معروف';
              final email = emailsMap[r.studentID] ?? '';
              return _ExamResultTile(
                index: i + 1,
                result: r,
                userName: name,
                userEmail: email,
                totalMarks: fullMark,
              );
            },
          ),
      ],
    );
  }
}

// ─── Pass-rate bar ───────────────────────────────────────────────────────────

class _PassRateBar extends StatelessWidget {
  final double passRate;
  const _PassRateBar({required this.passRate});

  @override
  Widget build(BuildContext context) {
    final shahr = GoogleFonts.scheherazadeNew();
    final amiri = GoogleFonts.amiri();
    final progress = (passRate / 100).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAltDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 14,
                backgroundColor: AppColors.neutral800,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.pastelGreen,
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${passRate.toStringAsFixed(0)}%',
                style: shahr.copyWith(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.pastelGreen,
                  height: 1.1,
                ),
              ),
              Text(
                'نسبة النجاح',
                style: amiri.copyWith(
                  fontSize: 12,
                  color: AppColors.neutral500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Stat box ───────────────────────────────────────────────────────────────

class _StatBox extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatBox({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final amiri = GoogleFonts.amiri();

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
        decoration: BoxDecoration(
          color: AppColors.surfaceAltDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(height: 8),
            Text(
              value,
              style: amiri.copyWith(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: amiri.copyWith(
                fontSize: 11,
                color: AppColors.neutral500,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── User result tile ────────────────────────────────────────────────────

class _ExamResultTile extends StatelessWidget {
  final int index;
  final ExamResult result;
  final String userName;
  final String userEmail;
  final double totalMarks;

  const _ExamResultTile({
    required this.index,
    required this.result,
    required this.userName,
    required this.userEmail,
    required this.totalMarks,
  });

  @override
  Widget build(BuildContext context) {
    final shahr = GoogleFonts.scheherazadeNew();
    final amiri = GoogleFonts.amiri();

    final score = result.score ?? 0.0;
    final pct = totalMarks == 0 ? 0.0 : (score / totalMarks) * 100;
    final passed = pct >= 50;

    final Color accent = passed ? AppColors.pastelGreen : AppColors.tomatoRed;
    final Color bg = accent.withAlpha(18);
    final String initial = userName.trim().isNotEmpty
        ? userName.trim()[0]
        : '؟';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withAlpha(45), width: 1),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accent.withAlpha(35),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                initial,
                style: shahr.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: accent,
                  height: 1.5,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Name + email
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: shahr.copyWith(
                    fontSize: 17,
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (userEmail.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    userEmail,
                    style: amiri.copyWith(
                      fontSize: 12,
                      color: AppColors.neutral500,
                      height: 1.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Score + chips
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${score.toInt()} / ${totalMarks.toInt()}',
                style: shahr.copyWith(
                  fontSize: 15,
                  color: AppColors.textPrimaryDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _ResultChip(
                    label: '${pct.toStringAsFixed(0)}%',
                    color: accent,
                  ),
                  const SizedBox(width: 5),
                  _ResultChip(
                    label: passed ? 'ناجح' : 'راسب',
                    color: accent,
                    filled: true,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Small result chip ─────────────────────────────────────────────────────

class _ResultChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool filled;

  const _ResultChip({
    required this.label,
    required this.color,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
      decoration: BoxDecoration(
        color: filled ? color.withAlpha(55) : color.withAlpha(22),
        borderRadius: BorderRadius.circular(8),
        border: filled
            ? null
            : Border.all(color: color.withAlpha(60), width: 1),
      ),
      child: Text(
        label,
        style: GoogleFonts.amiri(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
