import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sehatapp/core/theme/app_theme.dart';

class DotsIndicator extends StatelessWidget {
  const DotsIndicator({super.key, required this.length, required this.activeIndex});
  final int length;
  final int activeIndex;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(length, (i) {
        final bool active = i == activeIndex;
        return Container(
          width: active ? 16.w : 8.w,
          height: 6.h,
          margin: EdgeInsets.only(right: 6.w),
          decoration: BoxDecoration(
            color: (active ? AppTheme.primary : Colors.black.withAlpha(60)),
            borderRadius: BorderRadius.circular(3.r),
          ),
        );
      }),
    );
  }
}
