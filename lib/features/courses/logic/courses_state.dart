import 'package:equatable/equatable.dart';
import 'package:mrmichaelashrafdashboard/features/courses/data/models/course.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CoursesCubit state hierarchy.
//
// Follows the project-wide pattern: a sealed base + one initial + a dedicated
// (Loading / Success / Error) triple per action. Error states ALWAYS carry a
// `message`; success states carry the resulting entity when the action
// produces one. See [CoursesStateX] at the bottom of the file for the
// cross-cutting helpers consumers reach for instead of long `is X || is Y`
// chains.
//
// Pure helper reads on the cubit (e.g. `getCoursesCount`,
// `fetchUsersBasicInfo`) intentionally do NOT emit state — they return a
// Future directly and let the calling screen own its own loading UI. The
// state triples here are reserved for actions whose lifecycle the UI tracks.
// ─────────────────────────────────────────────────────────────────────────────

sealed class CoursesState extends Equatable {
  const CoursesState();

  @override
  List<Object?> get props => [];
}

final class CoursesInitial extends CoursesState {
  const CoursesInitial();
}

// ─── publishCourse ──────────────────────────────────────────────────────
final class PublishCourseLoading extends CoursesState {
  const PublishCourseLoading();
}

final class PublishCourseSuccess extends CoursesState {
  final Course course;
  const PublishCourseSuccess(this.course);
  @override
  List<Object?> get props => [course];
}

final class PublishCourseError extends CoursesState {
  final String message;
  const PublishCourseError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── saveCourseUpdates ──────────────────────────────────────────────────
final class SaveCourseUpdatesLoading extends CoursesState {
  const SaveCourseUpdatesLoading();
}

final class SaveCourseUpdatesSuccess extends CoursesState {
  final Course course;
  const SaveCourseUpdatesSuccess(this.course);
  @override
  List<Object?> get props => [course];
}

final class SaveCourseUpdatesError extends CoursesState {
  final String message;
  const SaveCourseUpdatesError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── deleteCourse ───────────────────────────────────────────────────────
final class DeleteCourseLoading extends CoursesState {
  const DeleteCourseLoading();
}

final class DeleteCourseSuccess extends CoursesState {
  final String courseId;
  const DeleteCourseSuccess(this.courseId);
  @override
  List<Object?> get props => [courseId];
}

final class DeleteCourseError extends CoursesState {
  final String message;
  const DeleteCourseError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── toggleCourseVisibility ─────────────────────────────────────────────
// Loading carries the courseId so each card can show its own spinner — the
// grid shares one cubit, so without the id every card would spin.
final class ToggleCourseVisibilityLoading extends CoursesState {
  final String courseId;
  const ToggleCourseVisibilityLoading(this.courseId);
  @override
  List<Object?> get props => [courseId];
}

final class ToggleCourseVisibilitySuccess extends CoursesState {
  final String courseId;
  final bool isVisible;
  const ToggleCourseVisibilitySuccess({
    required this.courseId,
    required this.isVisible,
  });
  @override
  List<Object?> get props => [courseId, isVisible];
}

final class ToggleCourseVisibilityError extends CoursesState {
  final String message;
  const ToggleCourseVisibilityError(this.message);
  @override
  List<Object?> get props => [message];
}

// NOTE: paginated reads (`fetchCoursesPage` / `getCoursesCount`) and the
// enrollment helpers are plain Future-returning methods on the cubit — the
// center owns its page list + loading/error UI, so they have no state triple
// here. State is reserved for the mutations consumers react to.

// ─────────────────────────────────────────────────────────────────────────────
// Cross-cutting helpers. Consumers don't need to know every concrete state —
// `state.errorMessage` and `state.isLoading` give them the generic answer
// when that's all they care about. Use the concrete `state is
// PublishCourseSuccess` pattern when the action's identity matters
// (e.g. to react only to delete completions, not every success).
// ─────────────────────────────────────────────────────────────────────────────
extension CoursesStateX on CoursesState {
  String? get errorMessage => switch (this) {
        PublishCourseError(:final message) => message,
        SaveCourseUpdatesError(:final message) => message,
        DeleteCourseError(:final message) => message,
        ToggleCourseVisibilityError(:final message) => message,
        _ => null,
      };

  bool get isLoading =>
      this is PublishCourseLoading ||
      this is SaveCourseUpdatesLoading ||
      this is DeleteCourseLoading ||
      this is ToggleCourseVisibilityLoading;

  bool get isMutationSuccess =>
      this is PublishCourseSuccess ||
      this is SaveCourseUpdatesSuccess ||
      this is DeleteCourseSuccess ||
      this is ToggleCourseVisibilitySuccess;
}
