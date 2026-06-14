import 'package:equatable/equatable.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/data/models/highlight.dart';

sealed class HighlightsState extends Equatable {
  const HighlightsState();

  @override
  List<Object?> get props => [];
}

final class HighlightsInitial extends HighlightsState {
  const HighlightsInitial();
}

// ─── publishHighlight ───────────────────────────────────────────────────
final class PublishHighlightLoading extends HighlightsState {
  const PublishHighlightLoading();
}

final class PublishHighlightSuccess extends HighlightsState {
  final Highlight highlight;
  const PublishHighlightSuccess(this.highlight);
  @override
  List<Object?> get props => [highlight];
}

final class PublishHighlightError extends HighlightsState {
  final String message;
  const PublishHighlightError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── saveHighlightUpdates ───────────────────────────────────────────────
final class SaveHighlightUpdatesLoading extends HighlightsState {
  const SaveHighlightUpdatesLoading();
}

final class SaveHighlightUpdatesSuccess extends HighlightsState {
  final Highlight highlight;
  const SaveHighlightUpdatesSuccess(this.highlight);
  @override
  List<Object?> get props => [highlight];
}

final class SaveHighlightUpdatesError extends HighlightsState {
  final String message;
  const SaveHighlightUpdatesError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── deleteHighlight ────────────────────────────────────────────────────
final class DeleteHighlightLoading extends HighlightsState {
  const DeleteHighlightLoading();
}

final class DeleteHighlightSuccess extends HighlightsState {
  final String highlightId;
  const DeleteHighlightSuccess(this.highlightId);
  @override
  List<Object?> get props => [highlightId];
}

final class DeleteHighlightError extends HighlightsState {
  final String message;
  const DeleteHighlightError(this.message);
  @override
  List<Object?> get props => [message];
}

// ─── toggleHighlightVisibility ──────────────────────────────────────────
// Loading carries the highlightId so each card can show its own spinner —
// the grid shares one cubit, so without the id every card would spin.
final class ToggleHighlightVisibilityLoading extends HighlightsState {
  final String highlightId;
  const ToggleHighlightVisibilityLoading(this.highlightId);
  @override
  List<Object?> get props => [highlightId];
}

final class ToggleHighlightVisibilitySuccess extends HighlightsState {
  final String highlightId;
  final bool isVisible;
  const ToggleHighlightVisibilitySuccess({
    required this.highlightId,
    required this.isVisible,
  });
  @override
  List<Object?> get props => [highlightId, isVisible];
}

final class ToggleHighlightVisibilityError extends HighlightsState {
  final String message;
  const ToggleHighlightVisibilityError(this.message);
  @override
  List<Object?> get props => [message];
}

// NOTE: paginated reads (`fetchHighlightsPage` / `getHighlightsCount`) are
// plain Future-returning helpers on the cubit — the center owns its page
// list + loading/error UI locally, so they intentionally have no state
// triple here. State is reserved for the mutations the grid reacts to.

// ─────────────────────────────────────────────────────────────────────────────
extension HighlightsStateX on HighlightsState {
  String? get errorMessage => switch (this) {
        PublishHighlightError(:final message) => message,
        SaveHighlightUpdatesError(:final message) => message,
        DeleteHighlightError(:final message) => message,
        ToggleHighlightVisibilityError(:final message) => message,
        _ => null,
      };

  bool get isLoading =>
      this is PublishHighlightLoading ||
      this is SaveHighlightUpdatesLoading ||
      this is DeleteHighlightLoading ||
      this is ToggleHighlightVisibilityLoading;

  bool get isMutationSuccess =>
      this is PublishHighlightSuccess ||
      this is SaveHighlightUpdatesSuccess ||
      this is DeleteHighlightSuccess ||
      this is ToggleHighlightVisibilitySuccess;
}
