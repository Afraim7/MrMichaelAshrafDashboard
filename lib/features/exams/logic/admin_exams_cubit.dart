import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mrmichaelashrafdashboard/core/config/app_strings.dart';
import 'package:mrmichaelashrafdashboard/core/enums/exam_status.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/exam.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/exam_result.dart';
import 'package:mrmichaelashrafdashboard/features/exams/logic/admin_exams_state.dart';
import 'package:mrmichaelashrafdashboard/features/students/data/models/user.dart';

class AdminExamsCubit extends Cubit<AdminExamsState> {
  AdminExamsCubit() : super(ExamsInitial());

  final FirebaseFirestore _firestoreRef = FirebaseFirestore.instance;

  Future<void> publishExam({required Exam exam}) async {
    try {
      emit(PublishingExam());
      await _firestoreRef.collection('exams').doc(exam.id).set(exam.toMap());
      emit(ExamPublished());
      await refreshExams();
    } catch (e) {
      emit(
        ExamsError(
          message: '${AppStrings.errors.examPublishFailed}: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> saveExamUpdates({required Exam exam}) async {
    try {
      emit(SavingExamUpdates());
      await _firestoreRef
          .collection('exams')
          .doc(exam.id)
          .set(exam.toMap(), SetOptions(merge: true));
      emit(ExamUpdatesSaved());
      await refreshExams();
    } catch (e) {
      emit(
        ExamsError(
          message: '${AppStrings.errors.courseUpdateFailed}: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> deleteExam({required String examId}) async {
    try {
      emit(DeletingExam());
      await _firestoreRef.collection('exams').doc(examId).delete();
      emit(ExamDeleted());
      await refreshExams();
    } catch (e) {
      emit(
        ExamsError(
          message: '${AppStrings.errors.examDeleteFailed}: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> fetchAllExams() async {
    try {
      emit(ExamsLoading());
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

      // Compute state dynamically for each exam
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

      emit(ExamsLoaded(exams: examsWithComputedState));
    } catch (e) {
      emit(
        ExamsError(
          message: '${AppStrings.errors.examLoadFailedAdmin}: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> fetchExamsByGrade(String gradeName) async {
    try {
      emit(ExamsLoading());
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

      final examsWithComputedState = exams.map((exam) {
        final computedState = exam.computeAdminExamState();
        return exam.copyWith(state: computedState);
      }).toList();

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

      emit(ExamsLoaded(exams: examsWithComputedState));
    } catch (e) {
      emit(
        ExamsError(
          message: '${AppStrings.errors.examLoadFailedAdmin}: ${e.toString()}',
        ),
      );
    }
  }

  // Count active exams
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
        ExamsError(
          message: '${AppStrings.errors.examLoadFailedAdmin}: ${e.toString()}',
        ),
      );
      return 0;
    }
  }

  Future<void> refreshExams() async {
    await fetchAllExams();
  }

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

  // Fetch student names (Helper for exam results display usually)
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
