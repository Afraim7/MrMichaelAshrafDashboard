import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mrmichaelashrafdashboard/core/config/app_strings.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course.dart';
import 'package:mrmichaelashrafdashboard/features/courses/logic/admin_courses_state.dart';

class AdminCoursesCubit extends Cubit<AdminCoursesState> {
  AdminCoursesCubit() : super(CoursesInitial());

  final FirebaseFirestore _firestoreRef = FirebaseFirestore.instance;

  Stream<List<Course>> fetchAllCoursesStream() {
    try {
      emit(CoursesLoading());
      return _firestoreRef.collection('courses').snapshots().map((snapshot) {
        final courses = snapshot.docs
            .map((doc) {
              try {
                final data = doc.data();
                data['courseID'] = doc.id;
                return Course.fromMap(data);
              } catch (e) {
                return null;
              }
            })
            .where((course) => course != null)
            .cast<Course>()
            .toList();
        courses.sort((a, b) => b.startDate.compareTo(a.startDate));
        return courses;
      });
    } catch (e) {
      emit(
        CoursesError('${AppStrings.errors.courseLoadFailed}: ${e.toString()}'),
      );
      return Stream.value([]);
    }
  }

  Future<void> fetchAllCourses() async {
    try {
      emit(CoursesLoading());
      final snapshot = await _firestoreRef.collection('courses').get();
      final courses = snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              data['courseID'] = doc.id;
              return Course.fromMap(data);
            } catch (e) {
              return null;
            }
          })
          .where((course) => course != null)
          .cast<Course>()
          .toList();
      courses.sort((a, b) => b.startDate.compareTo(a.startDate));
      emit(CoursesLoaded(courses));
    } catch (e) {
      emit(
        CoursesError('${AppStrings.errors.courseLoadFailed}: ${e.toString()}'),
      );
    }
  }

  Future<void> fetchCoursesByGrade(String gradeName) async {
    try {
      emit(CoursesLoading());
      final snapshot = await _firestoreRef
          .collection('courses')
          .where('grade', isEqualTo: gradeName)
          .get();

      final courses = snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              data['courseID'] = doc.id;
              return Course.fromMap(data);
            } catch (e) {
              return null;
            }
          })
          .where((course) => course != null)
          .cast<Course>()
          .toList();
      courses.sort((a, b) => b.startDate.compareTo(a.startDate));
      emit(CoursesLoaded(courses));
    } catch (e) {
      emit(
        CoursesError('${AppStrings.errors.courseLoadFailed}: ${e.toString()}'),
      );
    }
  }

  Future<void> publishCourse({required Course course}) async {
    try {
      emit(PublishingCourse());
      await _firestoreRef
          .collection('courses')
          .doc(course.courseID)
          .set(course.toMap());
      emit(CoursePublished());
      await refreshCourses();
    } catch (e) {
      emit(
        CoursesError(
          '${AppStrings.errors.coursePublishFailed}: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> deleteCourse({required String courseId}) async {
    try {
      emit(DeletingCourse());
      await _firestoreRef.collection('courses').doc(courseId).delete();
      emit(CourseDeleted());
      await refreshCourses();
    } catch (e) {
      emit(
        CoursesError(
          '${AppStrings.errors.courseDeleteFailed}: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> saveCourseUpdates({required Course course}) async {
    try {
      emit(SavingCourseUpdates());
      await _firestoreRef
          .collection('courses')
          .doc(course.courseID)
          .set(course.toMap(), SetOptions(merge: true));
      emit(CourseUpdatesSaved());
      await refreshCourses();
    } catch (e) {
      emit(
        CoursesError(
          '${AppStrings.errors.courseUpdateFailed}: ${e.toString()}',
        ),
      );
    }
  }

  Future<int> getAllCoursesCount() async {
    try {
      final snapshot = await _firestoreRef.collection('courses').get();
      return snapshot.docs.length;
    } catch (e) {
      emit(
        CoursesError('${AppStrings.errors.courseLoadFailed}: ${e.toString()}'),
      );
      return 0;
    }
  }

  Future<void> refreshCourses() async {
    await fetchAllCourses();
  }
}
