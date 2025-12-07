import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatapp/core/localization/app_texts.dart';
import 'package:sehatapp/features/recently_viewed/bloc/recently_viewed_cubit.dart';
import 'package:sehatapp/features/search/bloc/search_cubit.dart';
import 'package:sehatapp/features/search/models/search_item.dart';
import 'package:sehatapp/features/search/presentation/widgets/empty_search_view.dart';
import 'package:sehatapp/features/search/presentation/widgets/search_result_card.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _ctrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Clear previous search state and input when entering the page
    _ctrl.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<SearchCubit>().clear();
      }
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onQueryChanged(String v) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () {
      context.read<SearchCubit>().search(v);
    });
  }

  @override
  Widget build(BuildContext context) {
    final tx = AppTexts.of(context);
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h + MediaQuery.of(context).padding.top, 16.w, 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top bar: back button and centered title
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      tx.searchTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                ),
                SizedBox(width: 48.w), // spacer to balance back button width
              ],
            ),
            SizedBox(height: 12.h),
            Hero(
              tag: 'search-bar',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6FA),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.black38),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          decoration: InputDecoration.collapsed(hintText: tx.searchHint),
                          onChanged: _onQueryChanged,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            BlocBuilder<SearchCubit, SearchState>(
              builder: (context, state) {
                final q = state.query.trim();
                return RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyMedium,
                    children: [
                      TextSpan(text: tx.searchResultFor('')), // prefix only
                      TextSpan(text: q.isEmpty ? '' : ' "$q"', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                    ],
                  ),
                );
              },
            ),
 
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) {
                  final items = state.results;
                  final hasQuery = state.query.trim().isNotEmpty;
                  if (state.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!hasQuery) {
                    // Initial screen shows the empty lottie centered
                    return const EmptySearchView();
                  }
                  if (hasQuery && items.isEmpty) {
                    return const EmptySearchView();
                  }
                  return AnimatedSwitcher(
                    duration: const Duration(microseconds: 500),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: ListView.separated(
                      key: ValueKey('list-${state.query}-${items.length}'),
                      itemCount: items.length,
                      separatorBuilder: (_,_) => SizedBox(height: 8.h),
                      itemBuilder: (context, i) {
                        final item = items[i];
                        final map = item.toMap();
                        return SearchResultCard(
                          item: SearchItem.fromPost(map),
                          onTap: () {
                            context.read<RecentlyViewedCubit>().addViewed(map);
                            context.pushNamed('bloodRequestDetails', extra: map);
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
