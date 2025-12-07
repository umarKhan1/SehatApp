import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sehatapp/core/theme/app_theme.dart';
import 'package:sehatapp/features/chat/data/chat_repository.dart';
import 'package:sehatapp/features/chat/presentation/widgets/message_bubble.dart';

class ChatMessageList extends StatefulWidget {
  const ChatMessageList({
    super.key,
    required this.messages,
    required this.title,
    required this.otherUid,
    required this.currentUserUid,
    required this.currentUserName,
    required this.lastReadAtOther,
    required this.scrollController,
    required this.onLongPressMessage,
    this.onSwipeReply,
    this.highlightedMessageId,
    this.onHighlightRequest,
  });

  final List<MessageItem> messages;
  final String title;
  final String? otherUid;
  final String? currentUserUid;
  final String? currentUserName;
  final DateTime? lastReadAtOther;
  final ScrollController scrollController;
  final void Function(MessageItem message, bool isMe) onLongPressMessage;
  final void Function(MessageItem message)? onSwipeReply;
  final String? highlightedMessageId;
  final void Function(String messageId)? onHighlightRequest;

  @override
  State<ChatMessageList> createState() => _ChatMessageListState();
}

class _ChatMessageListState extends State<ChatMessageList> {
  final Map<String, GlobalKey> _itemKeys = {};

  bool _isMe(String fromUid) => widget.currentUserUid != null && widget.currentUserUid == fromUid;

  GlobalKey _keyForMessage(String id) {
    return _itemKeys.putIfAbsent(id, () => GlobalKey(debugLabel: 'msg-$id'));
  }

  void _scrollToReply(String replyId) {
    final key = _itemKeys[replyId];
    final context = key?.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
      alignment: 0.3,
    );
    widget.onHighlightRequest?.call(replyId);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: widget.scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
      itemCount: widget.messages.length,
      itemBuilder: (context, i) {
        final m = widget.messages[i];
        final isMe = _isMe(m.fromUid);
        final bubbleText = m.status == 'deleted' ? 'This message was deleted' : m.text;
        final replyMsg = m.replyToMessageId != null
            ? widget.messages.firstWhere(
                (x) => x.id == m.replyToMessageId,
                orElse: () => MessageItem(
                  id: '',
                  fromUid: '',
                  toUid: '',
                  text: '',
                  createdAt: m.createdAt,
                  status: '',
                ),
              )
            : null;
        final replySenderName = (replyMsg != null && replyMsg.id.isNotEmpty)
            ? (replyMsg.fromUid == widget.currentUserUid
                ? (widget.currentUserName?.isNotEmpty == true ? widget.currentUserName! : 'You')
                : (replyMsg.fromUid == widget.otherUid ? widget.title : 'Unknown'))
            : null;
        final replyPreviewText = (replyMsg != null && replyMsg.id.isNotEmpty) ? replyMsg.text : null;
        final bubbleKey = _keyForMessage(m.id);
        final isHighlighted = widget.highlightedMessageId == m.id;
        return Dismissible(
          key: ValueKey('swipe-${m.id}'),
        
          resizeDuration: Duration.zero,
          movementDuration: const Duration(milliseconds: 160),
          dismissThresholds: const {
            DismissDirection.startToEnd: 0.18,
            DismissDirection.endToStart: 0.18,
          },
          confirmDismiss: (direction) async {
            if (m.status == 'deleted' || widget.onSwipeReply == null) return false;
            widget.onSwipeReply!(m);
            return false; // keep the item in place
          },
          background: Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 12.w),
              child: Row(
                children: [
                  Icon(Icons.reply, color: AppTheme.primary, size: 24.sp),
                  SizedBox(width: 6.w),
                  Text('Reply', style: TextStyle(color: AppTheme.primary, fontSize: 13.sp)),
                ],
              ),
            ),
          ),
          secondaryBackground: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 12.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Reply', style: TextStyle(color: AppTheme.primary, fontSize: 13.sp)),
                  SizedBox(width: 6.w),
                  Icon(Icons.reply, color: AppTheme.primary, size: 24.sp),
                ],
              ),
            ),
          ),
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            key: ValueKey(m.id),
            onLongPress: () {
              if (m.status == 'deleted') return;
              widget.onLongPressMessage(m, isMe);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                color: isHighlighted ? Colors.yellow.withValues(alpha: .15) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: MessageBubble(
                key: bubbleKey,
                text: bubbleText,
                isMe: isMe,
                createdAt: m.createdAt.toDate(),
                reactions: m.reactions,
                lastReadAtOther: widget.lastReadAtOther,
                replySenderName: replySenderName,
                replyPreviewText: replyPreviewText,
                onReplyTap: (m.replyToMessageId != null && replyMsg != null && replyMsg.id.isNotEmpty)
                    ? () => _scrollToReply(m.replyToMessageId!)
                    : null,
              ),
            ),
          ),
        );
      },
    );
  }
}
