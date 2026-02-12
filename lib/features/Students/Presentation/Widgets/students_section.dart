import 'package:flutter/material.dart';
import 'package:mrmichaelashrafdashboard/features/students/data/models/user.dart';
import 'package:mrmichaelashrafdashboard/features/students/presentation/widgets/admin_studen_card.dart';

class StudentsSection extends StatelessWidget {
  final List<AppUser> students;

  const StudentsSection({super.key, required this.students});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = constraints.maxWidth < 600
            ? 1
            : constraints.maxWidth < 1000
            ? 2
            : constraints.maxWidth < 1400
            ? 3
            : 4;

        return GridView.builder(
          shrinkWrap: true,
          padding: const EdgeInsets.all(12),
          physics: const BouncingScrollPhysics(),
          itemCount: students.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            mainAxisExtent: 300,
          ),
          itemBuilder: (context, index) {
            final student = students[index];

            return AdminStudentCard(student: student);
          },
        );
      },
    );
  }
}
