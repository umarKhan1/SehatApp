import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sehatapp/features/ai_chat/presentation/cubit/ai_chat_cubit.dart';
import 'package:sehatapp/features/ai_chat/presentation/cubit/ai_chat_state.dart';
import 'package:sehatapp/features/ai_chat/presentation/widgets/chat_input_bar.dart';
import 'package:sehatapp/features/ai_chat/presentation/widgets/message_bubble.dart';
import 'package:sehatapp/features/ai_chat/presentation/widgets/starter_view.dart';
import 'package:sehatapp/features/ai_chat/presentation/widgets/topic_selector_dialog.dart';

class AIChatPage extends StatefulWidget {
  const AIChatPage({super.key});

  @override
  State<AIChatPage> createState() => _AIChatPageState();
}

class _AIChatPageState extends State<AIChatPage> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<AIChatCubit>().loadConversation();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Future<void> _handleSend() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    _textController.clear();

    // Show topic selector on first message if needed
    final state = context.read<AIChatCubit>().state;
    if (state.topic == null && state.messages.isEmpty) {
      final topic = await showDialog<String>(
        context: context,
        builder: (context) => const TopicSelectorDialog(),
      );

      if (topic != null) {
        // ignore: use_build_context_synchronously
        context.read<AIChatCubit>().selectTopic(topic);
      }
    }

    await context.read<AIChatCubit>().sendMessage(text);

    // Scroll to bottom after sending
    Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Assistant'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Clear Chat'),
                  content: const Text(
                    'Are you sure you want to start a new conversation?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('Clear'),
                    ),
                  ],
                ),
              );

              if (confirm == true && mounted) {
                context.read<AIChatCubit>().clearChat();
              }
            },
          ),
        ],
      ),
      body: BlocConsumer<AIChatCubit, AIChatState>(
        listener: (context, state) {
          // Auto-scroll when new messages arrive
          if (state.messages.isNotEmpty) {
            Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
          }
        },
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.isInitial && state.isFirstTime) {
            return StarterView(
              onQuickAction: (action) {
                context.read<AIChatCubit>().selectQuickAction(action);
              },
            );
          }

          return Column(
            children: [
              // Messages list
              Expanded(
                child: state.messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 80.sp,
                              color: Colors.grey.shade300,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              'Start a conversation',
                              style: TextStyle(
                                fontSize: 18.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: EdgeInsets.all(16.w),
                        itemCount: state.messages.length,
                        itemBuilder: (context, index) {
                          final message = state.messages[index];
                          return MessageBubble(
                            message: message,
                            onRetry: () {
                              context.read<AIChatCubit>().retryMessage(
                                message.id,
                              );
                            },
                          );
                        },
                      ),
              ),

              // Input bar
              ChatInputBar(
                controller: _textController,
                onSend: _handleSend,
                enabled: !state.isSending,
              ),
            ],
          );
        },
      ),
    );
  }
}
