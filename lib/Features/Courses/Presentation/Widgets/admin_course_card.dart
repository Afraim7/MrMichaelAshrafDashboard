import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mrmichaelashrafdashboard/Core/Config/app_radii.dart';
import 'package:mrmichaelashrafdashboard/Core/Themes/app_colors.dart';
import 'package:mrmichaelashrafdashboard/Core/Config/app_assets.dart';
import 'package:mrmichaelashrafdashboard/Shared/Components/meta_row_badge.dart';

class AdminCourseCard extends StatefulWidget {
  final String title;
  final String describtion;
  final int numberOfLessons;
  final String grade;
  final int studentsCount;
  final String? imageUrl;
  final VoidCallback? onTap;
  final double price;

  const AdminCourseCard({
    super.key,
    required this.title,
    required this.describtion,
    required this.grade,
    required this.studentsCount,
    this.imageUrl,
    this.onTap,
    required this.numberOfLessons,
    required this.price,
  });

  @override
  State<AdminCourseCard> createState() => _AdminCourseCardState();
}

class _AdminCourseCardState extends State<AdminCourseCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: AppRadii.xxxl,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 250),
          scale: _isHovered ? 1.02 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(35),
              color: AppColors.surfaceDark,
              border: Border.all(color: AppColors.neutral900, width: 1.2),
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: AppColors.midBlue.withAlpha(90),
                        blurRadius: 15,
                        spreadRadius: 0,
                        offset: const Offset(0, 0),
                      ),
                    ]
                  : null,
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(35)),
                  child: Image.asset(
                    AppAssets.images.courseDefault,
                    fit: BoxFit.cover,
                    height: 200,
                    width: double.infinity,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        widget.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.scheherazadeNew(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.appWhite,
                          height: 2,
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        widget.describtion,
                        maxLines: 2,
                        style: GoogleFonts.scheherazadeNew(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: AppColors.neutral600,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 10),

                      MetaRowBadge(
                        icon: Icons.menu_book_outlined,
                        data: '${widget.numberOfLessons} دروس',
                      ),

                      const SizedBox(height: 10),

                      // Grade + Students
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 25,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.royalBlue.withAlpha(80),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Text(
                                widget.grade,
                                style: GoogleFonts.amiri(
                                  color: AppColors.appWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),

                          Spacer(),

                          Flexible(
                            child: MetaRowBadge(
                              icon: Icons.group_rounded,
                              data: '${widget.studentsCount}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
