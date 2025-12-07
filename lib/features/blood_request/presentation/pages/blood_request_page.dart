import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatapp/core/localization/app_texts.dart';
import 'package:lottie/lottie.dart';
import 'package:sehatapp/core/constants/app_images.dart';
import 'package:sehatapp/features/blood_request/presentation/widgets/blood_request_card.dart';
import 'package:sehatapp/features/blood_request/presentation/widgets/blood_request_item.dart';
import 'package:sehatapp/features/blood_request/bloc/blood_request_cubit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sehatapp/features/recently_viewed/bloc/recently_viewed_cubit.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BloodRequestPage extends StatefulWidget {
  const BloodRequestPage({super.key, this.group});
  final String? group;

  @override
  State<BloodRequestPage> createState() => _BloodRequestPageState();
}

class _BloodRequestPageState extends State<BloodRequestPage> {
  @override
  void initState() {
    super.initState();
    // Start loading requests for the group
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      context.read<BloodRequestCubit>().start(bloodGroup: widget.group, excludeUid: uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    String formatDate(dynamic raw) {
      if (raw == null) return '';
      try {
        DateTime dt;
        if (raw is String) {
          dt = DateTime.parse(raw);
        } else if (raw is Timestamp) {
          dt = raw.toDate();
        } else if (raw is DateTime) {
          dt = raw;
        } else {
          return raw.toString();
        }
        const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
        return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
      } catch (_) {
        return raw.toString();
      }
    }
    final tx = AppTexts.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
                  Expanded(child: Center(child: Text(tx.bloodRequestTitle, style: Theme.of(context).textTheme.titleLarge))),
                  SizedBox(width: 48.w),
                ],
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: BlocBuilder<BloodRequestCubit, BloodRequestState>(
                  builder: (context, state) {
                    if (state.loading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.error != null) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset(AppImages.bloodAnimation, width: 220.w),
                            SizedBox(height: 12.h),
                            Text('No blood group found', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
                          ],
                        ),
                      );
                    }
                    final posts = state.items;
                    if (posts.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Lottie.asset(AppImages.bloodAnimation, width: 220.w),
                            SizedBox(height: 12.h),
                            Text('No blood group found', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: posts.length,
                      separatorBuilder: (_, _) => SizedBox(height: 12.h),
                      itemBuilder: (context, i) {
                        final p = posts[i];
                        final item = BloodRequestItem(
                          title: (p['name'] ?? '') as String,
                          hospital: (p['hospital'] ?? '') as String,
                          date: formatDate(p['date'] ?? p['createdAt']),
                          bloodGroup: (p['bloodGroup'] ?? '') as String,
                        );
                        return InkWell(
                          onTap: () {
                            // Add to recently viewed and navigate
                            context.read<RecentlyViewedCubit>().addViewed(p);
                            context.pushNamed('bloodRequestDetails', extra: p);
                          },
                          child: BloodRequestCard(item: item),
                        );
                      },
                    );
                  },
                ),
              ),
              SizedBox(height: 12.h),
              Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.redAccent),
                    borderRadius: BorderRadius.circular(24.r),
                    color: Colors.white,
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 6))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(tx.bloodWithGroup(widget.group ?? 'B+'), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.redAccent, fontWeight: FontWeight.w700)),
                      SizedBox(width: 8.w),
                      const Icon(Icons.keyboard_arrow_up, color: Colors.redAccent),
                    ],
                  ),
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
