import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.icon, required this.title});
  final IconData icon;
  final String title;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Container(
            width: 88.w,
            height: 88.w,
            decoration: const BoxDecoration(color: Color(0xFFFFEEEE), shape: BoxShape.circle),
            child: Icon(icon, color: Colors.redAccent, size: 36.sp),
          ),
        ),
        SizedBox(height: 16.h),
        Center(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}
