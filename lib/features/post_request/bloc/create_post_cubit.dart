import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatapp/features/post_request/data/post_repository.dart';

class CreatePostState {
  const CreatePostState({this.loading = false, this.error, this.postId});
  final bool loading;
  final String? error;
  final String? postId;
  CreatePostState copyWith({bool? loading, String? error, String? postId}) =>
      CreatePostState(loading: loading ?? this.loading, error: error, postId: postId ?? this.postId);
}

class CreatePostCubit extends Cubit<CreatePostState> {
  CreatePostCubit({required this.repo}) : super(const CreatePostState());
  final PostRepository repo;

  Future<void> submit(Map<String, dynamic> data) async {
    emit(state.copyWith(loading: true));
    try {
      final id = await repo.createPost(data);
      emit(state.copyWith(loading: false, postId: id));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
