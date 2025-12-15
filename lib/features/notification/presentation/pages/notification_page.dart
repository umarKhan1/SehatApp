import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sehatapp/core/localization/app_texts.dart';
import 'package:sehatapp/features/notification/domain/entities/notification_entity.dart';
import 'package:sehatapp/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:sehatapp/features/notification/presentation/widgets/notification_item.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          AppTexts.of(context).notifications,
          style: GoogleFonts.poppins(
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            }
          },
        ),
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              // Only show button if there are unread notifications
              if (state.unreadCount > 0) {
                return TextButton(
                  onPressed: () {
                    context.read<NotificationCubit>().markAllRead();
                  },
                  child: Text(
                    'Mark as Read',
                    style: GoogleFonts.poppins(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFFE63946),
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.error != null) {
            return Center(child: Text(state.error!));
          }
          if (state.notifications.isEmpty) {
            return Center(child: Text(AppTexts.of(context).notificationEmpty));
          }

          final grouped = _groupNotifications(context, state.notifications);
          final keys = grouped.keys.toList();

          return ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            itemCount: keys.length,
            itemBuilder: (context, index) {
              final dateLabel = keys[index];
              final notifs = grouped[dateLabel]!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Text(
                      dateLabel,
                      style: GoogleFonts.poppins(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  ...notifs.map(
                    (n) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: NotificationItem(
                        notification: n,
                        onTap: () {
                          context.read<NotificationCubit>().markAsRead(n.id);
                        },
                      ),
                    ),
                  ),
                  Divider(color: Colors.grey[200]),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Map<String, List<NotificationEntity>> _groupNotifications(
    BuildContext context,
    List<NotificationEntity> notifications,
  ) {
    // Sort by date desc
    final sorted = List<NotificationEntity>.from(notifications)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    final Map<String, List<NotificationEntity>> grouped = {};

    for (var n in sorted) {
      final key = _getDateLabel(context, n.timestamp);
      if (!grouped.containsKey(key)) {
        grouped[key] = [];
      }
      grouped[key]!.add(n);
    }
    return grouped;
  }

  String _getDateLabel(BuildContext context, DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final date = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (date.isAtSameMomentAs(today)) {
      return AppTexts.of(context).today;
    } else if (date.isAtSameMomentAs(yesterday)) {
      return AppTexts.of(context).yesterday;
    } else {
      return AppTexts.of(context).earlier;
    }
  }
}
