import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/core/themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/exam.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/exam_result.dart';

/// ---------------------------------------------------------
/// MAIN WIDGET - ExamResultsSheet
/// ---------------------------------------------------------
class ExamResultsSheet extends StatelessWidget {
  final Exam exam;
  final List<ExamResult> results;
  final Map<String, String> studentNamesMap; // studentId -> studentName

  const ExamResultsSheet({
    super.key,
    required this.exam,
    required this.results,
    required this.studentNamesMap,
  });

  // Calculate total students and pass rate
  int get totalStudents => results.length;

  double get passRate {
    if (results.isEmpty) return 0.0;
    final totalMarks = exam.fullExamMark();
    if (totalMarks == 0) return 0.0;

    final passedCount = results.where((result) {
      final score = result.score ?? 0;
      final passingScore = totalMarks * 0.5; // 50% passing rate
      return score >= passingScore;
    }).length;

    return (passedCount / totalStudents) * 100;
  }

  @override
  Widget build(BuildContext context) {
    final shahr = GoogleFonts.scheherazadeNew();

    return Directionality(
      textDirection: TextDirection.rtl, // Arabic UI
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exam.title,
              style: shahr.copyWith(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                _SummaryBox(
                  title: "إجمالي الطلاب",
                  value: totalStudents.toString(),
                ),
                const SizedBox(width: 12),
                _SummaryBox(
                  title: "معدل النجاح",
                  value: "${passRate.toStringAsFixed(1)}%",
                ),
              ],
            ),

            const SizedBox(height: 50),

            Text(
              "نتائج الطلاب",
              style: shahr.copyWith(
                fontSize: 20,
                color: AppColors.neutral300,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            // Student Tiles List
            // ---------------------------
            results.isEmpty
                ? Center(
                    child: Text(
                      "لا توجد نتائج متاحة",
                      style: shahr.copyWith(
                        fontSize: 16,
                        color: Colors.white60,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: results.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (_, index) {
                      final item = results[index];
                      final studentName =
                          studentNamesMap[item.studentId] ?? "طالب غير معروف";
                      final totalMarks = exam.fullExamMark();
                      return _ExamResultTile(
                        index: index + 1,
                        result: item,
                        studentName: studentName,
                        totalMarks: totalMarks,
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

/// SUMMARY BOX
class _SummaryBox extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryBox({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final font = GoogleFonts.amiri();

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surfaceAltDark,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              title,
              style: font.copyWith(
                color: AppColors.neutral300,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: font.copyWith(
                color: AppColors.textPrimaryDark,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// STUDENT RESULT TILE
class _ExamResultTile extends StatelessWidget {
  final int index;
  final ExamResult result;
  final String studentName;
  final double totalMarks;

  const _ExamResultTile({
    required this.index,
    required this.result,
    required this.studentName,
    required this.totalMarks,
  });

  @override
  Widget build(BuildContext context) {
    final shahr = GoogleFonts.scheherazadeNew();
    final amiri = GoogleFonts.amiri();
    final score = result.score ?? 0.0;
    final percentage = totalMarks == 0 ? 0 : (score / totalMarks) * 100;
    Color tileColor;
    Color textColor;
    Color iconColor;
    IconData icon;

    if (percentage < 50) {
      // RED
      tileColor = AppColors.tomatoRed.withAlpha(26);
      textColor = AppColors.tomatoRed;
      iconColor = AppColors.tomatoRed;
      icon = Icons.cancel;
    } else if (percentage < 75) {
      // YELLOW
      tileColor = AppColors.royalYellow.withAlpha(26);
      textColor = AppColors.royalYellow;
      iconColor = AppColors.royalYellow;
      icon = Icons.error;
    } else {
      // GREEN
      tileColor = AppColors.lightGreen.withAlpha(26);
      textColor = AppColors.lightGreen;
      iconColor = AppColors.lightGreen;
      icon = Icons.check_circle;
    }

    final formattedDate = result.submittedAt != null
        ? "${result.submittedAt!.year}/${result.submittedAt!.month}/${result.submittedAt!.day} "
              "${result.submittedAt!.hour}:${result.submittedAt!.minute.toString().padLeft(2, '0')}"
        : "غير متاح";

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          /// Index
          Text(
            "$index . ",
            style: shahr.copyWith(color: AppColors.appWhite, fontSize: 18),
          ),

          const SizedBox(width: 14),

          /// Student info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: shahr.copyWith(
                    fontSize: 18,
                    color: AppColors.appWhite,
                    height: 2,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "تاريخ التسليم : $formattedDate",
                  style: amiri.copyWith(
                    fontSize: 14,
                    color: AppColors.neutral500,
                    height: 1.5,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),

          /// Score
          Text(
            "${score.toInt()} / ${totalMarks.toInt()}",
            style: shahr.copyWith(
              fontSize: 18,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),

          /// Status Icon
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Icon(icon, color: iconColor, size: 26),
          ),
        ],
      ),
    );
  }
}
