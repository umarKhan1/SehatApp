import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsTile extends StatelessWidget {
  const SettingsTile({super.key, required this.icon, required this.color, required this.title, this.onTap});
  final IconData icon;
  final Color color;
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h),
        child: Row(
          children: [
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(18.r)),
              child: Icon(icon, color: Colors.black54),
            ),
            SizedBox(width: 12.w),
            Expanded(child: Text(title, style: Theme.of(context).textTheme.bodyMedium)),
            const Icon(Icons.chevron_right, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}
