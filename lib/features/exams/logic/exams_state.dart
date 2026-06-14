import 'package:equatable/equatable.dart';
import 'package:mrmichaelashrafdashboard/features/exams/data/models/exam.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ExamsCubit state hierarchy. Follows the project pattern: sealed base,
// one initial, and a per-action (Loading / Success / Error) triple. Helper
// reads (counts, lookups by id, student-name fetches) stay as plain async
// methods on the cubit — they don't earn dedicated states because no UI
// observes their lifecycle.
// ─────────────────────────────────────────────────────────────────────────────

sealed class ExamsState extends Equatable {
  const ExamsState();

  @override
  List<Object?> get props => [];
}

final class ExamsInitial extends ExamsState {
  const ExamsInitial();
}

// ─── publishExam ────────────────────────────────────────────────────────
final class PublishExamLoading extends ExamsState {
  const PublishExamLoading();
}

final class PublishExamSuccess extends ExamsState {
  final Exam exam;
  const PublishExamSuccess(this.exam);
  @override
  List<Object?> get props => [exam];
}

final class PublishExamError extends ExamsState {
  final String message;
  const PublishExamError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── saveExamUpdates ────────────────────────────────────────────────────
final class SaveExamUpdatesLoading extends ExamsState {
  const SaveExamUpdatesLoading();
}

final class SaveExamUpdatesSuccess extends ExamsState {
  final Exam exam;
  const SaveExamUpdatesSuccess(this.exam);
  @override
  List<Object?> get props => [exam];
}

final class SaveExamUpdatesError extends ExamsState {
  final String message;
  const SaveExamUpdatesError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── deleteExam ─────────────────────────────────────────────────────────
final class DeleteExamLoading extends ExamsState {
  const DeleteExamLoading();
}

final class DeleteExamSuccess extends ExamsState {
  final String examId;
  const DeleteExamSuccess(this.examId);
  @override
  List<Object?> get props => [examId];
}

final class DeleteExamError extends ExamsState {
  final String message;
  const DeleteExamError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── toggleExamVisibility ───────────────────────────────────────────────
// Loading carries the examId so each card shows its own spinner.
final class ToggleExamVisibilityLoading extends ExamsState {
  final String examId;
  const ToggleExamVisibilityLoading(this.examId);
  @override
  List<Object?> get props => [examId];
}

final class ToggleExamVisibilitySuccess extends ExamsState {
  final String examId;
  final bool isVisible;
  const ToggleExamVisibilitySuccess({
    required this.examId,
    required this.isVisible,
  });
  @override
  List<Object?> get props => [examId, isVisible];
}

final class ToggleExamVisibilityError extends ExamsState {
  final String message;
  const ToggleExamVisibilityError(this.message);
  @override
  List<Object?> get props => [message];
}

// NOTE: paginated reads (`fetchExamsPage` / `getExamsCount`) and the results
// fetch are plain Future-returning helpers on the cubit — the center owns its
// page list + loading/error UI, so they have no state triple here.

// ─────────────────────────────────────────────────────────────────────────────
extension ExamsStateX on ExamsState {
  String? get errorMessage => switch (this) {
        PublishExamError(:final message) => message,
        SaveExamUpdatesError(:final message) => message,
        DeleteExamError(:final message) => message,
        ToggleExamVisibilityError(:final message) => message,
        _ => null,
      };

  bool get isLoading =>
      this is PublishExamLoading ||
      this is SaveExamUpdatesLoading ||
      this is DeleteExamLoading ||
      this is ToggleExamVisibilityLoading;

  bool get isMutationSuccess =>
      this is PublishExamSuccess ||
      this is SaveExamUpdatesSuccess ||
      this is DeleteExamSuccess ||
      this is ToggleExamVisibilitySuccess;
}
