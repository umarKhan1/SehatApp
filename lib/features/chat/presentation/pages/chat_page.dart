import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sehatapp/core/localization/app_texts.dart';
import 'package:sehatapp/features/call/data/call_repository_impl.dart';
import 'package:sehatapp/features/call/domain/entities/call_session.dart';
import 'package:sehatapp/features/call/presentation/cubit/call_cubit.dart';
import 'package:sehatapp/features/call/presentation/pages/call_page.dart';
import 'package:sehatapp/features/chat/data/chat_repository.dart';
import 'package:sehatapp/features/chat/presentation/cubit/chat_cubit.dart';
import 'package:sehatapp/features/chat/presentation/widgets/message_actions_overlay.dart';
import 'package:sehatapp/features/chat/presentation/widgets/message_input_bar.dart';
import 'package:sehatapp/features/chat/presentation/widgets/message_list.dart';
import 'package:sehatapp/features/chat/presentation/widgets/reply_bar.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.title, this.otherUid});
  final String title;
  final String? otherUid;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
  final TextEditingController _ctrl = TextEditingController();
  final List<String> _reactionEmojis = const [
    '👍',
    '❤️',
    '😂',
    '😮',
    '😢',
    '🙏',
    '😡',
  ];

  bool _typing = false;
  bool _hasScrolledOnce = false;
  int _lastMessageCount = 0;
  OverlayEntry? _overlay;
  AnimationController? _overlayController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final other = widget.otherUid;
      if (mounted && other != null && other.isNotEmpty) {
        await context.read<ChatCubit>().init(
          otherUid: other,
          otherName: widget.title,
        );
        // Auto-scroll to bottom after messages load
        if (mounted) {
          // Small delay to ensure messages are rendered
          await Future.delayed(const Duration(milliseconds: 100));
          _scrollToBottom();
        }
      }
    });
  }

  void _onInputChanged() {
    final isTyping = _ctrl.text.trim().isNotEmpty;
    if (isTyping != _typing) {
      _typing = isTyping;
      context.read<ChatCubit>().setTyping(isTyping);
    }
    // Do NOT clear reply state here!
  }

  void _showAnimatedOverlay(
    BuildContext context, {
    required String messageId,
    required String preview,
    required bool isMe,
  }) {
    _dismissOverlay();

    final overlayState = Overlay.of(context, rootOverlay: true);

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _overlayController = controller;

    final scaleAnim = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));
    final fadeAnim = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeIn));

    controller.forward();

    _overlay = OverlayEntry(
      builder: (_) => AnimatedBuilder(
        animation: controller,
        builder: (context, child) {
          return MessageActionsOverlay(
            preview: preview,
            isMe: isMe,
            reactionEmojis: _reactionEmojis,
            scaleAnim: scaleAnim,
            fadeAnim: fadeAnim,
            onDismiss: _dismissOverlay,
            onReact: (emoji) => context.read<ChatCubit>().react(
              messageId: messageId,
              emoji: emoji,
            ),
            onReply: () {
              context.read<ChatCubit>().startReply(
                messageId: messageId,
                preview: preview,
              );
              WidgetsBinding.instance.addPostFrameCallback(
                (_) => _scrollToBottom(animated: true),
              );
            },
            onDelete: isMe
                ? () => context.read<ChatCubit>().deleteMessage(messageId)
                : null,
          );
        },
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _overlay != null) {
        overlayState.insert(_overlay!);
      }
    });
  }

  void _dismissOverlay() {
    _overlay?.remove();
    _overlay = null;
    _overlayController?.dispose();
    _overlayController = null;
  }

  void _startCall({required bool video}) {
    final target = widget.otherUid;
    if (target == null || target.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot start call: missing recipient')),
      );
      return;
    }
    CallCubit? existingCubit;
    try {
      existingCubit = BlocProvider.of<CallCubit>(context);
    } catch (_) {}

    if (existingCubit != null) {
      existingCubit.startOutgoing(
        calleeUid: target,
        calleeName: widget.title,
        type: video ? CallType.video : CallType.audio,
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider.value(
            value: existingCubit!,
            child: const CallPage(),
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => BlocProvider<CallCubit>(
            create: (_) {
              final chatRepo = RepositoryProvider.of<ChatRepository>(context);
              return CallCubit(CallRepository(), chatRepo: chatRepo)
                ..startOutgoing(
                  calleeUid: target,
                  calleeName: widget.title,
                  type: video ? CallType.video : CallType.audio,
                );
            },
            child: const CallPage(),
          ),
        ),
      );
    }
  }

  void _scrollToBottom({bool animated = false}) {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position.maxScrollExtent;
    if (animated) {
      _scrollController.animateTo(
        position,
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
      );
    } else {
      _scrollController.jumpTo(position);
    }
  }

  @override
  void dispose() {
    _dismissOverlay();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tx = AppTexts.of(context);
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.call),
                        tooltip: 'Voice call',
                        onPressed: () => _startCall(video: false),
                      ),
                      IconButton(
                        icon: const Icon(Icons.videocam),
                        tooltip: 'Video call',
                        onPressed: () => _startCall(video: true),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: BlocBuilder<ChatCubit, ChatState>(
                builder: (context, state) {
                  if (state.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.messages.length != _lastMessageCount) {
                    _lastMessageCount = state.messages.length;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _scrollToBottom(animated: _hasScrolledOnce);
                      _hasScrolledOnce = true;
                    });
                  }
                  final currentUid = FirebaseAuth.instance.currentUser?.uid;
                  final currentName =
                      FirebaseAuth.instance.currentUser?.displayName;
                  return ChatMessageList(
                    messages: state.messages,
                    title: widget.title,
                    otherUid: state.otherUid ?? widget.otherUid,
                    currentUserUid: currentUid,
                    currentUserName: currentName,
                    lastReadAtOther: state.lastReadAtOther,
                    scrollController: _scrollController,
                    highlightedMessageId: state.highlightedMessageId,
                    onLongPressMessage: (message, isMe) {
                      _showAnimatedOverlay(
                        context,
                        messageId: message.id,
                        preview: message.text,
                        isMe: isMe,
                      );
                    },
                    onHighlightRequest: (id) =>
                        context.read<ChatCubit>().highlightMessage(id),
                    onSwipeReply: (message) {
                      final preview = (message.text.isNotEmpty)
                          ? message.text
                          : 'Message';
                      context.read<ChatCubit>().startReply(
                        messageId: message.id,
                        preview: preview,
                      );
                      context.read<ChatCubit>().highlightMessage(message.id);
                      WidgetsBinding.instance.addPostFrameCallback(
                        (_) => _scrollToBottom(animated: true),
                      );
                    },
                    onCallLogTap: (message) {
                      final callData = message.metadata?['call'];
                      if (callData != null) {
                        final type = callData['type'] as String? ?? 'audio';
                        _startCall(video: type == 'video');
                      }
                    },
                  );
                },
              ),
            ),
            BlocBuilder<ChatCubit, ChatState>(
              builder: (context, state) {
                if (state.replyToMessageId == null) {
                  return const SizedBox.shrink();
                }
                final currentUid = FirebaseAuth.instance.currentUser?.uid;
                final replyMsg = state.messages.firstWhere(
                  (m) => m.id == state.replyToMessageId,
                  orElse: () => MessageItem(
                    id: '',
                    fromUid: '',
                    toUid: '',
                    text: '',
                    createdAt: Timestamp.now(),
                    status: '',
                  ),
                );
                final myName = FirebaseAuth.instance.currentUser?.displayName;
                final replyTitle = replyMsg.id.isNotEmpty
                    ? (replyMsg.fromUid == currentUid
                          ? (myName?.isNotEmpty == true ? myName! : 'You')
                          : widget.title)
                    : widget.title;
                final displayTitle = replyTitle.isEmpty
                    ? widget.title
                    : replyTitle;
                return ReplyBar(
                  title: displayTitle,
                  preview: state.replyPreviewText ?? '',
                  onCancel: () => context.read<ChatCubit>().cancelReply(),
                );
              },
            ),
            MessageInputBar(
              controller: _ctrl,
              hintText: tx.typeMessageHint,
              onChanged: _onInputChanged,
              onSend: () async {
                final text = _ctrl.text.trim();
                if (text.isEmpty) return;
                await context.read<ChatCubit>().send(text);
                _ctrl.clear();
                _onInputChanged();
              },
            ),
          ],
        ),
      ),
    );
  }
}
