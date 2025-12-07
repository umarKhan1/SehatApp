import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sehatapp/features/chat/presentation/widgets/message_bubble.dart';

class MessageActionsOverlay extends StatelessWidget {
  const MessageActionsOverlay({
    super.key,
    required this.preview,
    required this.isMe,
    required this.reactionEmojis,
    required this.scaleAnim,
    required this.fadeAnim,
    required this.onDismiss,
    required this.onReact,
    required this.onReply,
    this.onDelete,
  });

  final String preview;
  final bool isMe;
  final List<String> reactionEmojis;
  final Animation<double> scaleAnim;
  final Animation<double> fadeAnim;
  final VoidCallback onDismiss;
  final void Function(String emoji) onReact;
  final VoidCallback onReply;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bubbleMaxWidth = size.width * 0.78;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: onDismiss,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(
                    0.32 * fadeAnim.value,
                  ),
                ),
              ),
            ),
          ),
        ),
        Center(
          child: Opacity(
            opacity: fadeAnim.value,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha:  0.85),
                      borderRadius: BorderRadius.circular(24.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: reactionEmojis
                          .map(
                            (e) => GestureDetector(
                              onTap: () {
                                onReact(e);
                                onDismiss();
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 6.w,
                                  vertical: 2.h,
                                ),
                                child: Text(
                                  e,
                                  style: const TextStyle(fontSize: 22),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Transform.scale(
                  scale: scaleAnim.value,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: bubbleMaxWidth,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      elevation: 12,
                      borderRadius: BorderRadius.circular(16),
                      child: MessageBubble(
                        text: preview,
                        isMe: isMe,
                        createdAt: DateTime.now(),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 240.w,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF222222),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          dense: true,
                          leading: const Icon(
                            Icons.reply,
                            color: Colors.white,
                          ),
                          title: const Text(
                            'Reply',
                            style: TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            onReply();
                            onDismiss();
                          },
                        ),
                        if (onDelete != null)
                          ListTile(
                            dense: true,
                            leading: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            title: const Text(
                              'Delete',
                              style: TextStyle(color: Colors.white),
                            ),
                            onTap: () async {
                              onDelete!.call();
                              onDismiss();
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
