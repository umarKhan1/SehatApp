import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.text,
    required this.isMe,
    required this.createdAt,
    this.status = 'sent',
    this.reactions = const {},
    this.lastReadAtOther,
    this.replySenderName,
    this.replyPreviewText,
    this.onReplyTap,
    this.type,
    this.metadata,
    this.onTap,
  });
  final String text;
  final bool isMe;
  final DateTime createdAt;
  final String status;
  final Map<String, String> reactions;
  final DateTime? lastReadAtOther;
  final String? replySenderName;
  final String? replyPreviewText;
  final VoidCallback? onReplyTap;
  final String? type;
  final Map<String, dynamic>? metadata;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (type == 'call_log' && metadata != null) {
      return _buildCallLogBubble(context);
    }

    final bg = isMe
        ? const Color(0xFFE1FFC7)
        : const Color(0xFFE8F0FE); // clearer contrast for receiver
    final fg = Colors.black87;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final timeStr = _formatTime(createdAt);
    final isRead =
        lastReadAtOther != null && lastReadAtOther!.isAfter(createdAt);

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
                  Text(
                    replySenderName!,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                      fontSize: 13.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    replyPreviewText!,
                    style: TextStyle(color: Colors.black87, fontSize: 13.sp),
                  ),
                ],
              ),
            ),
          ),
        Row(
          mainAxisAlignment: isMe
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
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
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: fg),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeStr,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.black54,
                                fontSize: 12.sp,
                              ),
                        ),
                        if (isMe) ...[
                          SizedBox(width: 4.w),
                          if (status == 'pending')
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.black38,
                                ),
                              ),
                            )
                          else
                            Icon(
                              Icons.done_all,
                              size: 16,
                              color: isRead
                                  ? const Color(0xFF34B7F1)
                                  : Colors.black38, // blue when read
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

  Widget _buildCallLogBubble(BuildContext context) {
    final callData = metadata?['call'] as Map<String, dynamic>? ?? {};
    final callType = callData['type'] as String? ?? 'audio'; // audio | video
    final outcome = callData['outcome'] as String? ?? 'ended';
    final durationSeconds = (callData['durationSeconds'] as num? ?? 0).toInt();
    final direction = callData['direction'] as String? ?? 'outgoing';

    // Parse status text and icon
    final isVideo = callType == 'video';
    final title = isVideo ? 'Video call' : 'Voice call';

    String subtitle;
    IconData statusIcon;
    Color statusColor = Colors.red; // Default for missed/declined

    if (outcome == 'missed') {
      subtitle = 'Missed call';
      statusIcon = Icons.call_missed;
    } else if (outcome == 'rejected') {
      subtitle = 'Declined';
      statusIcon = Icons.call_end;
    } else if (outcome == 'noAnswer') {
      subtitle = 'No answer';
      statusIcon = Icons.call_missed_outgoing;
    } else {
      // Completed with duration
      subtitle = _formatDuration(durationSeconds);
      statusIcon = direction == 'incoming'
          ? Icons.call_received
          : Icons.call_made;
      statusColor = Colors.green; // Completed calls are green
    }

    // Main icon (CircleAvatar)
    final mainIcon = isVideo ? Icons.videocam : Icons.call;

    // Bubble color (Keep somewhat consistent or neutral)
    final bg = isMe ? const Color(0xFFE1FFC7) : const Color(0xFFE8F0FE);
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final timeStr = _formatTime(createdAt);

    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: align,
        children: [
          Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Container(
                width: 240.w,
                margin: EdgeInsets.symmetric(vertical: 6.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
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
                  children: [
                    Container(
                      padding: EdgeInsets.all(10.w),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(mainIcon, size: 28.sp, color: Colors.black87),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Icon(statusIcon, size: 16.sp, color: statusColor),
                              SizedBox(width: 4.w),
                              Text(
                                subtitle,
                                style: TextStyle(
                                  fontSize: 13.sp,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(height: 20.h), // push time down
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '$seconds sec';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '$m min $s sec';
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
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 4.h),
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .9),
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 4),
              ],
            ),
            child: Wrap(spacing: 6.w, runSpacing: 4.h, children: chips),
          ),
        ],
      ),
    );
  }
}
