import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sehatapp/core/theme/app_theme.dart';
import 'package:sehatapp/features/ai_chat/data/models/message_model.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({super.key, required this.message, this.onRetry});
  final MessageModel message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              radius: 16.r,
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(Icons.auto_awesome, size: 18.sp, color: Colors.white),
            ),
            SizedBox(width: 8.w),
          ],
          Flexible(
            child: GestureDetector(
              onTap: message.status == MessageStatus.error ? onRetry : null,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isUser
                      ? Colors.grey.shade200
                      : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isUser) ...[
                      Icon(
                        Icons.auto_awesome,
                        size: 20.sp,
                        color: Theme.of(context).primaryColor,
                      ),
                      SizedBox(width: 8.w),
                    ],
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (message.status == MessageStatus.sending &&
                              message.text == 'Thinking...')
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 16.w,
                                  height: 16.h,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Thinking...',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ],
                            )
                          else if (message.status == MessageStatus.error)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 16.sp,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 4.w),
                                    Flexible(
                                      child: Text(
                                        'Something went wrong. Tap to retry.',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          else
                            isUser
                                ? Text(
                                    message.text,
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      color: Colors.black87,
                                      height: 1.4,
                                    ),
                                  )
                                : MarkdownBody(
                                    data: message.text,
                                    styleSheet: MarkdownStyleSheet(
                                      p: TextStyle(
                                        fontSize: 15.sp,
                                        color: Colors.black87,
                                        height: 1.4,
                                      ),
                                      h1: TextStyle(
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      h2: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      h3: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                      strong: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      listBullet: TextStyle(
                                        fontSize: 15.sp,
                                        color: Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 8.w),
            CircleAvatar(
              radius: 16.r,
              backgroundColor: AppTheme.primary,
              child: Icon(Icons.person, size: 18.sp, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}
