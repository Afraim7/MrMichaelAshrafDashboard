import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/gender.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/government.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/grade.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/stage.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/study_type.dart';
import 'package:mrmichaelashrafdashboard/Core/Themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/Shared/Components/meta_row_badge.dart';
import 'package:mrmichaelashrafdashboard/Features/Students/Data/Models/user.dart';

class AdminStudentCard extends StatefulWidget {
  final AppUser student;

  const AdminStudentCard({super.key, required this.student});

  @override
  State<AdminStudentCard> createState() => _AdminStudentCardState();
}

class _AdminStudentCardState extends State<AdminStudentCard> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => _showStudentDetailsDialog(context),
        child: AnimatedScale(
          scale: isHovered ? 1.02 : 1.0,
          duration: const Duration(milliseconds: 160),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.bgDark,
              borderRadius: BorderRadius.circular(35),
              border: Border.all(color: AppColors.neutral900, width: 1.2),
              boxShadow: isHovered
                  ? [
                      BoxShadow(
                        color: AppColors.midBlue.withAlpha(90),
                        blurRadius: 15,
                        spreadRadius: 0,
                        offset: const Offset(0, 0),
                      ),
                    ]
                  : [],
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------- TOP ROW ----------
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.appNavy,
                        shape: BoxShape.circle,
                      ),
                      child: widget.student.setProfileIcon.isNotEmpty
                          ? ClipOval(
                              child: Image.asset(
                                widget.student.setProfileIcon,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.person_outline,
                              color: AppColors.royalYellow,
                              size: 28,
                            ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // NAME
                          Text(
                            widget.student.userName,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 2,
                            ),
                          ),

                          // GRADE
                          Text(
                            widget.student.grade.label,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: Colors.white54,
                              height: 1.4,
                            ),
                          ),

                          const SizedBox(height: 25),

                          // EMAIL
                          MetaRowBadge(
                            icon: Icons.email_outlined,
                            data: widget.student.email,
                          ),

                          // PHONE
                          MetaRowBadge(
                            icon: Icons.phone_android_rounded,
                            data: widget.student.phone,
                          ),

                          // Parent Phone
                          MetaRowBadge(
                            icon: Icons.phone,
                            data: widget.student.parentPhone,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // ---------- DIVIDER ----------
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Divider(
                    indent: 20,
                    endIndent: 20,
                    height: 0.7,
                    color: const Color.fromARGB(16, 255, 255, 255),
                  ),
                ),

                // ---------- COUNTERS ----------
                rowCounter(
                  title: "الكورسات المسجله",
                  count: widget.student.enrolledCoursesCount.toString(),
                  color: AppColors.midBlue,
                ),

                const SizedBox(height: 10),

                rowCounter(
                  title: "الآمتحانات",
                  count: widget.student.takenExamsCount.toString(),
                  color: AppColors.pastelYellow,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------- COUNTER ROW ----------
  Widget rowCounter({
    required String title,
    required String count,
    required Color color,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.scheherazadeNew(
            fontSize: 16,
            color: AppColors.appWhite,
            fontWeight: FontWeight.w500,
            height: 1.5,
          ),
        ),
        const Spacer(),
        Container(
          height: 35,
          width: 35,
          decoration: BoxDecoration(
            color: color.withAlpha(51),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              count,
              style: GoogleFonts.scheherazadeNew(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showStudentDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          decoration: BoxDecoration(
            color: AppColors.bgDark,
            borderRadius: BorderRadius.circular(35),
            border: Border.all(color: AppColors.neutral900, width: 1.2),
          ),
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'معلومات الطالب',
                      style: GoogleFonts.scheherazadeNew(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        height: 2,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.of(dialogContext).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Top section (same as card)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.appNavy,
                        shape: BoxShape.circle,
                      ),
                      child: widget.student.setProfileIcon.isNotEmpty
                          ? ClipOval(
                              child: Image.asset(
                                widget.student.setProfileIcon,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.person_outline,
                              color: AppColors.royalYellow,
                              size: 28,
                            ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.student.userName,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              height: 2,
                            ),
                          ),
                          Text(
                            widget.student.grade.label,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: Colors.white54,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 25),
                          MetaRowBadge(
                            icon: Icons.email_outlined,
                            data: widget.student.email,
                          ),
                          MetaRowBadge(
                            icon: Icons.phone_android_rounded,
                            data: widget.student.phone,
                          ),
                          MetaRowBadge(
                            icon: Icons.phone,
                            data: widget.student.parentPhone,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // All other info in column starting from parent phone
                const SizedBox(height: 30),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MetaRowBadge(
                      icon: Icons.person,
                      data: widget.student.gender.label,
                    ),
                    const SizedBox(height: 10),
                    MetaRowBadge(
                      icon: Icons.location_on,
                      data: widget.student.state.label,
                    ),
                    const SizedBox(height: 10),
                    MetaRowBadge(
                      icon: Icons.school,
                      data: widget.student.stage.label,
                    ),
                    const SizedBox(height: 10),
                    MetaRowBadge(
                      icon: Icons.verified,
                      data: widget.student.emailVerified == true
                          ? 'الآيميل مؤكد'
                          : 'غير مؤكد',
                    ),
                    const SizedBox(height: 10),
                    MetaRowBadge(
                      icon: Icons.featured_play_list,
                      data: widget.student.studyType.label,
                    ),
                  ],
                ),
                // Divider
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Divider(
                    indent: 20,
                    endIndent: 20,
                    height: 0.7,
                    color: const Color.fromARGB(16, 255, 255, 255),
                  ),
                ),
                // Counters
                rowCounter(
                  title: "الكورسات المسجله",
                  count: widget.student.enrolledCoursesCount.toString(),
                  color: AppColors.midBlue,
                ),
                const SizedBox(height: 10),
                rowCounter(
                  title: "الآمتحانات",
                  count: widget.student.takenExamsCount.toString(),
                  color: AppColors.pastelYellow,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
