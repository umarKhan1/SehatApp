import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sehatapp/core/theme/app_theme.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.text, required this.isMe, this.isRead = false});
  final String text;
  final bool isMe;
  final bool isRead;

  @override
  Widget build(BuildContext context) {
    final bg = isMe ?  AppTheme.primary : const Color(0xFFF1F3F6);
    final fg = isMe ? Colors.white : Colors.black87;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      crossAxisAlignment: align,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              margin: EdgeInsets.symmetric(vertical: 6.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                  bottomLeft: Radius.circular(isMe ? 12.r : 2.r),
                  bottomRight: Radius.circular(isMe ? 2.r : 12.r),
                ),
              ),
              child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: fg)),
            ),
            if (isMe)
              Padding(
                padding: EdgeInsets.only(right: 6.w, bottom: 2.h),
                child: Icon(
                  Icons.done_all,
                  size: 16,
                  color: isRead ? Colors.blue : Colors.white70,
                ),
              ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          '3 Apr 11:00 AM',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black45),
        ),
      ],
    );
  }
}
