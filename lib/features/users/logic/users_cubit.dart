import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_strings.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/firebase_error_messages.dart';
import 'package:mrmichaelashrafdashboard/features/users/data/models/app_user.dart';
import 'package:mrmichaelashrafdashboard/features/users/logic/users_state.dart';

class UsersBreakdown {
  final int total;
  final int online;
  final int center;
  final int male;
  final int female;
  final int unverified;
  final int verified;

  const UsersBreakdown({
    required this.total,
    required this.online,
    required this.center,
    required this.male,
    required this.female,
    required this.unverified,
    required this.verified,
  });

  const UsersBreakdown.empty()
    : total = 0,
      online = 0,
      center = 0,
      male = 0,
      female = 0,
      unverified = 0,
      verified = 0;
}

class UsersCubit extends Cubit<UsersState> {
  UsersCubit() : super(const UsersInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> updateUserField({
    required String userID,
    required Map<String, dynamic> updates,
  }) async {
    if (updates.isEmpty) {
      emit(UpdateUserFieldSuccess(userId: userID, updates: updates));
      return true;
    }
    emit(const UpdateUserFieldLoading());
    try {
      await _firestore.collection('users').doc(userID).update(updates);
      emit(UpdateUserFieldSuccess(userId: userID, updates: updates));
      return true;
    } catch (e) {
      final translated = FirebaseErrorTranslator.translate(
        e,
        fallback: AppStrings.errors.studentsLoadFailed,
      );
      emit(UpdateUserFieldError(translated.message));
      return false;
    }
  }

  // ─── fetchUsersPage (Future-returning helper) ───────────────────────
  // The center owns its own page list + loading/error UI, so this returns
  // the slice directly and does not emit. Offset-emulation: pull
  // `page * pageSize` rows, drop the leading ones in memory.
  Future<List<AppUser>> fetchUsersPage({
    required int page,
    required int pageSize,
    String? gradeName,
  }) async {
    Query<Map<String, dynamic>> q = _firestore.collection('users');
    if (gradeName != null) {
      // Grade-filtered: skip the server-side orderBy so we don't need a
      // (grade + userName) COMPOSITE index. The page is sorted in memory
      // below. Without this, Firestore throws FAILED_PRECONDITION and the
      // center shows its error view.
      q = q.where('grade', isEqualTo: gradeName);
    } else {
      q = q.orderBy('userName');
    }
    final snap = await q.limit(page * pageSize).get();

    final allDocs = snap.docs;
    final skip = (page - 1) * pageSize;
    final pageDocs = skip >= allDocs.length
        ? const <QueryDocumentSnapshot<Map<String, dynamic>>>[]
        : allDocs.sublist(skip);

    final students = pageDocs
        .map((doc) {
          try {
            final data = doc.data();
            data['userID'] = doc.id;
            return AppUser.fromJson(data);
          } catch (_) {
            return null;
          }
        })
        .whereType<AppUser>()
        .toList();
    // Consistent display order regardless of which query path ran.
    students.sort((a, b) => a.userName.compareTo(b.userName));
    return students;
  }

  // ─── sendEmailVerificationLink ─────────────────────────────────────────
  /// Triggers an email-verification link for the student.
  ///
  /// NOTE: the Firebase client SDK can only send a verification email for the
  /// *currently signed-in* user — it cannot target an arbitrary account. The
  /// production path is an Admin-SDK Cloud Function exposing
  /// `generateEmailVerificationLink(email)` and mailing the result. Until that
  /// function ships, this simulates the round-trip so the action is wired
  /// end-to-end through the cubit's state lifecycle; swap the delay for the
  /// callable invocation when it lands.
  Future<void> sendEmailVerificationLink({required String userID}) async {
    emit(const SendEmailVerificationLinkLoading());
    try {
      await Future.delayed(const Duration(milliseconds: 600));
      emit(SendEmailVerificationLinkSuccess(userID));
    } catch (e) {
      final translated = FirebaseErrorTranslator.translate(
        e,
        fallback: 'تعذّر إرسال رابط التفعيل، حاول مجددًا',
      );
      emit(SendEmailVerificationLinkError(translated.message));
    }
  }

  // ─── Read helpers (no state emit) ──────────────────────────────────────

  Future<int> getUsersCount({String? gradeName}) async {
    Query<Map<String, dynamic>> q = _firestore.collection('users');
    if (gradeName != null) {
      q = q.where('grade', isEqualTo: gradeName);
    }
    final agg = await q.count().get();
    return agg.count ?? 0;
  }

  /// Bulk name + email lookup for a set of userIDs. Used by the course
  /// enrollments sheet to label its tiles. Returns two parallel maps so each
  /// tile resolves in O(1) without an extra round-trip per row. User data
  /// lives in the `users` collection — this is the right cubit to own it.
  Future<({Map<String, String> names, Map<String, String> emails})>
  fetchUsersBasicInfo(List<String> userIDs) async {
    if (userIDs.isEmpty) {
      return (names: <String, String>{}, emails: <String, String>{});
    }
    final docs = await Future.wait(
      userIDs.map((id) => _firestore.collection('users').doc(id).get()),
    );
    final names = <String, String>{};
    final emails = <String, String>{};
    for (var i = 0; i < userIDs.length; i++) {
      final data = docs[i].data();
      if (data != null) {
        names[userIDs[i]] = (data['userName'] ?? '') as String;
        emails[userIDs[i]] = (data['email'] ?? '') as String;
      }
    }
    return (names: names, emails: emails);
  }

  Future<AppUser?> fetchUserById(String userId) async {
    final snap = await _firestore.collection('users').doc(userId).get();
    if (!snap.exists) return null;
    final data = snap.data()!;
    data['userID'] = snap.id;
    return AppUser.fromJson(data);
  }

  Future<UsersBreakdown> getUsersBreakdown() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      var total = 0,
          online = 0,
          center = 0,
          male = 0,
          female = 0,
          unverified = 0;
      for (final doc in snapshot.docs) {
        total++;
        final data = doc.data();
        switch (data['studyType']) {
          case 'onlineStudent':
            online++;
          case 'centerStudent':
            center++;
        }
        switch (data['gender']) {
          case 'male':
            male++;
          case 'female':
            female++;
        }
        if (data['emailVerified'] != true) unverified++;
      }
      return UsersBreakdown(
        total: total,
        online: online,
        center: center,
        male: male,
        female: female,
        unverified: unverified,
        verified: total - unverified,
      );
    } catch (_) {
      return const UsersBreakdown.empty();
    }
  }
}
