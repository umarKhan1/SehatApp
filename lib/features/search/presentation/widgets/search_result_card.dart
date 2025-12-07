import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sehatapp/features/search/models/search_item.dart';

class SearchResultCard extends StatelessWidget {
  const SearchResultCard({super.key, required this.item, this.onTap});
  final SearchItem item;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
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
              child: Text(item.bloodGroup, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.redAccent, fontWeight: FontWeight.w700)),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.title, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
                  SizedBox(height: 6.h),
                  if (item.type == SearchType.need) ...[
                    if ((item.subtitle ?? '').isNotEmpty)
                      Row(children: [
                        const Icon(Icons.local_hospital, color: Colors.redAccent, size: 16),
                        SizedBox(width: 6.w),
                        Expanded(child: Text(item.subtitle!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54))),
                      ]),
                    SizedBox(height: 6.h),
                    if ((item.date ?? '').isNotEmpty)
                      Row(children: [
                        const Icon(Icons.access_time, color: Colors.redAccent, size: 16),
                        SizedBox(width: 6.w),
                        Expanded(child: Text(item.date!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54))),
                      ]),
                  ] else ...[
                    if ((item.subtitle ?? '').isNotEmpty)
                      Row(children: [
                        const Icon(Icons.phone, color: Colors.redAccent, size: 16),
                        SizedBox(width: 6.w),
                        Expanded(child: Text(item.subtitle!, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54))),
                      ]),
                  ]
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
