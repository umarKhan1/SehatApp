import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post});
  final Map<String, dynamic> post;

  @override
  Widget build(BuildContext context) {
    final name = (post['name'] ?? '') as String;
    final bloodGroup = post['bloodGroup'] ?? '';
    final hospital = (post['hospital'] ?? '') as String;
    final city = (post['city'] ?? '') as String;
    final country = (post['country'] ?? '') as String;
    final reason = (post['reason'] ?? '') as String;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(8.r)),
                  child: Text('$bloodGroup', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
                SizedBox(width: 8.w),
                Expanded(child: Text(name, style: Theme.of(context).textTheme.titleMedium)),
              ],
            ),
            SizedBox(height: 8.h),
            Text(reason, maxLines: 3, overflow: TextOverflow.ellipsis),
            SizedBox(height: 8.h),
            Row(
              children: [
                const Icon(Icons.local_hospital, size: 16, color: Colors.black54),
                SizedBox(width: 4.w),
                Expanded(child: Text(hospital, style: const TextStyle(color: Colors.black87))),
              ],
            ),
            SizedBox(height: 4.h),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.black54),
                SizedBox(width: 4.w),
                Expanded(child: Text('$city, $country', style: const TextStyle(color: Colors.black87))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
