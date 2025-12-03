import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sehatapp/features/chat/presentation/pages/chat_page.dart';

class BloodRequestDetailsPage extends StatelessWidget {
  const BloodRequestDetailsPage({super.key, required this.title, required this.bloodGroup});
  final String title;
  final String bloodGroup;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Post Details',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  SizedBox(width: 48.w),
                ],
              ),
              SizedBox(height: 20.h),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 64.w,
                      height: 64.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.redAccent),
                        color: const Color(0xFFFFEEEE),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        bloodGroup,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.redAccent, fontWeight: FontWeight.w700),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              const Divider(),
               SizedBox(height: 7.h),
              _DetailsRow(icon: Icons.person, label: 'Contact Person', value: 'Person Name'),
              SizedBox(height: 7.h),
              _DetailsRow(icon: Icons.phone, label: 'Mobile Number', value: '+88 01112233344'),
              SizedBox(height: 7.h),
              _DetailsRow(icon: Icons.bloodtype, label: 'How many Bag(s)', value: '3 Bags'),
              SizedBox(height: 7.h), 
              _DetailsRow(icon: Icons.public, label: 'Country', value: 'Bangladesh'),
              SizedBox(height: 7.h),
              _DetailsRow(icon: Icons.location_on, label: 'City', value: 'Dhaka'),
              SizedBox(height: 7.h),
              _DetailsRow(icon: Icons.local_hospital, label: 'Hospital', value: 'Nur Hospital'),
              SizedBox(height: 12.h),
              Text('Why do you need blood?', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              SizedBox(height: 8.h),
              Text(
                'sunt in culpa qui officia deserunt mollitia animi, id est laborum et dolorum fuga. Et harum quidem rerum facilis expedita',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatPage(title: 'Cameron Williamson'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                  ),
                  child: Text('Chat Now', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                ),
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailsRow extends StatelessWidget {
  const _DetailsRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 32.w,
              height: 32.w,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEEEE),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Icon(icon, color: Colors.redAccent, size: 18),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54)),
                  Text(value, style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        const Divider(height: 1),
      ],
    );
  }
}
