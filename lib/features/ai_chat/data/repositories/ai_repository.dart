import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sehatapp/core/network/http_client.dart';
import 'package:sehatapp/core/network/http_exception.dart';
import 'package:sehatapp/features/ai_chat/data/models/conversation_model.dart';
import 'package:sehatapp/features/ai_chat/data/models/message_model.dart';

class AIRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final HttpClient _httpClient = HttpClient();

  // Send message and get streaming response
  Stream<String> sendMessage({
    required String message,
    required List<MessageModel> history,
    required String languageCode,
    String? topic,
  }) async* {
    try {
      // Get API key
      final apiKey = dotenv.env['GEMINI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        throw const HttpException('GEMINI_API_KEY not found in .env file');
      }

      // Build request with system instruction
      final systemPrompt = _getSystemPrompt(
        topic: topic,
        languageCode: languageCode,
      );

      // Build conversation history for the model, excluding system messages
      final chatHistory = history
          .where((m) => m.role != MessageRole.system)
          .map(
            (m) => {
              'role': m.role == MessageRole.user ? 'user' : 'model',
              'parts': [
                {'text': m.text},
              ],
            },
          )
          .toList();

      final contents = [
        {
          'role': 'user',
          'parts': [
            {'text': systemPrompt},
          ],
        },
        ...chatHistory,
        {
          'role': 'user',
          'parts': [
            {'text': message},
          ],
        },
      ];

      final url =
          'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:streamGenerateContent?alt=sse&key=$apiKey';

      final body = {
        'contents': contents,
        'generationConfig': {'temperature': 0.7, 'maxOutputTokens': 800},
      };

      // Use HTTP client for streaming
      await for (final chunk in _httpClient.postStream(
        url: url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      )) {
        // Parse SSE format
        final lines = chunk.split('\n');
        for (final line in lines) {
          if (line.startsWith('data: ')) {
            try {
              final jsonStr = line.substring(6);
              if (jsonStr.trim() == '[DONE]') continue;

              final data = jsonDecode(jsonStr);
              final text =
                  data['candidates']?[0]?['content']?['parts']?[0]?['text']
                      as String?;

              if (text != null && text.isNotEmpty) {
                yield text;
              }
            } catch (e) {
              // Skip invalid JSON lines
              if (kDebugMode) {
                print('[AIRepository] Skipping invalid chunk: $e');
              }
            }
          }
        }
      }
    } on NetworkException {
      throw Exception(
        'No internet connection. Please check your network and try again.',
      );
    } on TimeoutException {
      throw Exception('Request timeout. Please try again.');
    } on ClientException catch (e) {
      throw Exception('API error: ${e.message}');
    } on ServerException catch (e) {
      throw Exception('Server error: ${e.message}');
    } catch (e) {
      if (kDebugMode) {
        print('[AIRepository] ERROR: $e');
      }
      throw Exception('Failed to get AI response: $e');
    }
  }

  // System prompt for AI behavior
  String _getSystemPrompt({String? topic, required String languageCode}) {
    // Map language codes to language names
    final languageNames = {
      'en': 'English',
      'hi': 'Hindi (हिंदी)',
      'ur': 'Urdu (اردو)',
      'ar': 'Arabic (العربية)',
    };

    final languageName = languageNames[languageCode] ?? 'English';

    return '''
You are a helpful AI assistant for SehatApp, a blood donation and health guidance platform.

IMPORTANT: Respond ONLY in $languageName language. All your responses must be in $languageName.

Your primary focus:
- Blood donation guidance (eligibility, frequency, preparation, recovery)
- General health advice (non-diagnostic)

IMPORTANT RESPONSE GUIDELINES:
1. Keep responses SHORT and CONCISE (3-5 sentences max for simple questions)
2. Use bullet points and numbered lists for clarity
3. Use **bold** for important terms
4. Use ### for section headers when needed
5. Be conversational and friendly
6. Ask follow-up questions when needed (age, symptoms, medications, last donation date)
7. NEVER provide medical diagnoses
8. For urgent symptoms: "⚠️ Contact emergency services immediately"
9. Use emojis sparingly for emphasis (✓, ⚠️, 💡)

${topic != null ? 'Topic context: $topic' : ''}

Remember: BREVITY is key. Give direct, actionable answers in $languageName.
''';
  }

  // Save conversation to Firestore
  Future<void> saveConversation(ConversationModel conversation) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final conversationRef = _firestore
        .collection('ai_conversations')
        .doc(conversation.id);

    // Save conversation metadata
    await conversationRef.set(conversation.toFirestore());

    // Save messages as subcollection
    final messagesRef = conversationRef.collection('messages');
    for (final message in conversation.messages) {
      await messagesRef.doc(message.id).set(message.toFirestore());
    }
  }

  // Get latest conversation for user
  Future<ConversationModel?> getLatestConversation(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('ai_conversations')
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final doc = querySnapshot.docs.first;
      final conversation = ConversationModel.fromFirestore(doc.data());

      // Load messages
      final messagesSnapshot = await doc.reference
          .collection('messages')
          .orderBy('createdAt')
          .get();

      final messages = messagesSnapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc.data()))
          .toList();

      return conversation.copyWith(messages: messages);
    } catch (e) {
      return null;
    }
  }

  // Get all conversations for user
  Future<List<ConversationModel>> getAllConversations(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('ai_conversations')
          .where('userId', isEqualTo: userId)
          .orderBy('updatedAt', descending: true)
          .get();

      final conversations = <ConversationModel>[];
      for (final doc in querySnapshot.docs) {
        final conversation = ConversationModel.fromFirestore(doc.data());

        // Load messages for each conversation
        final messagesSnapshot = await doc.reference
            .collection('messages')
            .orderBy('createdAt')
            .get();

        final messages = messagesSnapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc.data()))
            .toList();

        conversations.add(conversation.copyWith(messages: messages));
      }

      return conversations;
    } catch (e) {
      return [];
    }
  }

  // Delete conversation
  Future<void> deleteConversation(String conversationId) async {
    final conversationRef = _firestore
        .collection('ai_conversations')
        .doc(conversationId);

    // Delete all messages first
    final messagesSnapshot = await conversationRef.collection('messages').get();

    for (final doc in messagesSnapshot.docs) {
      await doc.reference.delete();
    }

    // Delete conversation
    await conversationRef.delete();
  }
}
