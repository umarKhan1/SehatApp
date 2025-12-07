import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatapp/features/search/data/search_repository.dart';
import 'package:sehatapp/features/search/models/search_item_model.dart';

class SearchState {
  const SearchState({
    this.loading = false,
    this.query = '',
    this.results = const [],
    this.error,
  });
  final bool loading;
  final String query;
  final List<SearchItemModel> results;
  final String? error;
  SearchState copyWith({
    bool? loading,
    String? query,
    List<SearchItemModel>? results,
    String? error,
  }) => SearchState(
    loading: loading ?? this.loading,
    query: query ?? this.query,
    results: results ?? this.results,
    error: error,
  );
}

class SearchCubit extends Cubit<SearchState> {
  SearchCubit({required this.repo}) : super(const SearchState());
  final SearchRepository repo;

  Future<void> search(String term) async {
    emit(state.copyWith(loading: true, query: term,));
    try {
      final res = await repo.search(term);
      emit(state.copyWith(loading: false, results: res));
    } catch (e) {
      // ignore: avoid_print
      print('Search error: $e');
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }

  void clear() {
    emit(const SearchState());
  }
}
