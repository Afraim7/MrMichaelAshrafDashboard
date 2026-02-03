import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:mrmichaelashrafdashboard/Core/Config/app_strings.dart';
import 'package:mrmichaelashrafdashboard/Core/Enums/exam_status.dart';
import 'package:mrmichaelashrafdashboard/Features/Courses/Data/Models/course.dart';
import 'package:mrmichaelashrafdashboard/Features/Exams/Data/Models/exam.dart';
import 'package:mrmichaelashrafdashboard/Features/Exams/Data/Models/exam_result.dart';
import 'package:mrmichaelashrafdashboard/Features/Highlights/Data/Models/highlight.dart';
import 'package:mrmichaelashrafdashboard/Features/Students/Data/Models/user.dart';
part 'admin_functions_state.dart';

class AdminFunctionsCubit extends Cubit<AdminFunctionsState> {
  AdminFunctionsCubit() : super(AdminFunctionsInitial());

  final FirebaseFirestore _firestoreRef = FirebaseFirestore.instance;

  // COURSES METHODS -----------------------------------------------------------
  Stream<List<Course>> fetchAllCoursesStream() {
    try {
      emit(AdminLoadingCourses());
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
        AdminFunctionsError(
          error: '${AppStrings.errors.courseLoadFailed}: ${e.toString()}',
        ),
      );
      return Stream.value([]);
    }
  }

  Future<void> fetchAllCourses() async {
    try {
      emit(AdminLoadingCourses());
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
      emit(AdminCoursesLoaded(courses: courses));
    } catch (e) {
      emit(
        AdminFunctionsError(
          error: '${AppStrings.errors.courseLoadFailed}: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> fetchCoursesByGrade(String gradeName) async {
    try {
      emit(AdminLoadingCourses());
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
      emit(AdminCoursesLoaded(courses: courses));
    } catch (e) {
      emit(
        AdminFunctionsError(
          error: '${AppStrings.errors.courseLoadFailed}: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> publishCourse({required Course course}) async {
    try {
      emit(AdminPublishingCourse());
      await _firestoreRef
          .collection('courses')
          .doc(course.courseID)
          .set(course.toMap());
      emit(AdminCoursePublished());
      await refreshCourses();
    } catch (e) {
      emit(
        AdminFunctionsError(
          error: '${AppStrings.errors.coursePublishFailed}: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> deleteCourse({required String courseId}) async {
    try {
      emit(AdminDeletingCourse());
      await _firestoreRef.collection('courses').doc(courseId).delete();
      emit(AdminCourseDeleted());
      await refreshCourses();
    } catch (e) {
      emit(
        AdminFunctionsError(
          error: '${AppStrings.errors.courseDeleteFailed}: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> saveCourseUpdates({required Course course}) async {
    try {
      emit(AdminSavingCourseUpdates());
      await _firestoreRef
          .collection('courses')
          .doc(course.courseID)
          .set(course.toMap(), SetOptions(merge: true));
      emit(AdminCourseUpdatesSaved());
      await refreshCourses();
    } catch (e) {
      emit(
        AdminFunctionsError(
          error: '${AppStrings.errors.courseUpdateFailed}: ${e.toString()}',
        ),
      );
    }
  }

  // HIGHLIGHTS METHODS --------------------------------------------------------
  Future<void> publishHighlight({
    required String highlightText,
    required String grade,
    required String type,
    required Timestamp startDate,
    required Timestamp endDate,
  }) async {
    try {
      emit(AdminPublishingHighlight());
      final highlightId = _firestoreRef.collection('highlights').doc().id;
      await _firestoreRef.collection('highlights').doc(highlightId).set({
        'id': highlightId,
        'message': highlightText,
        'grade': grade,
        'type': type,
        'startDate': startDate,
        'endDate': endDate,
      });
      emit(AdminHighlightPublished());
      await fetchAllHighlights();
    } catch (e) {
      emit(
        AdminFunctionsError(
          error: '${AppStrings.errors.highlightPublishFailed}: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> fetchAllHighlights() async {
    try {
      emit(AdminLoadingHighlights());
      final snapshot = await _firestoreRef.collection('highlights').get();
      final highlights = snapshot.docs.map((doc) {
        return Highlight.fromJson(doc.data(), id: doc.id);
      }).toList();
      highlights.sort((a, b) {
        final aStart = a.startTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bStart = b.startTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bStart.compareTo(aStart);
      });
      emit(AdminHighlightsLoaded(highlights: highlights));
    } catch (e) {
      emit(AdminFunctionsError(error: AppStrings.errors.notesLoadFailed));
    }
  }

  Future<void> deleteHighlight(String highlightId) async {
    try {
      emit(AdminDeletingHighlight());
      await _firestoreRef.collection('highlights').doc(highlightId).delete();
      emit(AdminHighlightDeleted());
      await fetchAllHighlights();
    } catch (e) {
      emit(AdminFunctionsError(error: AppStrings.errors.highlightDeleteFailed));
    }
  }

  Future<void> saveHighlightUpdates({
    required String highlightId,
    required String highlightText,
    required String grade,
    required String type,
    required Timestamp startDate,
    required Timestamp endDate,
  }) async {
    try {
      emit(AdminSavingHighlightUpdates());
      await _firestoreRef.collection('highlights').doc(highlightId).set({
        'id': highlightId,
        'message': highlightText,
        'grade': grade,
        'type': type,
        'startDate': startDate,
        'endDate': endDate,
      }, SetOptions(merge: true));
      emit(AdminHighlightUpdatesSaved());
      await fetchAllHighlights();
    } catch (e) {
      emit(
        AdminFunctionsError(
          error: '${AppStrings.errors.highlightPublishFailed}: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> fetchHighlightsByGrade(String gradeName) async {
    try {
      emit(AdminLoadingHighlights());
      final snapshot = await _firestoreRef
          .collection('highlights')
          .where('grade', isEqualTo: gradeName)
          .get();

      final highlights = snapshot.docs.map((doc) {
        return Highlight.fromJson(doc.data(), id: doc.id);
      }).toList();

      highlights.sort((a, b) {
        final aStart = a.startTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bStart = b.startTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bStart.compareTo(aStart);
      });

      emit(AdminHighlightsLoaded(highlights: highlights));
    } catch (e) {
      emit(
        AdminFunctionsError(
          error: '${AppStrings.errors.notesLoadFailed}: ${e.toString()}',
        ),
      );
    }
  }

  // EXAM METHODS --------------------------------------------------------------
  Future<void> publishExam({required Exam exam}) async {
    try {
      emit(AdminPublishingExam());
      await _firestoreRef.collection('exams').doc(exam.id).set(exam.toMap());
      emit(AdminExamPublished());
      await refreshExams();
    } catch (e) {
      emit(
        AdminFunctionsError(
          error: '${AppStrings.errors.examPublishFailed}: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> saveExamUpdates({required Exam exam}) async {
    try {
      emit(AdminSavingExamUpdates());
      await _firestoreRef
          .collection('exams')
          .doc(exam.id)
          .set(exam.toMap(), SetOptions(merge: true));
      emit(AdminExamUpdatesSaved());
      await refreshExams();
    } catch (e) {
      emit(
        AdminFunctionsError(
          error: '${AppStrings.errors.courseUpdateFailed}: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> deleteExam({required String examId}) async {
    try {
      emit(AdminDeletingExam());
      await _firestoreRef.collection('exams').doc(examId).delete();
      emit(AdminExamDeleted());
      await refreshExams();
    } catch (e) {
      emit(
        AdminFunctionsError(
          error: '${AppStrings.errors.examDeleteFailed}: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> fetchAllExams() async {
    try {
      emit(AdminLoadingExams());
      final snapshot = await _firestoreRef.collection('exams').get();
      final exams = snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              data['id'] = doc.id; // Ensure id is set from document ID
              return Exam.fromMap(data);
            } catch (e) {
              return null;
            }
          })
          .where((exam) => exam != null)
          .cast<Exam>()
          .toList();

      // Compute state dynamically for each exam (admin view doesn't check student results)
      final examsWithComputedState = exams.map((exam) {
        final computedState = exam.computeAdminExamState();
        return exam.copyWith(state: computedState);
      }).toList();

      // Sort by startTime (most recent first), or by title if no startTime
      examsWithComputedState.sort((a, b) {
        if (a.startTime != null && b.startTime != null) {
          return b.startTime!.compareTo(a.startTime!);
        } else if (a.startTime != null) {
          return -1;
        } else if (b.startTime != null) {
          return 1;
        } else {
          return a.title.compareTo(b.title);
        }
      });

      emit(AdminExamsLoaded(exams: examsWithComputedState));
    } catch (e) {
      emit(
        AdminFunctionsError(
          error: '${AppStrings.errors.examLoadFailedAdmin}: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> fetchExamsByGrade(String gradeName) async {
    try {
      emit(AdminLoadingExams());
      final snapshot = await _firestoreRef
          .collection('exams')
          .where('grade', isEqualTo: gradeName)
          .get();

      final exams = snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              data['id'] = doc.id;
              return Exam.fromMap(data);
            } catch (e) {
              return null;
            }
          })
          .where((exam) => exam != null)
          .cast<Exam>()
          .toList();

      // Compute state dynamically for each exam (admin view doesn't check student results)
      final examsWithComputedState = exams.map((exam) {
        final computedState = exam.computeAdminExamState();
        return exam.copyWith(state: computedState);
      }).toList();

      // Sort by startTime (most recent first), or by title if no startTime
      examsWithComputedState.sort((a, b) {
        if (a.startTime != null && b.startTime != null) {
          return b.startTime!.compareTo(a.startTime!);
        } else if (a.startTime != null) {
          return -1;
        } else if (b.startTime != null) {
          return 1;
        } else {
          return a.title.compareTo(b.title);
        }
      });

      emit(AdminExamsLoaded(exams: examsWithComputedState));
    } catch (e) {
      emit(
        AdminFunctionsError(
          error: '${AppStrings.errors.examLoadFailedAdmin}: ${e.toString()}',
        ),
      );
    }
  }

  // STUDENTS METHODS ----------------------------------------------------------
  Stream<List<AppUser>> fetchAllStudentsStream() {
    try {
      return _firestoreRef.collection('users').snapshots().map((snapshot) {
        final students = snapshot.docs
            .map((doc) {
              try {
                final data = doc.data();
                data['userID'] = doc.id;
                return AppUser.fromMap(data);
              } catch (e) {
                return null;
              }
            })
            .where((student) => student != null)
            .cast<AppUser>()
            .toList();
        // Sort by userName alphabetically
        students.sort((a, b) => a.userName.compareTo(b.userName));
        return students;
      });
    } catch (e) {
      emit(
        AdminFunctionsError(
          error: '${AppStrings.errors.studentsLoadFailed}: ${e.toString()}',
        ),
      );
      return Stream.value([]);
    }
  }

  Future<void> fetchAllStudents() async {
    try {
      emit(AdminLoadingStudents());
      final snapshot = await _firestoreRef.collection('users').get();

      final students = snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              data['userID'] = doc.id;
              return AppUser.fromMap(data);
            } catch (e) {
              return null;
            }
          })
          .where((student) => student != null)
          .cast<AppUser>()
          .toList();
      students.sort((a, b) => a.userName.compareTo(b.userName));
      emit(AdminStudentsLoaded(students: students));
    } catch (e) {
      emit(
        AdminFunctionsError(
          error: '${AppStrings.errors.studentsLoadFailed}: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> fetchStudentsByGrade(String gradeName) async {
    try {
      emit(AdminLoadingStudents());
      final snapshot = await _firestoreRef
          .collection('users')
          .where('grade', isEqualTo: gradeName)
          .get();

      final students = snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              data['userID'] = doc.id;
              return AppUser.fromMap(data);
            } catch (e) {
              return null;
            }
          })
          .where((student) => student != null)
          .cast<AppUser>()
          .toList();

      students.sort((a, b) => a.userName.compareTo(b.userName));
      emit(AdminStudentsLoaded(students: students));
    } catch (e) {
      emit(
        AdminFunctionsError(
          error: '${AppStrings.errors.studentsLoadFailed}: ${e.toString()}',
        ),
      );
    }
  }

  // COUNT METHODS -----------------------------------------------------------
  /// Get total count of all courses in Firestore
  Future<int> getAllCoursesCount() async {
    try {
      final snapshot = await _firestoreRef.collection('courses').get();
      return snapshot.docs.length;
    } catch (e) {
      emit(
        AdminFunctionsError(
          error: '${AppStrings.errors.courseLoadFailed}: ${e.toString()}',
        ),
      );
      return 0;
    }
  }

  /// Get count of all active exams
  Future<int> getActiveExamsCount() async {
    try {
      final snapshot = await _firestoreRef.collection('exams').get();
      final exams = snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              data['id'] = doc.id;
              return Exam.fromMap(data);
            } catch (e) {
              return null;
            }
          })
          .where((exam) => exam != null)
          .cast<Exam>()
          .toList();

      final activeExams = exams.where((exam) {
        final state = exam.computeAdminExamState();
        return state == ExamStatus.active;
      }).toList();

      return activeExams.length;
    } catch (e) {
      emit(
        AdminFunctionsError(
          error: '${AppStrings.errors.examLoadFailedAdmin}: ${e.toString()}',
        ),
      );
      return 0;
    }
  }

  /// Get count of all active highlights
  Future<int> getActiveHighlightsCount() async {
    try {
      final snapshot = await _firestoreRef.collection('highlights').get();
      final highlights = snapshot.docs
          .map((doc) {
            try {
              return Highlight.fromJson(doc.data(), id: doc.id);
            } catch (e) {
              return null;
            }
          })
          .where((highlight) => highlight != null)
          .cast<Highlight>()
          .toList();

      final now = DateTime.now();
      final activeHighlights = highlights.where((highlight) {
        final start =
            highlight.startTime ?? DateTime(now.year, now.month, now.day);
        final end =
            highlight.endTime ??
            DateTime(now.year, now.month, now.day, 23, 59, 59);
        final isActive = !now.isBefore(start) && !now.isAfter(end);
        return isActive;
      }).toList();

      return activeHighlights.length;
    } catch (e) {
      emit(
        AdminFunctionsError(
          error: '${AppStrings.errors.notesLoadFailed}: ${e.toString()}',
        ),
      );
      return 0;
    }
  }

  /// Get total count of all students in Firestore
  Future<int> getAllStudentsCount() async {
    try {
      final snapshot = await _firestoreRef.collection('users').get();
      return snapshot.docs.length;
    } catch (e) {
      emit(
        AdminFunctionsError(
          error: '${AppStrings.errors.studentsLoadFailed}: ${e.toString()}',
        ),
      );
      return 0;
    }
  }

  Future<int> getVerifiedStudentsCount() async {
    try {
      final snapshot = await _firestoreRef
          .collection('users')
          .where('emailVerified', isEqualTo: true)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      emit(
        AdminFunctionsError(
          error: '${AppStrings.errors.studentsLoadFailed}: ${e.toString()}',
        ),
      );
      return 0;
    }
  }

  // REFRESH METHODS -----------------------------------------------------------
  Future<void> refreshCourses() async {
    await fetchAllCourses();
  }

  Future<void> refreshExams() async {
    await fetchAllExams();
  }

  Future<void> refreshStudents() async {
    await fetchAllStudents();
  }

  Future<void> refreshHighlights() async {
    await fetchAllHighlights();
  }

  // Fetch all exam results for a specific exam
  Future<List<ExamResult>> fetchExamResults(String examId) async {
    try {
      final snapshot = await _firestoreRef
          .collection('exams')
          .doc(examId)
          .collection('results')
          .get();

      final results = snapshot.docs
          .map((doc) {
            try {
              final data = doc.data();
              data['id'] = doc.id;
              data['submittedAt'] = data['submittedAt'] is Timestamp
                  ? (data['submittedAt'] as Timestamp).millisecondsSinceEpoch
                  : data['submittedAt'];
              return ExamResult.fromMap({
                ...data,
                'examId': examId,
                'studentId': doc.id,
              });
            } catch (e) {
              return null;
            }
          })
          .where((result) => result != null)
          .cast<ExamResult>()
          .toList();

      // Sort by submittedAt (most recent first), or by score if no submittedAt
      results.sort((a, b) {
        if (a.submittedAt != null && b.submittedAt != null) {
          return b.submittedAt!.compareTo(a.submittedAt!);
        } else if (a.submittedAt != null) {
          return -1;
        } else if (b.submittedAt != null) {
          return 1;
        } else {
          final aScore = a.score ?? 0;
          final bScore = b.score ?? 0;
          return bScore.compareTo(aScore);
        }
      });

      return results;
    } catch (e) {
      return [];
    }
  }

  // Fetch student names for given student IDs
  Future<Map<String, String>> fetchStudentNames(List<String> studentIds) async {
    try {
      if (studentIds.isEmpty) return {};

      final futures = studentIds
          .map((id) => _firestoreRef.collection('users').doc(id).get())
          .toList();

      final docs = await Future.wait(futures);
      final namesMap = <String, String>{};

      for (var i = 0; i < studentIds.length; i++) {
        if (docs[i].exists && docs[i].data() != null) {
          try {
            final data = docs[i].data()!;
            data['userID'] = docs[i].id; // Ensure userID is set
            final user = AppUser.fromMap(data);
            namesMap[studentIds[i]] = user.userName;
          } catch (_) {
            namesMap[studentIds[i]] = "طالب غير معروف";
          }
        } else {
          namesMap[studentIds[i]] = "طالب غير معروف";
        }
      }

      return namesMap;
    } catch (e) {
      return {};
    }
  }
}
