// ignore_for_file: avoid_redundant_argument_values

import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageRole { user, assistant, system }

enum MessageStatus { sending, done, error }

class MessageModel {
  // Create a loading/thinking message
  factory MessageModel.thinking() {
    return MessageModel(
      id: 'thinking_${DateTime.now().millisecondsSinceEpoch}',
      role: MessageRole.assistant,
      text: 'Thinking...',
      createdAt: DateTime.now(),
      status: MessageStatus.sending,
    );
  }

  // Create an assistant message
  factory MessageModel.assistant({
    required String text,
    String? id,
    MessageStatus status = MessageStatus.done,
  }) {
    return MessageModel(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.assistant,
      text: text,
      createdAt: DateTime.now(),
      status: status,
    );
  }
  // Create a user message
  factory MessageModel.user({required String text, String? id}) {
    return MessageModel(
      id: id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      role: MessageRole.user,
      text: text,
      createdAt: DateTime.now(),
      status: MessageStatus.done,
    );
  }
  // Create from Firestore map
  factory MessageModel.fromFirestore(Map<String, dynamic> data) {
    return MessageModel(
      id: data['id'] as String,
      role: MessageRole.values.firstWhere(
        (e) => e.name == data['role'],
        orElse: () => MessageRole.user,
      ),
      text: data['text'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      status: MessageStatus.values.firstWhere(
        (e) => e.name == (data['status'] ?? 'done'),
        orElse: () => MessageStatus.done,
      ),
      error: data['error'] as String?,
    );
  }
  const MessageModel({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
    this.status = MessageStatus.done,
    this.error,
  });
  final String id;
  final MessageRole role;
  final String text;
  final DateTime createdAt;
  final MessageStatus status;
  final String? error;

  // Create a copy with updated fields
  MessageModel copyWith({
    String? id,
    MessageRole? role,
    String? text,
    DateTime? createdAt,
    MessageStatus? status,
    String? error,
  }) {
    return MessageModel(
      id: id ?? this.id,
      role: role ?? this.role,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      error: error ?? this.error,
    );
  }

  // Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'role': role.name,
      'text': text,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.name,
      if (error != null) 'error': error,
    };
  }

  bool get isUser => role == MessageRole.user;
  bool get isAssistant => role == MessageRole.assistant;
  bool get isThinking => status == MessageStatus.sending;
  bool get hasError => status == MessageStatus.error;
}
