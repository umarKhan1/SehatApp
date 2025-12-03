import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatapp/core/constants/app_options.dart';

class BloodGroupChips extends StatelessWidget {
  const BloodGroupChips({super.key, this.onSelect});

  final void Function(String group)? onSelect;

  @override
  Widget build(BuildContext context) {
    final groups = AppOptions.bloodGroups;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Blood Group', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: groups.map((g) => _BloodChip(label: g, onTap: () {
            onSelect?.call(g);
            // Navigate to blood request listing for selected group
            context.push('/blood-request?group=$g');
          })).toList(),
        ),
      ],
    );
  }
}

class _BloodChip extends StatelessWidget {
  const _BloodChip({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: 72.w,
        height: 64.h,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.redAccent),
          borderRadius: BorderRadius.circular(12.r),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bloodtype, color: Colors.redAccent, size: 20.sp),
            SizedBox(height: 6.h),
            Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.redAccent, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
