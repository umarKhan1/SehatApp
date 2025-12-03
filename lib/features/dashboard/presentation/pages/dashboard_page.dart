import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sehatapp/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:sehatapp/features/dashboard/presentation/widgets/banner_carousel.dart';
import 'package:sehatapp/features/dashboard/presentation/widgets/blood_group_chips.dart';
import 'package:sehatapp/features/dashboard/presentation/widgets/search_bar.dart';
import 'package:sehatapp/features/recently_viewed/presentation/widgets/recently_viewed_list.dart';
import 'package:sehatapp/features/blood_request/presentation/pages/blood_request_details_page.dart';
import 'package:sehatapp/features/dashboard/presentation/widgets/our_contribution_grid.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final recentItems = [
      RecentlyViewedItem(title: 'Emergency B+ Blood Needed', hospital: 'Hospital Name', date: '12 Feb 2022', bloodGroup: 'B+'),
      RecentlyViewedItem(title: 'Emergency B+ Blood Needed', hospital: 'Hospital Name', date: '12 Feb 2022', bloodGroup: 'B+'),
    ];

    final stats = [
      ContributionStat(value: '1K+', label: 'Blood Donner', bg: const Color(0xFFF0F6FF), valueColor: const Color(0xFF4E9AF1)),
      ContributionStat(value: '20', label: 'Post everyday', bg: const Color(0xFFEFFAF1), valueColor: const Color(0xFF29A064)),
      ContributionStat(value: '20', label: 'Post everyday', bg: const Color(0xFFF2F2FF), valueColor: const Color(0xFF6B6AF6)),
      ContributionStat(value: '1K+', label: 'Blood Donner', bg: const Color(0xFFFCF2FF), valueColor: const Color(0xFFCD69E5)),
      ContributionStat(value: '20', label: 'Post everyday', bg: const Color(0xFFFFF0F0), valueColor: const Color(0xFFFF6B6B)),
      ContributionStat(value: '20', label: 'Post everyday', bg: const Color(0xFFFFFAEE), valueColor: const Color(0xFFFFC12E)),
    ];

    return Scaffold(
      appBar: const DashboardHeader(),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search bar with hero animation
              const SearchBarHero(),
              SizedBox(height: 16.h),
              const BannerCarousel(),
              SizedBox(height: 16.h),
              const BloodGroupChips(),
              SizedBox(height: 24.h),
              RecentlyViewedList(
                items: recentItems,
                onItemTap: (item) {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => BloodRequestDetailsPage(
                        title: item.title,
                        bloodGroup: item.bloodGroup,
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 24.h),
              OurContributionGrid(stats: stats),
              SizedBox(height: 24.h),
              const Center(child: Text('Welcome to Dashboard', textAlign: TextAlign.center)),
            ],
          ),
        ),
      ),
    );
  }
}
