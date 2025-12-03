import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sehatapp/core/constants/app_images.dart';
import 'package:sehatapp/features/dashboard/bloc/banner_cubit.dart';

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key});

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final PageController _controller = PageController();
  Timer? _timer;

  final List<String> _banners = const [
    AppImages.banner1,
    AppImages.banner2,
    AppImages.banner3,
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final cubit = context.read<BannerCubit>();
      final next = (cubit.state.index + 1) % _banners.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
      cubit.setIndex(next);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BannerCubit, BannerState>(
      builder: (context, state) {
        return SizedBox(
          height: 140.h,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Stack(
              children: [
                PageView.builder(
                  controller: _controller,
                  itemCount: _banners.length,
                  onPageChanged: (i) => context.read<BannerCubit>().setIndex(i),
                  itemBuilder: (context, i) {
                    return Image.asset(_banners[i], fit: BoxFit.cover);
                  },
                ),
                Positioned(
                  left: 12.w,
                  bottom: 12.h,
                  child: Row(
                    children: List.generate(_banners.length, (i) {
                      final active = i == state.index;
                      return Container(
                        width: active ? 8.w : 6.w,
                        height: active ? 8.w : 6.w,
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        decoration: BoxDecoration(
                          color: active ? Colors.redAccent : Colors.lightBlueAccent,
                          shape: BoxShape.circle,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
