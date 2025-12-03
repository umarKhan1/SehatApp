import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sehatapp/features/blood_request/presentation/widgets/blood_request_item.dart';

class BloodRequestCard extends StatelessWidget {
  const BloodRequestCard({super.key, required this.item});
  final BloodRequestItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(12.r),
        color: Colors.white,
      ),
      padding: EdgeInsets.all(12.w),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEEE),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.redAccent),
            ),
            alignment: Alignment.center,
            child: Text(
              item.bloodGroup,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.redAccent, fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 6.h),
                Row(children: [
                  const Icon(Icons.local_hospital, color: Colors.redAccent, size: 16),
                  SizedBox(width: 6.w),
                  Text(
                    item.hospital,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.black54),
                  ),
                ]),
                SizedBox(height: 6.h),
                Row(children: [
                  const Icon(Icons.access_time, color: Colors.redAccent, size: 16),
                  SizedBox(width: 6.w),
                  Text(
                    item.date,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.black54),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
