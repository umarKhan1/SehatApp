import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sehatapp/core/localization/app_texts.dart';
import 'package:sehatapp/features/chat/presentation/widgets/chat_list_item.dart';

class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  @override
  Widget build(BuildContext context) {
    final dividerColor = const Color(0xFFEDEFF3); // light drawer/divider color
    final items = [
      ChatListItem(title: 'Chat with admin', subtitle: 'saepe eveniet ut et voluptates', time: 'Yesterday', unreadCount: 0,
        leadingIcon: CircleAvatar(radius: 22.r, backgroundColor: const Color(0xFFFFEEEE), child: const Icon(Icons.bloodtype, color: Colors.redAccent))),
      ChatListItem(title: 'Jenny Wilson', subtitle: 'saepe eveniet ut et voluptates', time: '12:42 AM', unreadCount: 1,
        leadingIcon: CircleAvatar(radius: 22.r, backgroundColor: const Color(0xFFE8F4FF), child: const Icon(Icons.person, color: Color(0xFF4E9AF1)))),
      ChatListItem(title: 'Robert Fox', subtitle: 'saepe eveniet ut et voluptates', time: '12:42 AM', unreadCount: 0,
        leadingIcon: CircleAvatar(radius: 22.r, backgroundColor: const Color(0xFFEDEDED), child: const Icon(Icons.person, color: Colors.black45))),
    ];

    final tx = AppTexts.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              Center(child: Text(tx.inboxTitle, style: Theme.of(context).textTheme.titleLarge)),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6FA),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.black38),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration.collapsed(hintText: tx.searchNameHint),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => Divider(height: 1, color: dividerColor),
                  itemBuilder: (context, i) => items[i],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
