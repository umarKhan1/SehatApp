import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sehatapp/core/localization/app_texts.dart';
import 'package:sehatapp/features/more/presentation/pages/faq_page.dart';
import 'package:sehatapp/features/more/presentation/pages/settings_page.dart';
import 'package:sehatapp/features/more/presentation/widgets/more_list_item.dart';
import 'package:sehatapp/features/post_request/presentation/pages/create_request_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key});

  @override
  Widget build(BuildContext context) {
    final tx = AppTexts.of(context);
    final itemsData = [
      {'icon': Icons.bloodtype, 'title': tx.createRequestBlood},
      {'icon': Icons.add, 'title': tx.createDonorBlood},
      {'icon': Icons.apartment, 'title': tx.bloodDonateOrg},
      {'icon': Icons.local_shipping, 'title': tx.ambulance},
      {'icon': Icons.inbox, 'title': tx.inboxLabel},
      {'icon': Icons.volunteer_activism, 'title': tx.volunteerWork},
      {'icon': Icons.sell_outlined, 'title': tx.tags},
      {'icon': Icons.help_outline, 'title': tx.faq},
      {'icon': Icons.article_outlined, 'title': tx.blog},
      {'icon': Icons.settings_outlined, 'title': tx.settings},
      {'icon': Icons.swap_horizontal_circle_outlined, 'title': tx.compatibility},
      {'icon': Icons.favorite_border, 'title': tx.donateUs},
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              Center(child: Text(tx.moreTitle, style: Theme.of(context).textTheme.titleLarge)),
              SizedBox(height: 40.h),
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
                  separatorBuilder: (_, _) => const Divider(height: 1),
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
                        } else if (data['title'] == tx.faq) {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const FaqPage()),
                          );
                        } else if (data['title'] == tx.settings) {
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
