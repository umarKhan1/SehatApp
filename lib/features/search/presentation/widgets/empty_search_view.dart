import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:sehatapp/core/constants/app_images.dart';
import 'package:sehatapp/core/localization/app_texts.dart';

class EmptySearchView extends StatelessWidget {
  const EmptySearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final tx = AppTexts.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 180.h,
            child: Lottie.asset(AppImages.searchAnimations),
          ),
          SizedBox(height: 12.h),
          Text(tx.noPostsFound, style: Theme.of(context).textTheme.titleLarge),
        ],
      ),
    );
  }
}
