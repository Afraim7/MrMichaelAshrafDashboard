import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mrmichaelashrafdashboard/Shared/Models/admin.dart';

part 'admin_auth_state.dart';

class AdminAuthCubit extends Cubit<AdminAuthState> {
  AdminAuthCubit() : super(AdminAuthInitial()) {
    _auth.authStateChanges().listen((user) async {
      if (user == null) {
        emit(AdminUnauthenticated());
        return;
      }

      final snap = await _firestore.collection("admins").doc(user.uid).get();

      if (!snap.exists) {
        emit(AdminUnauthenticated());
        return;
      }

      final admin = Admin.fromMap(snap.data()!);
      emit(AdminAuthenticated(admin: admin, isFreshLogin: false));
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // CHECK ADMIN STATUS
  // ─────────────────────────────
  Future<void> checkAdminStatus() async {
    final user = _auth.currentUser;

    if (user == null) {
      emit(AdminUnauthenticated());
      return;
    }

    final snap = await _firestore.collection("admins").doc(user.uid).get();

    if (!snap.exists) {
      emit(AdminUnauthenticated());
      return;
    }

    final admin = Admin.fromMap(snap.data()!);
    emit(AdminAuthenticated(admin: admin, isFreshLogin: false));
  }

  // ADMIN LOGIN
  // ─────────────────────────────
  Future<void> adminLogin({
    required String email,
    required String password,
  }) async {
    try {
      emit(AdminLoggingIn());

      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final fbUser = cred.user;
      if (fbUser == null) {
        emit(AdminError(error: "تعذّر تسجيل الدخول."));
        return;
      }

      // Load from admins collection
      final snap = await _firestore.collection("admins").doc(fbUser.uid).get();

      if (!snap.exists) {
        emit(AdminError(error: "هذا الحساب ليس حساب مسؤول."));
        return;
      }

      final admin = Admin.fromMap(snap.data()!);
      emit(AdminAuthenticated(admin: admin, isFreshLogin: true));
    } catch (e) {
      emit(AdminError(error: "حدث خطأ أثناء تسجيل الدخول."));
    }
  }

  // LOGOUT
  // ─────────────────────────────
  Future<void> adminLogout() async {
    emit(AdminLoggingOut());
    await _auth.signOut();
    emit(AdminUnauthenticated());
  }
}
