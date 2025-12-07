import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatapp/features/chat/data/chat_repository.dart';

class InboxState {
  const InboxState({this.loading = false, this.error, this.conversations = const []});
  final bool loading;
  final String? error;
  final List<ConversationSummary> conversations;
  InboxState copyWith({bool? loading, String? error, List<ConversationSummary>? conversations}) =>
      InboxState(loading: loading ?? this.loading, error: error, conversations: conversations ?? this.conversations);
}

class InboxCubit extends Cubit<InboxState> {
  InboxCubit(this.repo) : super(const InboxState());
  final ChatRepository repo;
  Stream<List<ConversationSummary>>? _stream;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  void start() {
    final uid = _uid;
    if (uid == null) {
      emit(state.copyWith(error: 'Not logged in'));
      return;
    }
    emit(state.copyWith(loading: true,));
    _stream = repo.streamInbox(uid);
    _stream!.listen(
      (items) => emit(state.copyWith(loading: false, conversations: items)),
      onError: (e) => emit(state.copyWith(loading: false, error: e.toString())),
    );
  }
}
