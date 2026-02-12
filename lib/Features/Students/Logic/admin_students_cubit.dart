import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mrmichaelashrafdashboard/core/config/app_strings.dart';
import 'package:mrmichaelashrafdashboard/features/students/data/models/user.dart';
import 'package:mrmichaelashrafdashboard/features/students/logic/admin_students_state.dart';

class AdminStudentsCubit extends Cubit<AdminStudentsState> {
  AdminStudentsCubit() : super(StudentsInitial());

  final FirebaseFirestore _firestoreRef = FirebaseFirestore.instance;

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
        StudentsError(
          '${AppStrings.errors.studentsLoadFailed}: ${e.toString()}',
        ),
      );
      return Stream.value([]);
    }
  }

  Future<void> fetchAllStudents() async {
    try {
      emit(StudentsLoading());
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
      emit(StudentsLoaded(students));
    } catch (e) {
      emit(
        StudentsError(
          '${AppStrings.errors.studentsLoadFailed}: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> fetchStudentsByGrade(String gradeName) async {
    try {
      emit(StudentsLoading());
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
      emit(StudentsLoaded(students));
    } catch (e) {
      emit(
        StudentsError(
          '${AppStrings.errors.studentsLoadFailed}: ${e.toString()}',
        ),
      );
    }
  }

  Future<int> getAllStudentsCount() async {
    try {
      final snapshot = await _firestoreRef.collection('users').get();
      return snapshot.docs.length;
    } catch (e) {
      emit(
        StudentsError(
          '${AppStrings.errors.studentsLoadFailed}: ${e.toString()}',
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
        StudentsError(
          '${AppStrings.errors.studentsLoadFailed}: ${e.toString()}',
        ),
      );
      return 0;
    }
  }

  Future<void> refreshStudents() async {
    await fetchAllStudents();
  }
}
