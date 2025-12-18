import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatapp/core/localization/app_texts.dart';
import 'package:sehatapp/core/theme/app_theme.dart';
import 'package:sehatapp/features/auth/data/user_repository.dart';
import 'package:sehatapp/features/dashboard/bloc/posts_cubit.dart';
import 'package:sehatapp/features/dashboard/presentation/widgets/banner_carousel.dart';
import 'package:sehatapp/features/dashboard/presentation/widgets/blood_group_chips.dart';
import 'package:sehatapp/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:sehatapp/features/dashboard/presentation/widgets/our_contribution_grid.dart';
import 'package:sehatapp/features/dashboard/presentation/widgets/post_card.dart';
import 'package:sehatapp/features/dashboard/presentation/widgets/search_bar.dart';
import 'package:sehatapp/features/notification/presentation/cubit/notification_cubit.dart';
import 'package:sehatapp/features/post_request/data/post_repository.dart';
import 'package:sehatapp/features/recently_viewed/bloc/recently_viewed_cubit.dart';
import 'package:sehatapp/features/recently_viewed/presentation/widgets/recently_viewed_list.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tx = AppTexts.of(context);
    final repo = UserRepository();
    final uid = FirebaseAuth.instance.currentUser?.uid;

    final stats = [
      ContributionStat(
        value: '1K+',
        label: tx.bloodDonor,
        bg: const Color(0xFFF0F6FF),
        valueColor: const Color(0xFF4E9AF1),
      ),
      ContributionStat(
        value: '20',
        label: tx.postEveryday,
        bg: const Color(0xFFEFFAF1),
        valueColor: const Color(0xFF29A064),
      ),
      ContributionStat(
        value: '20',
        label: tx.postEveryday,
        bg: const Color(0xFFF2F2FF),
        valueColor: const Color(0xFF6B6AF6),
      ),
      ContributionStat(
        value: '1K+',
        label: tx.bloodDonor,
        bg: const Color(0xFFFCF2FF),
        valueColor: const Color(0xFFCD69E5),
      ),
      ContributionStat(
        value: '20',
        label: tx.postEveryday,
        bg: const Color(0xFFFFF0F0),
        valueColor: const Color(0xFFFF6B6B),
      ),
      ContributionStat(
        value: '20',
        label: tx.postEveryday,
        bg: const Color(0xFFFFFAEE),
        valueColor: const Color(0xFFFFC12E),
      ),
    ];

    return BlocProvider(
      create: (_) => PostsCubit(repo: PostRepository())..start(),
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const DashboardHeader().preferredSize,
          child: FutureBuilder<Map<String, dynamic>>(
            future: uid == null
                ? Future.value({'name': 'User name', 'wantToDonate': false})
                : repo.getUserWithCache(uid),
            builder: (context, snap) {
              String name = 'User name';
              bool donateOn = false;
              if (snap.hasData && snap.data != null) {
                final data = snap.data!;
                name = (data['name'] ?? name) as String;
                donateOn = (data['wantToDonate'] ?? false) as bool;
              }
              return BlocBuilder<NotificationCubit, NotificationState>(
                builder: (context, notificationState) {
                  return DashboardHeader(
                    userName: name,
                    donateOn: donateOn,
                    notificationCount: notificationState.unreadCount,
                    onNotificationsTap: () =>
                        context.pushNamed('notifications'),
                    onAITap: () => context.pushNamed('ai-chat'),
                  );
                },
              );
            },
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SearchBarHero(),
                SizedBox(height: 16.h),
                const BannerCarousel(),
                SizedBox(height: 16.h),
                const BloodGroupChips(),
                SizedBox(height: 24.h),
                BlocBuilder<RecentlyViewedCubit, RecentlyViewedState>(
                  builder: (context, rvState) {
                    final items = rvState.previewItems; // use preview only
                    if (items.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            Text(
                              tx.bloodGroupTitle,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.primary,
                              ),
                              onPressed: () =>
                                  context.pushNamed('recentlyViewed'),
                              child: Text(
                                'View all',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10.h),
                        RecentlyViewedList(
                          items: items
                              .map(
                                (p) => RecentlyViewedItem(
                                  id: (p['id'] ?? '') as String,
                                  title: (p['name'] ?? '') as String,
                                  hospital: (p['hospital'] ?? '') as String,
                                  date: (p['date'] ?? '') as String,
                                  bloodGroup: (p['bloodGroup'] ?? '') as String,
                                  mobile: (p['mobile'] ?? '') as String?,
                                  bags: (p['bags'] ?? '') as String?,
                                  country: (p['country'] ?? '') as String?,
                                  city: (p['city'] ?? '') as String?,
                                ),
                              )
                              .toList(),
                          onItemTap: (item) {
                            final full = items.firstWhere(
                              (e) => (e['id'] ?? '') == item.id,
                              orElse: () => {
                                'id': item.id,
                                'name': item.title,
                                'hospital': item.hospital,
                                'date': item.date,
                                'bloodGroup': item.bloodGroup,
                                'mobile': item.mobile,
                                'bags': item.bags,
                                'country': item.country,
                                'city': item.city,
                              },
                            );
                            context.pushNamed(
                              'bloodRequestDetails',
                              extra: full,
                            );
                          },
                        ),
                        SizedBox(height: 8.h),
                      ],
                    );
                  },
                ),
                SizedBox(height: 24.h),
                OurContributionGrid(stats: stats),
                SizedBox(height: 24.h),
                Center(
                  child: Text(tx.welcomeDashboard, textAlign: TextAlign.center),
                ),
                SizedBox(height: 24.h),
                Text(
                  tx.recentPostsTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                SizedBox(height: 8.h),
                BlocBuilder<PostsCubit, PostsState>(
                  builder: (context, state) {
                    if (state.loading) {
                      return Column(
                        children: List.generate(3, (i) => _PostShimmer()),
                      );
                    }
                    if (state.error != null) {
                      return Text(
                        state.error!,
                        style: const TextStyle(color: Colors.red),
                      );
                    }
                    if (state.posts.isEmpty) {
                      return Text(tx.noPostsFound);
                    }
                    return Column(
                      children: state.posts.map((p) {
                        return InkWell(
                          onTap: () {
                            context.read<RecentlyViewedCubit>().addViewed(p);
                            context.pushNamed('bloodRequestDetails', extra: p);
                          },
                          child: PostCard(post: p),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PostShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F3F3),
        borderRadius: BorderRadius.circular(12.r),
      ),
      height: 110.h,
    );
  }
}
