import 'package:equatable/equatable.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/exam.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/data/models/highlight.dart';
import 'package:mrmichaelashrafdashboard/features/payments/data/models/payment_record.dart';
import 'package:mrmichaelashrafdashboard/features/users/logic/users_cubit.dart';

// ─────────────────────────────────────────────────────────────────────────────
// HomeCubit state hierarchy.
//
// HomeCubit is fully isolated — it OWNS its own Firestore queries and does
// not call into the area cubits. That separation is what stops a filter
// switch in a center from corrupting the home view: area cubit state emits
// can't reach HomeCubit's state.
//
// The home renders from a single bundle [LoadHomeSuccess] carries:
//   * top 3 courses by enrollment
//   * live exams (window currently open)
//   * live highlights (within their schedule)
//   * the students breakdown (for the home stats grid)
//   * roll-up counts the stats grid needs
//
// Followed by the project-wide per-action triple pattern.
// ─────────────────────────────────────────────────────────────────────────────

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

final class HomeInitial extends HomeState {
  const HomeInitial();
}

// ─── load ───────────────────────────────────────────────────────────────
final class LoadHomeLoading extends HomeState {
  const LoadHomeLoading();
}

final class LoadHomeSuccess extends HomeState {
  final List<Course> topCourses;
  final List<Exam> liveExams;
  final List<Highlight> liveHighlights;
  final List<PaymentRecord> pendingPayments;
  final UsersBreakdown breakdown;
  final int totalCoursesCount;
  final int totalExamsCount;
  final int activeExamsCount;
  final int totalHighlightsCount;
  final int activeHighlightsCount;
  final int totalEnrollmentsCount;
  final double totalRevenue;

  const LoadHomeSuccess({
    required this.topCourses,
    required this.liveExams,
    required this.liveHighlights,
    required this.pendingPayments,
    required this.breakdown,
    required this.totalCoursesCount,
    required this.totalExamsCount,
    required this.activeExamsCount,
    required this.totalHighlightsCount,
    required this.activeHighlightsCount,
    required this.totalEnrollmentsCount,
    required this.totalRevenue,
  });

  @override
  List<Object?> get props => [
        topCourses,
        liveExams,
        liveHighlights,
        pendingPayments,
        breakdown,
        totalCoursesCount,
        totalExamsCount,
        activeExamsCount,
        totalHighlightsCount,
        activeHighlightsCount,
        totalEnrollmentsCount,
        totalRevenue,
      ];

  /// True when every content section is empty — drives the first-launch
  /// welcome card instead of four separate empty placeholders.
  bool get isCompletelyEmpty =>
      topCourses.isEmpty &&
      liveExams.isEmpty &&
      liveHighlights.isEmpty &&
      pendingPayments.isEmpty;
}

final class LoadHomeError extends HomeState {
  final String message;
  const LoadHomeError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── refresh ────────────────────────────────────────────────────────────
// Refresh keeps the existing `LoadHomeSuccess` on screen while the new data
// is in flight, so it has its own (Loading / Success / Error) triple that
// the UI uses for a subtle in-place spinner instead of dropping back to
// the full LoadHome skeleton.
final class RefreshHomeLoading extends HomeState {
  /// The previous bundle, preserved so the screen can keep rendering it
  /// while we re-fetch.
  final LoadHomeSuccess previous;
  const RefreshHomeLoading(this.previous);
  @override
  List<Object?> get props => [previous];
}

final class RefreshHomeSuccess extends HomeState {
  final List<Course> topCourses;
  final List<Exam> liveExams;
  final List<Highlight> liveHighlights;
  final List<PaymentRecord> pendingPayments;
  final UsersBreakdown breakdown;
  final int totalCoursesCount;
  final int totalExamsCount;
  final int activeExamsCount;
  final int totalHighlightsCount;
  final int activeHighlightsCount;
  final int totalEnrollmentsCount;
  final double totalRevenue;

  const RefreshHomeSuccess({
    required this.topCourses,
    required this.liveExams,
    required this.liveHighlights,
    required this.pendingPayments,
    required this.breakdown,
    required this.totalCoursesCount,
    required this.totalExamsCount,
    required this.activeExamsCount,
    required this.totalHighlightsCount,
    required this.activeHighlightsCount,
    required this.totalEnrollmentsCount,
    required this.totalRevenue,
  });

  @override
  List<Object?> get props => [
        topCourses,
        liveExams,
        liveHighlights,
        pendingPayments,
        breakdown,
        totalCoursesCount,
        totalExamsCount,
        activeExamsCount,
        totalHighlightsCount,
        activeHighlightsCount,
        totalEnrollmentsCount,
        totalRevenue,
      ];
}

final class RefreshHomeError extends HomeState {
  final String message;
  const RefreshHomeError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── toggleHomeCardVisibility ───────────────────────────────────────────
// Persisted UI preference — which preview cards the admin wants on the home
// screen. Backed by SharedPreferences when implementation lands.
final class ToggleHomeCardVisibilityLoading extends HomeState {
  const ToggleHomeCardVisibilityLoading();
}

final class ToggleHomeCardVisibilitySuccess extends HomeState {
  final String cardKey;
  final bool isVisible;
  const ToggleHomeCardVisibilitySuccess({
    required this.cardKey,
    required this.isVisible,
  });
  @override
  List<Object?> get props => [cardKey, isVisible];
}

final class ToggleHomeCardVisibilityError extends HomeState {
  final String message;
  const ToggleHomeCardVisibilityError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─────────────────────────────────────────────────────────────────────────────
extension HomeStateX on HomeState {
  String? get errorMessage => switch (this) {
        LoadHomeError(:final message) => message,
        RefreshHomeError(:final message) => message,
        ToggleHomeCardVisibilityError(:final message) => message,
        _ => null,
      };
}
