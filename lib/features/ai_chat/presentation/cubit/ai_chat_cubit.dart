// ignore: depend_on_referenced_packages
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sehatapp/features/ai_chat/data/models/conversation_model.dart';
import 'package:sehatapp/features/ai_chat/data/models/message_model.dart';
import 'package:sehatapp/features/ai_chat/data/repositories/ai_repository.dart';
import 'package:sehatapp/features/ai_chat/presentation/cubit/ai_chat_state.dart';

class AIChatCubit extends Cubit<AIChatState> {
  AIChatCubit(this.context, {AIRepository? repository})
    : _repository = repository ?? AIRepository(),
      super(const AIChatState());
  final AIRepository _repository;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final BuildContext context;

  // Load conversation (existing or new)
  Future<void> loadConversation() async {
    try {
      emit(state.copyWith(status: AIChatStatus.loading));

      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        emit(
          state.copyWith(
            status: AIChatStatus.error,
            error: 'User not authenticated',
          ),
        );
        return;
      }

      // Try to load latest conversation
      final conversation = await _repository.getLatestConversation(userId);

      if (conversation != null && conversation.messages.isNotEmpty) {
        // Existing conversation
        emit(
          state.copyWith(
            status: AIChatStatus.ready,
            conversation: conversation,
            messages: conversation.messages,
            isFirstTime: false,
          ),
        );
      } else {
        // New conversation - show starter view
        emit(state.copyWith(status: AIChatStatus.initial, isFirstTime: true));
      }
    } catch (e) {
      emit(state.copyWith(status: AIChatStatus.error, error: e.toString()));
    }
  }

  // Select topic (first time)
  void selectTopic(String topic) {
    emit(
      state.copyWith(
        topic: topic,
        status: AIChatStatus.ready,
        isFirstTime: false,
      ),
    );
  }

  // Send message
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        emit(
          state.copyWith(
            status: AIChatStatus.error,
            error: 'User not authenticated',
          ),
        );
        return;
      }

      // Create user message
      final userMessage = MessageModel.user(text: text.trim());

      // Add user message to list
      final updatedMessages = [...state.messages, userMessage];
      emit(
        state.copyWith(messages: updatedMessages, status: AIChatStatus.sending),
      );

      // Create or update conversation
      ConversationModel conversation;
      if (state.conversation == null) {
        conversation = ConversationModel.create(
          userId: userId,
          topic: state.topic,
        );
      } else {
        conversation = state.conversation!;
      }

      // Add thinking indicator
      final thinkingMessage = MessageModel.thinking();
      final messagesWithThinking = [...updatedMessages, thinkingMessage];
      emit(
        state.copyWith(
          messages: messagesWithThinking,
          status: AIChatStatus.receiving,
        ),
      );

      // Get AI response (streaming)
      final languageCode = Localizations.localeOf(context).languageCode;
      final responseStream = _repository.sendMessage(
        message: text.trim(),
        history: updatedMessages,
        topic: state.topic,
        languageCode: languageCode,
      );

      String fullResponse = '';
      await for (final chunk in responseStream) {
        fullResponse += chunk;

        // Update the thinking message with partial response
        final partialMessage = MessageModel.assistant(
          text: fullResponse,
          id: thinkingMessage.id,
          status: MessageStatus.sending,
        );

        final updatedMessagesWithPartial = [...updatedMessages, partialMessage];

        emit(
          state.copyWith(
            messages: updatedMessagesWithPartial,
            status: AIChatStatus.receiving,
          ),
        );
      }

      // Final assistant message
      final assistantMessage = MessageModel.assistant(
        text: fullResponse,
        id: thinkingMessage.id,
      );

      final finalMessages = [...updatedMessages, assistantMessage];

      // Update conversation
      final updatedConversation = conversation.copyWith(
        messages: finalMessages,
        updatedAt: DateTime.now(),
        title: conversation.messages.isEmpty
            ? conversation.generateTitle()
            : conversation.title,
      );

      // Save to Firestore
      await _repository.saveConversation(updatedConversation);

      emit(
        state.copyWith(
          conversation: updatedConversation,
          messages: finalMessages,
          status: AIChatStatus.ready,
        ),
      );
    } catch (e) {
      // Show error message
      final errorMessage = MessageModel.assistant(
        text: 'Something went wrong. Tap to retry.',
        status: MessageStatus.error,
      );

      final messagesWithError = [
        ...state.messages.where((m) => !m.isThinking),
        errorMessage,
      ];

      emit(
        state.copyWith(
          messages: messagesWithError,
          status: AIChatStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  // Retry failed message
  Future<void> retryMessage(String messageId) async {
    // Find the failed message
    final failedMessage = state.messages.firstWhere(
      (m) => m.id == messageId && m.hasError,
      orElse: () => state.messages.last,
    );

    // Find the user message before it
    final messageIndex = state.messages.indexOf(failedMessage);
    if (messageIndex > 0) {
      final previousMessage = state.messages[messageIndex - 1];
      if (previousMessage.isUser) {
        // Remove failed message and retry
        final messagesWithoutFailed = state.messages
            .where((m) => m.id != messageId)
            .toList();

        emit(state.copyWith(messages: messagesWithoutFailed));
        await sendMessage(previousMessage.text);
      }
    }
  }

  // Clear chat and start new conversation
  Future<void> clearChat() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    // Delete current conversation if exists
    if (state.conversation != null) {
      await _repository.deleteConversation(state.conversation!.id);
    }

    // Reset to initial state
    emit(const AIChatState());
  }

  // Quick action selected
  Future<void> selectQuickAction(String action) async {
    String prompt = '';

    // Handle both old action codes and new full labels
    if (action.contains('Blood donation') || action == 'blood_donation') {
      prompt = 'I need help with blood donation guidance';
    } else if (action.contains('Health advice') || action == 'health_advice') {
      prompt = 'I need general health advice';
    } else if (action.contains('Summarize') || action == 'summarize') {
      prompt = 'Can you help me summarize some text?';
    } else if (action.contains('Translation') || action == 'translate') {
      prompt = 'I need help translating something';
    } else if (action.contains('improve') || action.contains('Write')) {
      prompt = 'Can you help me improve my writing?';
    } else if (action.contains('Brainstorm') || action == 'brainstorm') {
      prompt = 'I need help brainstorming ideas';
    } else if (action.contains('Analyze') || action == 'analyze') {
      prompt = 'Can you help me analyze some data?';
    }

    if (prompt.isNotEmpty) {
      await sendMessage(prompt);
    }
  }
}
