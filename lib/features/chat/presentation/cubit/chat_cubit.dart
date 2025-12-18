import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatapp/core/services/network_service.dart';
import 'package:sehatapp/features/auth/data/user_repository.dart';
import 'package:sehatapp/features/chat/data/chat_repository.dart';

class ChatState {
  const ChatState({
    this.loading = false,
    this.error,
    this.conversationId,
    this.otherUid,
    this.messages = const [],
    this.typingOther = false,
    this.lastReadAtOther,
    this.replyToMessageId,
    this.replyPreviewText,
    this.highlightedMessageId,
  });
  static const _keep = Object();
  final bool loading;
  final String? error;
  final String? conversationId;
  final String? otherUid;
  final List<MessageItem> messages;
  final bool typingOther;
  final DateTime? lastReadAtOther;
  final String? replyToMessageId;
  final String? replyPreviewText;
  final String? highlightedMessageId;
  ChatState copyWith({
    bool? loading,
    String? error,
    String? conversationId,
    String? otherUid,
    List<MessageItem>? messages,
    bool? typingOther,
    DateTime? lastReadAtOther,
    Object? replyToMessageId = _keep,
    Object? replyPreviewText = _keep,
    Object? highlightedMessageId = _keep,
  }) => ChatState(
    loading: loading ?? this.loading,
    error: error,
    conversationId: conversationId ?? this.conversationId,
    otherUid: otherUid ?? this.otherUid,
    messages: messages ?? this.messages,
    typingOther: typingOther ?? this.typingOther,
    lastReadAtOther: lastReadAtOther ?? this.lastReadAtOther,
    replyToMessageId: replyToMessageId == _keep
        ? this.replyToMessageId
        : replyToMessageId as String?,
    replyPreviewText: replyPreviewText == _keep
        ? this.replyPreviewText
        : replyPreviewText as String?,
    highlightedMessageId: highlightedMessageId == _keep
        ? this.highlightedMessageId
        : highlightedMessageId as String?,
  );
}

class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this.repo, this.userRepo) : super(const ChatState());
  final ChatRepository repo;
  final IUserRepository userRepo;
  StreamSubscription<List<MessageItem>>? _sub;
  StreamSubscription? _convSub;
  bool _sending = false;
  Timer? _highlightTimer;

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  // Cache reply state to avoid closure issues
  String? _replyToMessageId;
  String? _replyPreviewText;

  // Network status subscription for auto-sending pending messages
  StreamSubscription<bool>? _networkSub;

  Future<void> init({required String otherUid, String? otherName}) async {
    final uid = _uid;
    if (uid == null) {
      emit(state.copyWith(error: 'Not logged in'));
      return;
    }
    emit(state.copyWith(loading: true));

    // Listen to network status changes to auto-send pending messages
    _networkSub?.cancel();
    _networkSub = NetworkService().connectivityStream.listen((isConnected) {
      if (isConnected) {
        _sendPendingMessages();
      }
    });
    // Fetch display names
    final meDoc = await userRepo.getUserWithCache(uid);
    final otherDoc = await userRepo.getUserWithCache(otherUid);
    final myName = (meDoc['name'] ?? '') as String;
    final otherDisplayName = (otherDoc['name'] ?? otherName ?? '') as String;
    final convId = await repo.getOrCreateConversation(
      a: uid,
      b: otherUid,
      aName: myName,
      bName: otherDisplayName,
    );
    emit(
      state.copyWith(
        conversationId: convId,
        otherUid: otherUid,
        // Always preserve reply state on init
        replyToMessageId: _replyToMessageId,
        replyPreviewText: _replyPreviewText,
      ),
    );
    _sub?.cancel();
    _sub = repo.streamMessages(convId).listen(
      (msgs) {
        final prev = {for (final m in state.messages) m.id: m};
        final merged = msgs.map((m) {
          final prevItem = prev[m.id];
          final reactions = m.reactions.isNotEmpty
              ? m.reactions
              : (prevItem?.reactions ?? m.reactions);
          return MessageItem(
            id: m.id,
            fromUid: m.fromUid,
            toUid: m.toUid,
            text: m.text,
            createdAt: m.createdAt,
            status: m.status,
            reactions: reactions,
            replyToMessageId: m.replyToMessageId,
            replyPreviewText: m.replyPreviewText,
            type: m.type,
            metadata: m.metadata,
          );
        }).toList();
        // Always persist reply state using private fields
        emit(
          state.copyWith(
            loading: false,
            messages: merged,
            replyToMessageId: _replyToMessageId,
            replyPreviewText: _replyPreviewText,
            highlightedMessageId: state.highlightedMessageId,
          ),
        );
      },
      onError: (e) => emit(state.copyWith(loading: false, error: e.toString())),
    );
    // Listen to conversation doc for lastReadAt updates
    _convSub?.cancel();
    _convSub = repo.streamConversation(convId).listen((snap) {
      final data = snap.data();
      if (data == null) return;
      final other = otherUid;
      final lastReadMap = (data['lastReadAt'] ?? {}) as Map<String, dynamic>;
      final ts = lastReadMap[other];
      DateTime? dt;
      if (ts is Timestamp) dt = ts.toDate();
      emit(
        state.copyWith(
          lastReadAtOther: dt,
          replyToMessageId: _replyToMessageId,
          replyPreviewText: _replyPreviewText,
          highlightedMessageId: state.highlightedMessageId,
        ),
      );
    });
    // Mark messages as read when opening
    await repo.markRead(conversationId: convId, readerUid: uid);
  }

  /// Retry loading conversation (called when user taps retry button)
  Future<void> retry({required String otherUid, String? otherName}) async {
    await init(otherUid: otherUid, otherName: otherName);
  }

  Future<void> send(String text) async {
    if (_sending) return; // guard against double taps
    _sending = true;
    try {
      final uid = _uid;
      final convId = state.conversationId;
      final otherUid = state.otherUid;
      if (uid == null ||
          convId == null ||
          otherUid == null ||
          text.trim().isEmpty) {
        return;
      }

      // Check network connectivity
      final isConnected = await NetworkService().isConnected;

      if (!isConnected) {
        // Add message to UI with 'pending' status
        final pendingMessage = MessageItem(
          id: 'pending_${DateTime.now().millisecondsSinceEpoch}',
          fromUid: uid,
          toUid: otherUid,
          text: text.trim(),
          createdAt: Timestamp.now(),
          status: 'pending', // Special status for offline messages
          replyToMessageId: _replyToMessageId,
          replyPreviewText: _replyPreviewText,
        );

        // Add to current messages
        final updatedMessages = [...state.messages, pendingMessage];
        emit(state.copyWith(messages: updatedMessages));

        // Clear reply state
        _replyToMessageId = null;
        _replyPreviewText = null;
        emit(state.copyWith(replyToMessageId: null, replyPreviewText: null));
        return;
      }

      // Online - send normally
      await repo.sendMessage(
        conversationId: convId,
        fromUid: uid,
        toUid: otherUid,
        text: text.trim(),
        replyToMessageId: _replyToMessageId,
        replyPreviewText: _replyPreviewText,
      );
      _replyToMessageId = null;
      _replyPreviewText = null;
      emit(state.copyWith(replyToMessageId: null, replyPreviewText: null));
    } finally {
      _sending = false;
    }
  }

  void startReply({required String messageId, required String preview}) {
    _replyToMessageId = messageId;
    _replyPreviewText = preview;
    emit(
      state.copyWith(replyToMessageId: messageId, replyPreviewText: preview),
    );
  }

  void cancelReply() {
    _replyToMessageId = null;
    _replyPreviewText = null;
    emit(state.copyWith(replyToMessageId: null, replyPreviewText: null));
  }

  Future<void> react({required String messageId, required String emoji}) async {
    final convId = state.conversationId;
    final uid = _uid;
    if (convId == null || uid == null) return;
    final currentMessages = List<MessageItem>.from(state.messages);
    final idx = currentMessages.indexWhere((m) => m.id == messageId);
    MessageItem? target = idx == -1 ? null : currentMessages[idx];
    final currentEmoji = target?.reactions[uid];
    final nextEmoji = currentEmoji == emoji ? null : emoji;

    // optimistic update so UI shows immediately
    if (target != null) {
      final newReactions = Map<String, String>.from(target.reactions);
      if (nextEmoji == null) {
        newReactions.remove(uid);
      } else {
        newReactions[uid] = nextEmoji;
      }
      currentMessages[idx] = MessageItem(
        id: target.id,
        fromUid: target.fromUid,
        toUid: target.toUid,
        text: target.text,
        createdAt: target.createdAt,
        status: target.status,
        reactions: newReactions,
        replyToMessageId: target.replyToMessageId,
        replyPreviewText: target.replyPreviewText,
        type: target.type,
        metadata: target.metadata,
      );
      emit(
        state.copyWith(
          messages: currentMessages,
          replyToMessageId: _replyToMessageId,
          replyPreviewText: _replyPreviewText,
        ),
      );
    }

    await repo.reactToMessage(
      conversationId: convId,
      messageId: messageId,
      emoji: nextEmoji,
      userUid: uid,
    );
  }

  Future<void> deleteMessage(String messageId) async {
    final convId = state.conversationId;
    final uid = _uid;
    if (convId == null || uid == null) return;
    await repo.deleteMessage(
      conversationId: convId,
      messageId: messageId,
      requesterUid: uid,
    );
  }

  Future<void> reportMessage(
    String messageId, {
    String reason = 'inappropriate',
  }) async {
    final convId = state.conversationId;
    if (convId == null) return;
    await repo.reportMessage(
      conversationId: convId,
      messageId: messageId,
      reason: reason,
    );
  }

  Future<void> setTyping(bool isTyping) async {
    final uid = _uid;
    final convId = state.conversationId;
    if (uid == null || convId == null) return;
    emit(
      state.copyWith(
        typingOther: isTyping,
        replyToMessageId: _replyToMessageId,
        replyPreviewText: _replyPreviewText,
      ),
    );
    await repo.setTyping(conversationId: convId, uid: uid, typing: isTyping);
  }

  @override
  Future<void> close() async {
    _highlightTimer?.cancel();
    await _sub?.cancel();
    await _convSub?.cancel();
    await _networkSub?.cancel();
    return super.close();
  }

  /// Send all pending messages when connection is restored
  Future<void> _sendPendingMessages() async {
    final uid = _uid;
    final convId = state.conversationId;
    final otherUid = state.otherUid;

    if (uid == null || convId == null || otherUid == null) return;

    // Find all pending messages
    final pendingMessages = state.messages
        .where((m) => m.status == 'pending')
        .toList();

    if (pendingMessages.isEmpty) return;

    // Send each pending message
    for (final msg in pendingMessages) {
      try {
        await repo.sendMessage(
          conversationId: convId,
          fromUid: uid,
          toUid: otherUid,
          text: msg.text,
          replyToMessageId: msg.replyToMessageId,
          replyPreviewText: msg.replyPreviewText,
        );

        // Remove pending message from state (Firestore will add the real one)
        final updatedMessages = state.messages
            .where((m) => m.id != msg.id)
            .toList();
        emit(state.copyWith(messages: updatedMessages));
      } catch (e) {
        // If sending fails, keep the pending message
        continue;
      }
    }
  }

  void highlightMessage(
    String? id, {
    Duration duration = const Duration(milliseconds: 900),
  }) {
    _highlightTimer?.cancel();
    emit(
      state.copyWith(
        highlightedMessageId: id,
        replyToMessageId: _replyToMessageId,
        replyPreviewText: _replyPreviewText,
      ),
    );
    if (id != null) {
      _highlightTimer = Timer(duration, () {
        final current = state.highlightedMessageId;
        if (current == id) {
          emit(
            state.copyWith(
              highlightedMessageId: null,
              replyToMessageId: _replyToMessageId,
              replyPreviewText: _replyPreviewText,
            ),
          );
        }
      });
    }
  }
}
