import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatapp/features/recently_viewed/data/recently_viewed_repository.dart';
import 'package:sehatapp/features/recently_viewed/models/recently_viewed_entry.dart';

class RecentlyViewedState {
  RecentlyViewedState({this.loading = false, this.previewItems = const [], this.allItems = const []});
  final bool loading;
  final List<Map<String, dynamic>> previewItems; // map for UI compatibility
  final List<Map<String, dynamic>> allItems;
  RecentlyViewedState copyWith({bool? loading, List<Map<String, dynamic>>? previewItems, List<Map<String, dynamic>>? allItems}) =>
      RecentlyViewedState(
        loading: loading ?? this.loading,
        previewItems: previewItems ?? this.previewItems,
        allItems: allItems ?? this.allItems,
      );
}

class RecentlyViewedCubit extends Cubit<RecentlyViewedState> {
  RecentlyViewedCubit(this.repo) : super(RecentlyViewedState());
  final IRecentlyViewedRepository repo;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  List<Map<String, dynamic>> _toUi(List<RecentlyViewedEntry> list) => list.map((e) => e.toMap()).toList();

  Future<void> loadPreview() async {
    emit(state.copyWith(loading: true));
    final uid = _uid;
    if (uid == null) {
      emit(state.copyWith(loading: false, previewItems: const []));
      return;
    }
    final items = await repo.getPreview(uid);
    emit(state.copyWith(loading: false, previewItems: _toUi(items)));
  }

  Future<void> loadAll() async {
    emit(state.copyWith(loading: true));
    final uid = _uid;
    if (uid == null) {
      emit(state.copyWith(loading: false, allItems: const []));
      return;
    }
    final items = await repo.getAll(uid);
    emit(state.copyWith(loading: false, allItems: _toUi(items)));
  }

  Future<void> addViewed(Map<String, dynamic> post) async {
    final uid = _uid;
    if (uid == null) return;
    await repo.addItem(uid, post);
    final preview = await repo.getPreview(uid);
    emit(state.copyWith(previewItems: _toUi(preview)));
  }

  Future<void> refreshAll() async {
    final uid = _uid;
    if (uid == null) return;
    final all = await repo.getAll(uid);
    emit(state.copyWith(allItems: _toUi(all)));
  }

  Future<void> clear() async {
    final uid = _uid;
    if (uid == null) return;
    await repo.clear(uid);
    emit(state.copyWith(previewItems: const [], allItems: const []));
  }
}
