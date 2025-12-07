import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RecentlyViewedItem {
  RecentlyViewedItem({
    required this.id,
    required this.title,
    required this.hospital,
    required this.date,
    required this.bloodGroup,
    this.mobile,
    this.bags,
    this.country,
    this.city,
  });
  final String id;
  final String title;
  final String hospital;
  final String date;
  final String bloodGroup;
  final String? mobile;
  final String? bags;
  final String? country;
  final String? city;
}

class RecentlyViewedList extends StatelessWidget {
  const RecentlyViewedList({super.key, required this.items, this.onItemTap});
  final List<RecentlyViewedItem> items;
  final void Function(RecentlyViewedItem item)? onItemTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Removed header text
        // SizedBox(height: 12.h),
        ...items.map((e) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _RecentCard(item: e, onTap: () => onItemTap?.call(e)),
            )),
      ],
    );
  }
}

class _RecentCard extends StatelessWidget {
  const _RecentCard({required this.item, this.onTap});
  final RecentlyViewedItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 6))],
        ),
        padding: EdgeInsets.all(12.w),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.redAccent),
                color: const Color(0xFFFFEEEE),
              ),
              alignment: Alignment.center,
              child: Text(
                item.bloodGroup,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.redAccent, fontWeight: FontWeight.w700),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  SizedBox(height: 8.h),
                  Row(children: [
                    const Icon(Icons.local_hospital, color: Colors.redAccent),
                    SizedBox(width: 8.w),
                    Text(item.hospital, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
                  ]),
              
                  SizedBox(height: 8.h),
                  Row(children: [
                    const Icon(Icons.access_time, color: Colors.redAccent),
                    SizedBox(width: 8.w),
                    Text(item.date, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
