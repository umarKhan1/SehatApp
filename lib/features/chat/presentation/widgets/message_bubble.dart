import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    required this.createdAt,
    this.reactions = const {},
    this.lastReadAtOther,
    this.replySenderName,
    this.replyPreviewText,
    this.onReplyTap,
  });
  final String text;
  final bool isMe;
  final DateTime createdAt;
  final Map<String, String> reactions;
  final DateTime? lastReadAtOther;
  final String? replySenderName;
  final String? replyPreviewText;
  final VoidCallback? onReplyTap;

  @override
  Widget build(BuildContext context) {
    final bg = isMe ? const Color(0xFFE1FFC7) : const Color(0xFFE8F0FE); // clearer contrast for receiver
    final fg = Colors.black87;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final timeStr = _formatTime(createdAt);
    final isRead = lastReadAtOther != null && lastReadAtOther!.isAfter(createdAt);

    final reactionsRow = _buildReactions(context);

    return Column(
      crossAxisAlignment: align,
      children: [
        if (replySenderName != null && replyPreviewText != null)
          GestureDetector(
            onTap: onReplyTap,
            child: Container(
              margin: EdgeInsets.only(bottom: 2.h),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(replySenderName!, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange, fontSize: 13.sp)),
                  SizedBox(height: 2.h),
                  Text(replyPreviewText!, style: TextStyle(color: Colors.black87, fontSize: 13.sp)),
                ],
              ),
            ),
          ),
        Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 6.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                    bottomLeft: Radius.circular(isMe ? 12.r : 2.r),
                    bottomRight: Radius.circular(isMe ? 2.r : 12.r),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        text,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: fg),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeStr,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54, fontSize: 12.sp),
                        ),
                        if (isMe) ...[
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.done_all,
                            size: 16,
                            color: isRead ? const Color(0xFF34B7F1) : Colors.black38, // blue when read
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (reactionsRow != null) reactionsRow,
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:${dt.minute.toString().padLeft(2, '0')} $ampm';
  }

  Widget? _buildReactions(BuildContext context) {
    if (reactions.isEmpty) {
      return null;
    }
  
    final counts = <String, int>{};
    reactions.values.where((e) => e.isNotEmpty).forEach((emoji) {
      counts[emoji] = (counts[emoji] ?? 0) + 1;
    });
    if (counts.isEmpty) return null;
    final chips = counts.entries.map((e) {
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(e.key, style: const TextStyle(fontSize: 14)),
            SizedBox(width: 4.w),
            Text('${e.value}', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      );
    }).toList();

    return Padding(
      padding: EdgeInsets.only(left: isMe ? 0 : 6.w, right: isMe ? 6.w : 0),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 4.h),
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
            ),
            child: Wrap(
              spacing: 6.w,
              runSpacing: 4.h,
              children: chips,
            ),
          ),
        ],
      ),
    );
  }
}
