import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatapp/features/recently_viewed/bloc/recently_viewed_cubit.dart';
import 'package:sehatapp/features/recently_viewed/presentation/widgets/recently_viewed_list.dart';

class RecentlyViewedPage extends StatefulWidget {
  const RecentlyViewedPage({super.key});

  @override
  State<RecentlyViewedPage> createState() => _RecentlyViewedPageState();
}

class _RecentlyViewedPageState extends State<RecentlyViewedPage> {
  @override
  void initState() {
    super.initState();
    // Load full list when entering the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<RecentlyViewedCubit>().loadAll();
    });
  }

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
                  IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
                  Expanded(
                    child: Center(
                      child: Text('Recently viewed', style: Theme.of(context).textTheme.titleLarge),
                    ),
                  ),
                  SizedBox(width: 48.w),
                ],
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: BlocBuilder<RecentlyViewedCubit, RecentlyViewedState>(
                  builder: (context, state) {
                    final items = state.allItems; // use full list for this page
                    if (items.isEmpty) {
                      return Center(child: Text('No recently viewed'));
                    }
                    // Scrollable list to avoid overflow
                    final uiItems = items.map((p) => RecentlyViewedItem(
                      id: (p['id'] ?? '') as String,
                      title: (p['name'] ?? '') as String,
                      hospital: (p['hospital'] ?? '') as String,
                      date: (p['date'] ?? '') as String,
                      bloodGroup: (p['bloodGroup'] ?? '') as String,
                      mobile: (p['mobile'] ?? '') as String?,
                      bags: (p['bags'] ?? '') as String?,
                      country: (p['country'] ?? '') as String?,
                      city: (p['city'] ?? '') as String?,
                    )).toList();
                    return ListView.separated(
                      itemCount: uiItems.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, i) {
                        final item = uiItems[i];
                        return RecentlyViewedList(
                          items: [item],
                          onItemTap: (tapped) {
                            final full = items.firstWhere((e) => (e['id'] ?? '') == tapped.id, orElse: () => {
                              'id': tapped.id,
                              'name': tapped.title,
                              'hospital': tapped.hospital,
                              'date': tapped.date,
                              'bloodGroup': tapped.bloodGroup,
                              'mobile': tapped.mobile,
                              'bags': tapped.bags,
                              'country': tapped.country,
                              'city': tapped.city,
                            });
                            context.pushNamed('bloodRequestDetails', extra: full);
                          },
                        );
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
