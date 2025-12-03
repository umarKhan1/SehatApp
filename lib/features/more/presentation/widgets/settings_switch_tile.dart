import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({super.key, required this.icon, required this.color, required this.title, required this.value, required this.onChanged});
  final IconData icon;
  final Color color;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          Switch(
            value: value,
            activeThumbColor: Colors.redAccent,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
