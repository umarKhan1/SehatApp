import 'package:sehatapp/features/ai_chat/data/models/conversation_model.dart';
import 'package:sehatapp/features/ai_chat/data/models/message_model.dart';

enum AIChatStatus {
  initial, // First time, show starter view
  loading, // Loading conversation history
  ready, // Chat ready, show messages
  sending, // User message being sent
  receiving, // AI response streaming in
  error, // Error occurred
}

class AIChatState {
  const AIChatState({
    this.status = AIChatStatus.initial,
    this.conversation,
    this.messages = const [],
    this.error,
    this.topic,
    this.isFirstTime = true,
  });
  final AIChatStatus status;
  final ConversationModel? conversation;
  final List<MessageModel> messages;
  final String? error;
  final String? topic;
  final bool isFirstTime;

  AIChatState copyWith({
    AIChatStatus? status,
    ConversationModel? conversation,
    List<MessageModel>? messages,
    String? error,
    String? topic,
    bool? isFirstTime,
  }) {
    return AIChatState(
      status: status ?? this.status,
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      error: error,
      topic: topic ?? this.topic,
      isFirstTime: isFirstTime ?? this.isFirstTime,
    );
  }

  bool get isInitial => status == AIChatStatus.initial;
  bool get isLoading => status == AIChatStatus.loading;
  bool get isReady => status == AIChatStatus.ready;
  bool get isSending =>
      status == AIChatStatus.sending || status == AIChatStatus.receiving;
  bool get hasError => status == AIChatStatus.error;
}
