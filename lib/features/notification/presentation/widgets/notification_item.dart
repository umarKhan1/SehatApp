import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sehatapp/features/notification/domain/entities/notification_entity.dart';

class NotificationItem extends StatelessWidget {
  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
  });
  final NotificationEntity notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: notification.isRead
            ? Colors.transparent
            : Colors.blue.withValues(
                alpha: 0.02,
              ), // Slight highlight if unread? Or just use the transparent background as per design. Design looks white/clean.
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 0.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIcon(),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          notification.title,
                          style: GoogleFonts.poppins(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        _formatTime(notification.timestamp),
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Text(
                          notification.subtitle,
                          style: GoogleFonts.poppins(
                            fontSize: 12.sp,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (notification.unreadCount > 0)
                        Padding(
                          padding: EdgeInsets.only(left: 8.w),
                          child: CircleAvatar(
                            radius: 10.r,
                            backgroundColor: const Color(
                              0xFF00897B,
                            ), // Teal color from image
                            child: Text(
                              notification.unreadCount.toString(),
                              style: GoogleFonts.poppins(
                                fontSize: 10.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    Color bgColor;
    Color iconColor;
    IconData icon;

    switch (notification.type) {
      case NotificationType.message:
        bgColor = const Color(0xFFE3F2FD); // Light Blue
        iconColor = const Color(0xFF2196F3); // Blue
        icon = Icons.chat_bubble_outline;
        break;

      case NotificationType.post:
        bgColor = const Color(0xFFFFEBEE); // Light Red
        iconColor = const Color(0xFFF44336); // Red
        icon = Icons.medical_services_outlined;
        break;

      case NotificationType.reminder:
        bgColor = const Color(0xFFE8F5E9); // Light Green
        iconColor = const Color(0xFF4CAF50); // Green
        icon = Icons.notifications_none;
        break;

      case NotificationType.mention:
        bgColor = const Color(0xFFFFF3E0); // Light Orange/Beige
        return Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            image: const DecorationImage(
              image: AssetImage('assets/images/applogo.png'),
              fit: BoxFit.contain,
            ),
          ),
        );

      default:
        bgColor = Colors.grey.shade200;
        iconColor = Colors.black;
        icon = Icons.notifications;
    }

    return Container(
      width: 48.w,
      height: 48.w,
      decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
      child: Icon(icon, color: iconColor, size: 24.sp),
    );
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}min ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}hr ago';
    } else {
      if (difference.inDays == 1) {
        // Handled by header usually, but if inside item:
        return 'Yesterday'; // Or specific format
      }
      return '${difference.inDays}d ago';
    }
  }
}
