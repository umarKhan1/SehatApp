import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardHeader extends StatelessWidget implements PreferredSizeWidget {
  const DashboardHeader({super.key, this.userName = 'User name', this.avatarAsset = 'assets/images/applogo.png', this.donateOn = false, this.onNotificationsTap});

  final String userName;
  final String avatarAsset;
  final bool donateOn;
  final VoidCallback? onNotificationsTap;

  @override
  Size get preferredSize => Size.fromHeight(60.h);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundImage: AssetImage(avatarAsset),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'Donate Blood : ${donateOn ? 'On' : 'Off'}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: donateOn ? Colors.green : Colors.redAccent),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none),
              onPressed: onNotificationsTap,
            ),
          ],
        ),
      ),
    );
  }
}
