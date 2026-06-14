import 'dart:async';
import 'dart:io' show SocketException;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_strings.dart';

/// Coarse buckets the UI uses to decide *what to do* about an error.
///
///   • [network]      — flaky internet / DNS / timeouts; retry usually fixes it
///   • [permission]   — Firestore rules denied the read/write; retry won't fix
///   • [unauthenticated] — session expired; the user should re-login
///   • [notFound]     — the target doc no longer exists
///   • [validation]   — bad input (e.g. invalid email format)
///   • [unknown]      — anything we couldn't classify; safe default = retry
enum FirebaseErrorKind {
  network,
  permission,
  unauthenticated,
  notFound,
  validation,
  unknown,
}

/// What every error surface in the app speaks: a human-readable Arabic message
/// + the classification so the UI can decide whether a "retry" button makes
/// sense or whether to suggest a different action (e.g. "log in again").
class FirebaseFriendlyError {
  final String message;
  final FirebaseErrorKind kind;

  const FirebaseFriendlyError({required this.message, required this.kind});

  /// True for transient errors where the user tapping "retry" is reasonable.
  /// Permission / validation / notFound are NOT retryable — retrying does
  /// nothing useful and may confuse the user.
  bool get canRetry =>
      kind == FirebaseErrorKind.network ||
      kind == FirebaseErrorKind.unknown ||
      kind == FirebaseErrorKind.unauthenticated;
}

/// Single source of truth for turning any Firebase/network exception into
/// (a) Arabic copy admins can act on and (b) a category UI code can branch on.
///
/// Usage from a cubit's catch block:
/// ```dart
/// } catch (e) {
///   final err = FirebaseErrorTranslator.translate(e, fallback: 'فشل التحميل');
///   emit(XError(message: err.message, kind: err.kind));
/// }
/// ```
class FirebaseErrorTranslator {
  FirebaseErrorTranslator._();

  // ─── Public entry points ───────────────────────────────────────────────

  /// Translates a [FirebaseAuthException]. Codes covered are the full set
  /// auth users hit during sign-in / sign-up / reset flows.
  static FirebaseFriendlyError translateAuth(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return const FirebaseFriendlyError(
          message:
              'البريد الإلكتروني غير صحيح. يرجى إدخال بريد إلكتروني صالح والمحاولة مرة أخرى.',
          kind: FirebaseErrorKind.validation,
        );
      case 'missing-email':
        return const FirebaseFriendlyError(
          message: 'يرجى إدخال البريد الإلكتروني.',
          kind: FirebaseErrorKind.validation,
        );
      case 'email-already-in-use':
        return const FirebaseFriendlyError(
          message:
              'هذا البريد الإلكتروني مستخدم بالفعل. يرجى تسجيل الدخول أو استخدام بريد آخر.',
          kind: FirebaseErrorKind.validation,
        );
      case 'user-not-found':
        return const FirebaseFriendlyError(
          message: 'لا يوجد حساب مرتبط بهذا البريد الإلكتروني.',
          kind: FirebaseErrorKind.validation,
        );
      case 'wrong-password':
      case 'invalid-password':
      case 'invalid-credential':
        return const FirebaseFriendlyError(
          message:
              'البريد الإلكتروني أو كلمة المرور غير صحيحة. تحقق من البيانات وحاول مرة أخرى.',
          kind: FirebaseErrorKind.validation,
        );
      case 'user-disabled':
        return const FirebaseFriendlyError(
          message:
              'تم تعطيل هذا الحساب. يرجى التواصل مع الدعم الفني لحل المشكلة.',
          kind: FirebaseErrorKind.permission,
        );
      case 'user-token-expired':
      case 'requires-recent-login':
        return FirebaseFriendlyError(
          message: AppStrings.errors.notAuthenticated,
          kind: FirebaseErrorKind.unauthenticated,
        );
      case 'network-request-failed':
        return FirebaseFriendlyError(
          message: AppStrings.errors.noInternet,
          kind: FirebaseErrorKind.network,
        );
      case 'timeout':
        return FirebaseFriendlyError(
          message: AppStrings.errors.requestTimeout,
          kind: FirebaseErrorKind.network,
        );
      case 'too-many-requests':
        return const FirebaseFriendlyError(
          message:
              'لقد تجاوزت عدد المحاولات المسموح بها. يرجى الانتظار قبل المحاولة مرة أخرى.',
          kind: FirebaseErrorKind.permission,
        );
      case 'operation-not-allowed':
        return const FirebaseFriendlyError(
          message:
              'طريقة تسجيل الدخول هذه غير مفعّلة. يرجى التواصل مع المسؤول.',
          kind: FirebaseErrorKind.permission,
        );
      case 'quota-exceeded':
        return FirebaseFriendlyError(
          message: AppStrings.errors.quotaExceeded,
          kind: FirebaseErrorKind.network,
        );
      case 'invalid-verification-code':
        return const FirebaseFriendlyError(
          message:
              'رمز التحقق غير صحيح أو منتهي الصلاحية. يرجى طلب رمز جديد والمحاولة مجدداً.',
          kind: FirebaseErrorKind.validation,
        );
      default:
        return FirebaseFriendlyError(
          message: AppStrings.errors.loginFailed,
          kind: FirebaseErrorKind.unknown,
        );
    }
  }

  /// Translates any Firestore / generic exception thrown by the data layer.
  /// Pass a [fallback] message — used only when nothing more specific applies
  /// (so the UI still says something domain-relevant like "فشل تحميل الطلاب").
  static FirebaseFriendlyError translate(
    Object error, {
    required String fallback,
  }) {
    // ── Bare network failures (no Firebase wrapper) ───────────────────
    if (error is SocketException) {
      return FirebaseFriendlyError(
        message: AppStrings.errors.noInternet,
        kind: FirebaseErrorKind.network,
      );
    }
    if (error is TimeoutException) {
      return FirebaseFriendlyError(
        message: AppStrings.errors.requestTimeout,
        kind: FirebaseErrorKind.network,
      );
    }

    // ── Firebase Auth exceptions surfacing in non-auth code paths ─────
    if (error is FirebaseAuthException) {
      return translateAuth(error);
    }

    // ── Firestore + other Firebase exceptions ─────────────────────────
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return FirebaseFriendlyError(
            message: AppStrings.errors.permissionDenied,
            kind: FirebaseErrorKind.permission,
          );
        case 'unauthenticated':
          return FirebaseFriendlyError(
            message: AppStrings.errors.notAuthenticated,
            kind: FirebaseErrorKind.unauthenticated,
          );
        case 'unavailable':
        case 'deadline-exceeded':
        case 'aborted':
          return FirebaseFriendlyError(
            message: AppStrings.errors.serviceUnavailable,
            kind: FirebaseErrorKind.network,
          );
        case 'not-found':
          return FirebaseFriendlyError(
            message: AppStrings.errors.notFoundResource,
            kind: FirebaseErrorKind.notFound,
          );
        case 'cancelled':
          return FirebaseFriendlyError(
            message: AppStrings.errors.unexpectedError,
            kind: FirebaseErrorKind.unknown,
          );
        case 'resource-exhausted':
          return FirebaseFriendlyError(
            message: AppStrings.errors.quotaExceeded,
            kind: FirebaseErrorKind.network,
          );
        case 'failed-precondition':
        case 'invalid-argument':
        case 'out-of-range':
          return FirebaseFriendlyError(
            message: fallback,
            kind: FirebaseErrorKind.validation,
          );
        default:
          return FirebaseFriendlyError(
            message: fallback,
            kind: FirebaseErrorKind.unknown,
          );
      }
    }

    // ── Last-ditch fallback for stringy/unknown errors ────────────────
    final raw = error.toString().toLowerCase();
    // Heuristics: some Firestore errors surface as plain strings instead of
    // structured FirebaseException. Cheap to check — high signal.
    if (raw.contains('socket') ||
        raw.contains('network') ||
        raw.contains('connection')) {
      return FirebaseFriendlyError(
        message: AppStrings.errors.noInternet,
        kind: FirebaseErrorKind.network,
      );
    }
    if (raw.contains('permission')) {
      return FirebaseFriendlyError(
        message: AppStrings.errors.permissionDenied,
        kind: FirebaseErrorKind.permission,
      );
    }
    return FirebaseFriendlyError(
      message: fallback,
      kind: FirebaseErrorKind.unknown,
    );
  }
}
