import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatapp/features/post_request/data/post_repository.dart';

class PostsState {
  const PostsState({this.loading = false, this.error, this.posts = const []});
  final bool loading;
  final String? error;
  final List<Map<String, dynamic>> posts;
  PostsState copyWith({bool? loading, String? error, List<Map<String, dynamic>>? posts}) =>
      PostsState(loading: loading ?? this.loading, error: error, posts: posts ?? this.posts);
}

class PostsCubit extends Cubit<PostsState> {
  PostsCubit({required this.repo}) : super(const PostsState());
  final PostRepository repo;
  StreamSubscription? _sub;

  void start() {
    emit(state.copyWith(loading: true));
    _sub?.cancel();
    _sub = repo.streamPosts(limit: 100).listen(
      (items) => emit(state.copyWith(loading: false, posts: items)),
      onError: (e) => emit(state.copyWith(loading: false, error: e.toString())),
    );
  }

  @override
  Future<void> close() async {
    await _sub?.cancel();
    return super.close();
  }
}
