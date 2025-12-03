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
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Row(
       
        children: [
          leadingIcon ?? CircleAvatar(radius: 22.r, backgroundColor: const Color(0xFFFFEEEE), child: const Icon(Icons.bloodtype, color: Colors.redAccent)),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (unreadCount > 0) ...[
                            SizedBox(width: 6.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: primary.withValues(alpha: 
                       0.1),
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              child: Text(
                                '$unreadCount',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: primary, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(time, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black45)),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
