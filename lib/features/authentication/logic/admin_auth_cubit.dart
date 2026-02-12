import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mrmichaelashrafdashboard/features/authentication/data/models/admin.dart';

part 'admin_auth_state.dart';

class AdminAuthCubit extends Cubit<AdminAuthState> {
  AdminAuthCubit() : super(AdminAuthInitial()) {
    _authSubscription = _auth.authStateChanges().listen((user) async {
      if (user == null) {
        if (isClosed) return;
        emit(AdminUnauthenticated());
        return;
      }

      final admin = await loadAdminStatus(user.uid);
      if (admin == null) {
        if (isClosed) return;
        emit(AdminUnauthenticated());
        return;
      }

      if (isClosed) return;
      emit(AdminAuthenticated(admin: admin, isFreshLogin: false));
    });
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<User?>? _authSubscription;

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  Future<Admin?> loadAdminStatus(String uid) async {
    try {
      final snap = await _firestore.collection("admins").doc(uid).get();
      if (!snap.exists) return null;

      return Admin.fromMap(snap.data()!);
    } catch (e) {
      return null;
    }
  }

  // ADMIN LOGIN ─────────────────────────────
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

      final admin = await loadAdminStatus(fbUser.uid);

      if (admin == null) {
        emit(AdminError(error: "هذا الحساب ليس حساب مسؤول."));
        return;
      }

      emit(AdminAuthenticated(admin: admin, isFreshLogin: true));
    } on FirebaseAuthException catch (e) {
      final errorMessage = _getAuthErrorMessage(e.code);
      emit(AdminError(error: errorMessage));
    } catch (e) {
      emit(AdminError(error: "حدث خطأ أثناء تسجيل الدخول."));
    }
  }

  // LOGOUT ─────────────────────────────
  Future<void> adminLogout() async {
    try {
      emit(AdminLoggingOut());
      await Future.delayed(Duration(milliseconds: 500));
      await _auth.signOut();
      emit(AdminUnauthenticated());
    } catch (e) {
      emit(AdminError(error: "تعذّر تسجيل الخروج. حاول مرة أخرى."));
    }
  }

  // ERROR MESSAGE HELPER ─────────────────────────────
  String _getAuthErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'البريد الإلكتروني غير صحيح. يرجى إدخال بريد إلكتروني صالح والمحاولة مرة أخرى.';
      case 'missing-email':
        return 'يرجى إدخال البريد الإلكتروني.';
      case 'email-already-in-use':
        return 'هذا البريد الإلكتروني مستخدم بالفعل. يرجى تسجيل الدخول أو استخدام بريد آخر.';
      case 'user-not-found':
        return 'لا يوجد حساب مرتبط بهذا البريد الإلكتروني.';
      case 'wrong-password':
      case 'invalid-password':
      case 'invalid-credential':
        return ' البريد الإلكتروني أو كلمة المرور غير صحيحة. يرجى التاكيد والمحاولة مرة أخرى.';
      case 'user-disabled':
        return 'تم تعطيل هذا الحساب. يرجى التواصل مع الدعم الفني لحل المشكلة.';
      case 'user-token-expired':
        return 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.';
      case 'user-mismatch':
        return 'الحساب الذي تحاول استخدامه غير مطابق للمعلومات المطلوبة لهذه العملية.';
      case 'requires-recent-login':
        return 'لأسباب تتعلق بأمان حسابك يرجى تسجيل الدخول مرة أخرى لإتمام العملية.';
      case 'network-request-failed':
        return 'تعذّر الاتصال بالأنترنت. يرجى التحقق من اتصال الإنترنت والمحاولة مجدداً.';
      case 'timeout':
        return 'انتهت مهلة الاتصال. يرجى المحاولة لاحقاً.';
      case 'operation-not-allowed':
        return 'طريقة تسجيل الدخول هذه غير مفعّلة. يرجى التواصل مع المسؤول لتفعيلها.';
      case 'too-many-requests':
        return 'لقد تجاوزت عدد المحاولات المسموح بها لتسجيل الدخول. يرجى الانتظار قبل المحاولة مرة أخرى.';
      case 'invalid-verification-code':
        return 'رمز التحقق غير صحيح أو منتهي الصلاحية. يرجى طلب رمز جديد والمحاولة مجدداً.';
      case 'quota-exceeded':
        return 'تم تجاوز الحد الأقصى لطلبات التحقق. يرجى المحاولة لاحقاً.';
      case 'invalid-phone-number':
        return 'رقم الهاتف غير صالح. يرجى التأكد من صحته والمحاولة مرة أخرى.';
      case 'invalid-tenant-id':
        return 'معرّف المستأجر غير صالح. يرجى التحقق من إعدادات المشروع.';
      case 'internal-error':
        return 'حدث خطأ داخلي غير متوقع. يرجى المحاولة مرة أخرى.';
      case 'account-exists-with-different-credential':
        return 'يوجد حساب مسجّل بهذا البريد الإلكتروني بطريقة تسجيل مختلفة. يرجى استخدام طريقة التسجيل المناسبة.';
      default:
        return 'حدث خطأ أثناء تسجيل الدخول. يرجى المحاولة مرة أخرى';
    }
  }
}
