import 'package:equatable/equatable.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/data/models/highlight.dart';

class AdminHighlightsState extends Equatable {
  const AdminHighlightsState();

  @override
  List<Object> get props => [];
}

class HighlightsInitial extends AdminHighlightsState {}

class PublishingHighlight extends AdminHighlightsState {}

class HighlightPublished extends AdminHighlightsState {}

class LoadingHighlights extends AdminHighlightsState {}

class DeletingHighlight extends AdminHighlightsState {}

class HighlightDeleted extends AdminHighlightsState {}

class SavingHighlightUpdates extends AdminHighlightsState {}

class HighlightUpdatesSaved extends AdminHighlightsState {}

class HighlightsLoading extends AdminHighlightsState {}

class HighlightsLoaded extends AdminHighlightsState {
  final List<Highlight> highlights;
  const HighlightsLoaded({required this.highlights});
}

class HighlightsError extends AdminHighlightsState {
  final String message;
  const HighlightsError(this.message);

  @override
  List<Object> get props => [message];
}
