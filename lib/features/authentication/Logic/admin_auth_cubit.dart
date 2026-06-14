import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_strings.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/firebase_error_messages.dart';
import 'package:mrmichaelashrafdashboard/features/authentication/data/models/admin.dart';
part 'admin_auth_state.dart';

class AdminAuthCubit extends Cubit<AdminAuthState> {
  AdminAuthCubit() : super(const AdminAuthInitial()) {
    _bindToAuthStream();
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<User?>? _authSubscription;

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }

  void _bindToAuthStream() {
    _authSubscription = _auth.authStateChanges().listen((user) async {
      if (isClosed) return;
      if (user == null) {
        emit(const CheckAuthStatusUnauthenticated());
        return;
      }
      try {
        final admin = await _loadAdmin(user.uid);
        if (isClosed) return;
        if (admin == null) {
          emit(const CheckAuthStatusUnauthenticated());
          return;
        }
        emit(CheckAuthStatusAuthenticated(admin: admin));
      } catch (e) {
        if (isClosed) return;
        final translated = FirebaseErrorTranslator.translate(
          e,
          fallback: AppStrings.errors.loginFailed,
        );
        emit(CheckAuthStatusError(translated.message));
      }
    });
  }

  Future<Admin?> _loadAdmin(String uid) async {
    final snap = await _firestore.collection('admins').doc(uid).get();
    if (!snap.exists) return null;
    return Admin.fromMap(snap.data()!);
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(const SignInLoading());
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final fbUser = cred.user;
      if (fbUser == null) {
        emit(const SignInError('تعذّر تسجيل الدخول.'));
        return;
      }
      final admin = await _loadAdmin(fbUser.uid);
      if (admin == null) {
        emit(const SignInError('هذا الحساب ليس حساب مسؤول.'));
        return;
      }
      emit(SignInSuccess(admin));
    } on FirebaseAuthException catch (e) {
      emit(SignInError(FirebaseErrorTranslator.translateAuth(e).message));
    } catch (e) {
      emit(
        SignInError(
          FirebaseErrorTranslator.translate(
            e,
            fallback: AppStrings.errors.loginFailed,
          ).message,
        ),
      );
    }
  }

  Future<void> signOut() async {
    emit(const SignOutLoading());
    try {
      await _auth.signOut();
      emit(const SignOutSuccess());
    } catch (e) {
      emit(
        SignOutError(
          FirebaseErrorTranslator.translate(
            e,
            fallback: 'تعذّر تسجيل الخروج. حاول مرة أخرى.',
          ).message,
        ),
      );
    }
  }

  Future<void> sendPasswordReset({required String email}) async {
    emit(const SendPasswordResetLoading());
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      emit(const SendPasswordResetSuccess());
    } on FirebaseAuthException catch (e) {
      emit(
        SendPasswordResetError(FirebaseErrorTranslator.translateAuth(e).message),
      );
    } catch (e) {
      emit(
        SendPasswordResetError(
          FirebaseErrorTranslator.translate(
            e,
            fallback: 'تعذّر إرسال رابط إعادة تعيين كلمة المرور. حاول مرة أخرى.',
          ).message,
        ),
      );
    }
  }
}
