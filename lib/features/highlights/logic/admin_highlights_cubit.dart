import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mrmichaelashrafdashboard/core/config/app_strings.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/data/models/highlight.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/logic/admin_highlights_state.dart';

class AdminHighlightsCubit extends Cubit<AdminHighlightsState> {
  AdminHighlightsCubit() : super(HighlightsInitial());

  final FirebaseFirestore _firestoreRef = FirebaseFirestore.instance;

  Future<void> publishHighlight({
    required String highlightText,
    required String grade,
    required String type,
    required Timestamp startDate,
    required Timestamp endDate,
  }) async {
    try {
      emit(PublishingHighlight());
      final highlightId = _firestoreRef.collection('highlights').doc().id;
      await _firestoreRef.collection('highlights').doc(highlightId).set({
        'id': highlightId,
        'message': highlightText,
        'grade': grade,
        'type': type,
        'startDate': startDate,
        'endDate': endDate,
      });
      emit(HighlightPublished());
      await fetchAllHighlights();
    } catch (e) {
      emit(
        HighlightsError(
          '${AppStrings.errors.highlightPublishFailed}: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> fetchAllHighlights() async {
    try {
      emit(HighlightsLoading());
      final snapshot = await _firestoreRef.collection('highlights').get();
      final highlights = snapshot.docs.map((doc) {
        return Highlight.fromJson(doc.data(), id: doc.id);
      }).toList();
      highlights.sort((a, b) {
        final aStart = a.startTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bStart = b.startTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bStart.compareTo(aStart);
      });
      emit(HighlightsLoaded(highlights: highlights));
    } catch (e) {
      emit(HighlightsError(AppStrings.errors.notesLoadFailed));
    }
  }

  Future<void> deleteHighlight(String highlightId) async {
    try {
      emit(DeletingHighlight());
      await _firestoreRef.collection('highlights').doc(highlightId).delete();
      emit(HighlightDeleted());
      await fetchAllHighlights();
    } catch (e) {
      emit(HighlightsError(AppStrings.errors.highlightDeleteFailed));
    }
  }

  Future<void> saveHighlightUpdates({
    required String highlightId,
    required String highlightText,
    required String grade,
    required String type,
    required Timestamp startDate,
    required Timestamp endDate,
  }) async {
    try {
      emit(SavingHighlightUpdates());
      await _firestoreRef.collection('highlights').doc(highlightId).set({
        'id': highlightId,
        'message': highlightText,
        'grade': grade,
        'type': type,
        'startDate': startDate,
        'endDate': endDate,
      }, SetOptions(merge: true));
      emit(HighlightUpdatesSaved());
      await fetchAllHighlights();
    } catch (e) {
      emit(
        HighlightsError(
          '${AppStrings.errors.highlightPublishFailed}: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> fetchHighlightsByGrade(String gradeName) async {
    try {
      emit(HighlightsLoading());
      final snapshot = await _firestoreRef
          .collection('highlights')
          .where('grade', isEqualTo: gradeName)
          .get();

      final highlights = snapshot.docs.map((doc) {
        return Highlight.fromJson(doc.data(), id: doc.id);
      }).toList();

      highlights.sort((a, b) {
        final aStart = a.startTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bStart = b.startTime ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bStart.compareTo(aStart);
      });

      emit(HighlightsLoaded(highlights: highlights));
    } catch (e) {
      emit(
        HighlightsError(
          '${AppStrings.errors.notesLoadFailed}: ${e.toString()}',
        ),
      );
    }
  }

  Future<int> getActiveHighlightsCount() async {
    try {
      final snapshot = await _firestoreRef.collection('highlights').get();
      final highlights = snapshot.docs
          .map((doc) {
            try {
              return Highlight.fromJson(doc.data(), id: doc.id);
            } catch (e) {
              return null;
            }
          })
          .where((highlight) => highlight != null)
          .cast<Highlight>()
          .toList();

      final now = DateTime.now();
      final activeHighlights = highlights.where((highlight) {
        final start =
            highlight.startTime ?? DateTime(now.year, now.month, now.day);
        final end =
            highlight.endTime ??
            DateTime(now.year, now.month, now.day, 23, 59, 59);
        final isActive = !now.isBefore(start) && !now.isAfter(end);
        return isActive;
      }).toList();

      return activeHighlights.length;
    } catch (e) {
      emit(
        HighlightsError(
          '${AppStrings.errors.notesLoadFailed}: ${e.toString()}',
        ),
      );
      return 0;
    }
  }

  Future<void> refreshHighlights() async {
    await fetchAllHighlights();
  }
}
