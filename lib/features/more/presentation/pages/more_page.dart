import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/more_list_item.dart';
import 'package:sehatapp/features/post_request/presentation/pages/create_request_page.dart';
import 'faq_page.dart';
import 'settings_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final itemsData = [
      {'icon': Icons.bloodtype, 'title': 'Create Request Blood'},
      {'icon': Icons.add, 'title': 'Create Donot Blood'},
      {'icon': Icons.apartment, 'title': 'Blood Donat Organization'},
      {'icon': Icons.local_shipping, 'title': 'Ambulance'},
      {'icon': Icons.inbox, 'title': 'Inbox'},
      {'icon': Icons.volunteer_activism, 'title': 'Work as volunteer'},
      {'icon': Icons.sell_outlined, 'title': 'Tags'},
      {'icon': Icons.help_outline, 'title': 'FAQ'},
      {'icon': Icons.article_outlined, 'title': 'Blog'},
      {'icon': Icons.settings_outlined, 'title': 'Settings'},
      {'icon': Icons.swap_horizontal_circle_outlined, 'title': 'Compatibility'},
      {'icon': Icons.favorite_border, 'title': 'Donate Us'},
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              Center(child: Text('More', style: Theme.of(context).textTheme.titleLarge)),
              SizedBox(height: 12.h),
              // Profile header card
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(16.w, 32.h, 16.w, 24.h),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(height: 24.h),
                        Text(
                          'Brooklyn Simmons',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Blood Group: B+',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: -22.h,
                    left: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 28.r,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 26.r,
                        backgroundImage: const AssetImage('assets/images/applogo.png'),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 12.w,
                    top: 12.h,
                    child: const Icon(Icons.edit_outlined, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: ListView.separated(
                  itemCount: itemsData.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final data = itemsData[i];
                    return MoreListItem(
                      icon: data['icon'] as IconData,
                      title: data['title'] as String,
                      onTap: () {
                        if (i == 0) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const CreateRequestPage()),
                          );
                        } else if (data['title'] == 'FAQ') {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const FaqPage()),
                          );
                        } else if (data['title'] == 'Settings') {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SettingsPage()),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
