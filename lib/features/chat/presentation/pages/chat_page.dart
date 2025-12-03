import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/message_bubble.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key, required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final messages = <Map<String, dynamic>>[
      {'text': 'Hi, Kmn acn?', 'isMe': false, 'isRead': true},
      {'text': 'sunt in culpa qui officia deserunt', 'isMe': false, 'isRead': true},
      {'text': 'sunt in culpa qui officia deserunt', 'isMe': true, 'isRead': true},
      {'text': 'sunt in culpa qui officia deserunt', 'isMe': true, 'isRead': false},
      {'text': 'sunt in culpa qui officia deserunt', 'isMe': false, 'isRead': false},
    ];

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
                      child: Text(title, style: Theme.of(context).textTheme.titleMedium),
                    ),
                  ),
                  SizedBox(width: 48.w),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                itemCount: messages.length,
                itemBuilder: (context, i) => MessageBubble(
                  text: messages[i]['text'] as String,
                  isMe: messages[i]['isMe'] as bool,
                  isRead: messages[i]['isRead'] as bool,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type Message',
                        filled: true,
                        fillColor: const Color(0xFFF1F3F6),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  CircleAvatar(
                    backgroundColor: Colors.redAccent,
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
