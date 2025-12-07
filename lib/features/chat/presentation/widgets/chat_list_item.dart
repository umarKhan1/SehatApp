import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatListItem extends StatelessWidget {
  const ChatListItem({super.key, required this.title, required this.subtitle, required this.time, required this.unreadCount, this.leadingIcon});
  final String title;
  final String subtitle;
  final String time;
  final int unreadCount;
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF1DB954); // green accent for unread badge
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 4.w),
      child: Row(
        children: [
          leadingIcon ?? CircleAvatar(radius: 22.r, backgroundColor: const Color(0xFFEDEDED), child: const Icon(Icons.person, color: Colors.black45)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(time, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (unreadCount > 0) ...[
                      SizedBox(width: 8.w),
                      Container(
                        width: 22.w,
                        height: 22.w,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: primary,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$unreadCount',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
