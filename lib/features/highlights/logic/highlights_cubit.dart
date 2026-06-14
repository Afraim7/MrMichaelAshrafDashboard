import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mrmichaelashrafdashboard/core/constants/app_strings.dart';
import 'package:mrmichaelashrafdashboard/core/utilities/firebase_error_messages.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/data/models/highlight.dart';
import 'package:mrmichaelashrafdashboard/features/highlights/logic/highlights_state.dart';

class HighlightsCubit extends Cubit<HighlightsState> {
  HighlightsCubit() : super(const HighlightsInitial());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── publishHighlight ───────────────────────────────────────────────────
  Future<void> publishHighlight({
    required String highlightText,
    required String grade,
    required String type,
    required Timestamp startDate,
    required Timestamp endDate,
  }) async {
    emit(const PublishHighlightLoading());
    try {
      final highlightId = _firestore.collection('highlights').doc().id;
      final data = {
        'id': highlightId,
        'message': highlightText,
        'grade': grade,
        'type': type,
        'startDate': startDate,
        'endDate': endDate,
        // New highlights start hidden — the admin reviews then toggles them
        // visible from the card.
        'isVisible': false,
      };
      await _firestore.collection('highlights').doc(highlightId).set(data);
      emit(PublishHighlightSuccess(Highlight.fromJson(data, id: highlightId)));
    } catch (e) {
      final translated = FirebaseErrorTranslator.translate(
        e,
        fallback: AppStrings.errors.highlightPublishFailed,
      );
      emit(PublishHighlightError(translated.message));
    }
  }

  // ─── saveHighlightUpdates ───────────────────────────────────────────────
  Future<void> saveHighlightUpdates({
    required String highlightId,
    required String highlightText,
    required String grade,
    required String type,
    required Timestamp startDate,
    required Timestamp endDate,
  }) async {
    emit(const SaveHighlightUpdatesLoading());
    try {
      final data = {
        'id': highlightId,
        'message': highlightText,
        'grade': grade,
        'type': type,
        'startDate': startDate,
        'endDate': endDate,
      };
      await _firestore
          .collection('highlights')
          .doc(highlightId)
          .set(data, SetOptions(merge: true));
      emit(
        SaveHighlightUpdatesSuccess(Highlight.fromJson(data, id: highlightId)),
      );
    } catch (e) {
      final translated = FirebaseErrorTranslator.translate(
        e,
        fallback: AppStrings.errors.highlightPublishFailed,
      );
      emit(SaveHighlightUpdatesError(translated.message));
    }
  }

  // ─── deleteHighlight ────────────────────────────────────────────────────
  Future<void> deleteHighlight(String highlightId) async {
    emit(const DeleteHighlightLoading());
    try {
      await _firestore.collection('highlights').doc(highlightId).delete();
      emit(DeleteHighlightSuccess(highlightId));
    } catch (e) {
      final translated = FirebaseErrorTranslator.translate(
        e,
        fallback: AppStrings.errors.highlightDeleteFailed,
      );
      emit(DeleteHighlightError(translated.message));
    }
  }

  // ─── toggleHighlightVisibility ──────────────────────────────────────────
  /// Flips the admin-controlled `isVisible` flag. When false the highlight is
  /// hidden from students regardless of its date window. Emits a per-card
  /// loading state (carrying the id) so only the tapped card spins.
  Future<void> toggleHighlightVisibility({
    required String highlightId,
    required bool isVisible,
  }) async {
    emit(ToggleHighlightVisibilityLoading(highlightId));
    try {
      await _firestore.collection('highlights').doc(highlightId).update({
        'isVisible': isVisible,
      });
      emit(
        ToggleHighlightVisibilitySuccess(
          highlightId: highlightId,
          isVisible: isVisible,
        ),
      );
    } catch (e) {
      final translated = FirebaseErrorTranslator.translate(
        e,
        fallback: AppStrings.errors.highlightPublishFailed,
      );
      emit(ToggleHighlightVisibilityError(translated.message));
    }
  }

  // ─── fetchHighlightsPage (Future-returning helper) ──────────────────────
  // The center owns its own page list + loading/error UI, so this returns
  // the slice directly and does not emit. Offset-emulation: pull
  // `page * pageSize` rows, drop the leading ones in memory.
  Future<List<Highlight>> fetchHighlightsPage({
    required int page,
    required int pageSize,
    String? gradeName,
  }) async {
    Query<Map<String, dynamic>> q = _firestore.collection('highlights');
    if (gradeName != null) {
      // Grade-filtered: skip the server-side orderBy to avoid needing a
      // (grade + startDate) composite index — sorted in memory below.
      q = q.where('grade', isEqualTo: gradeName);
    } else {
      q = q.orderBy('startDate', descending: true);
    }
    final snap = await q.limit(page * pageSize).get();

    final allDocs = snap.docs;
    final skip = (page - 1) * pageSize;
    final pageDocs = skip >= allDocs.length
        ? const <QueryDocumentSnapshot<Map<String, dynamic>>>[]
        : allDocs.sublist(skip);

    final highlights = pageDocs
        .map((doc) {
          try {
            return Highlight.fromJson(doc.data(), id: doc.id);
          } catch (_) {
            return null;
          }
        })
        .whereType<Highlight>()
        .toList();
    // Newest-first; highlights without a start time sort to the end.
    highlights.sort((a, b) {
      if (a.startTime == null && b.startTime == null) return 0;
      if (a.startTime == null) return 1;
      if (b.startTime == null) return -1;
      return b.startTime!.compareTo(a.startTime!);
    });
    return highlights;
  }

  Future<int> getHighlightsCount({String? gradeName}) async {
    Query<Map<String, dynamic>> q = _firestore.collection('highlights');
    if (gradeName != null) {
      q = q.where('grade', isEqualTo: gradeName);
    }
    final agg = await q.count().get();
    return agg.count ?? 0;
  }

  Future<Highlight?> fetchHighlightById(String highlightId) async {
    final snap = await _firestore
        .collection('highlights')
        .doc(highlightId)
        .get();
    if (!snap.exists) return null;
    return Highlight.fromJson(snap.data()!, id: snap.id);
  }
}
