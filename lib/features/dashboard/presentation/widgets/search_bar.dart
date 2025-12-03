import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatapp/core/localization/app_texts.dart';

class SearchBarHero extends StatelessWidget {
  const SearchBarHero({super.key});

  @override
  Widget build(BuildContext context) {
    final tx = AppTexts.of(context);
    return Hero(
      tag: 'search-bar',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.pushNamed('search'),
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
                Text(
                  tx.searchBlood,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.black45),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
