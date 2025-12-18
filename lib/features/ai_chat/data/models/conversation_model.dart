import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatapp/features/ai_chat/data/models/message_model.dart';

class ConversationModel {
  // Create a new conversation
  factory ConversationModel.create({required String userId, String? topic}) {
    final now = DateTime.now();
    return ConversationModel(
      id: 'conv_${now.millisecondsSinceEpoch}',
      userId: userId,
      title: 'New Chat',
      createdAt: now,
      updatedAt: now,
      topic: topic,
      messages: [],
    );
  }
  // Create from Firestore map
  factory ConversationModel.fromFirestore(
    Map<String, dynamic> data, {
    List<MessageModel>? messages,
  }) {
    return ConversationModel(
      id: data['id'] as String,
      userId: data['userId'] as String,
      title: data['title'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      topic: data['topic'] as String?,
      messages: messages ?? [],
    );
  }
  const ConversationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.topic,
    this.messages = const [],
  });
  final String id;
  final String userId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? topic; // 'blood_donation', 'health', 'both'
  final List<MessageModel> messages;

  // Create a copy with updated fields
  ConversationModel copyWith({
    String? id,
    String? userId,
    String? title,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? topic,
    List<MessageModel>? messages,
  }) {
    return ConversationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      topic: topic ?? this.topic,
      messages: messages ?? this.messages,
    );
  }

  // Convert to Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      if (topic != null) 'topic': topic,
    };
  }

  // Generate title from first message
  String generateTitle() {
    if (messages.isEmpty) return 'New Chat';
    final firstUserMessage = messages.firstWhere(
      (m) => m.role == MessageRole.user,
      orElse: () => messages.first,
    );
    final text = firstUserMessage.text;
    return text.length > 30 ? '${text.substring(0, 30)}...' : text;
  }
}
