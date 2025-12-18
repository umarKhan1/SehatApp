import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sehatapp/core/theme/app_theme.dart';

class TopicSelectorDialog extends StatelessWidget {
  const TopicSelectorDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('What do you need help with?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TopicOption(
            title: 'Blood Donation',
            icon: Icons.bloodtype,
            onTap: () => Navigator.pop(context, 'blood_donation'),
          ),
          SizedBox(height: 12.h),
          _TopicOption(
            title: 'Health',
            icon: Icons.health_and_safety,
            onTap: () => Navigator.pop(context, 'health'),
          ),
          SizedBox(height: 12.h),
          _TopicOption(
            title: 'Both',
            icon: Icons.all_inclusive,
            onTap: () => Navigator.pop(context, 'both'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Skip'),
        ),
      ],
    );
  }
}

class _TopicOption extends StatelessWidget {
  const _TopicOption({
    required this.title,
    required this.icon,
    required this.onTap,
  });
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primary),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primary),
            SizedBox(width: 12.w),
            Text(
              title,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
