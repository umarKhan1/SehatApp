import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatapp/core/constants/app_images.dart';

import 'package:sehatapp/core/theme/app_theme.dart';
import 'package:sehatapp/features/onboarding/bloc/onboarding_cubit.dart';
import 'package:sehatapp/features/onboarding/presentation/models/onboarding_item.dart';
import 'package:sehatapp/features/onboarding/presentation/widgets/dots_indicator.dart';
import 'package:sehatapp/features/onboarding/presentation/widgets/next_button.dart';
import 'package:sehatapp/l10n/app_localizations.dart';


class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();

  List<OnboardingItem> _localizedItems(BuildContext context) => [
        OnboardingItem(image: AppImages.ob1, title: AppLocalizations.of(context)!.onboardingTitle1, desc: AppLocalizations.of(context)!.onboardingDesc1),
        OnboardingItem(image: AppImages.ob2, title: AppLocalizations.of(context)!.onboardingTitle2, desc: AppLocalizations.of(context)!.onboardingDesc2),
        OnboardingItem(image: AppImages.ob3, title: AppLocalizations.of(context)!.onboardingTitle3, desc: AppLocalizations.of(context)!.onboardingDesc3),
      ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final items = _localizedItems(context);
    return BlocBuilder<OnboardingCubit, OnboardingState>(
      builder: (context, state) {
        final int pageIndex = state.pageIndex;
        return Scaffold(
          body: Stack(
            children: [
              // Top full-bleed image area
              Positioned.fill(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: items.length,
                  onPageChanged: (i) => context.read<OnboardingCubit>().setPage(i, items.length),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            item.image,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Skip button top-right
                        Positioned(
                          top: 8.h,
                          right: 16.w,
                          child: TextButton(
                            onPressed: () {
                               },
                            child: Text(t.skip),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Bottom card with content
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          items[pageIndex].title,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          items[pageIndex].desc,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black.withAlpha(140)),
                        ),
                        SizedBox(height: 16.h),
                        if (!state.isLast)
                          Row(
                            children: [
                              DotsIndicator(length: items.length, activeIndex: pageIndex),
                              const Spacer(),
                              NextButton(
                                isContinue: state.isLast,
                                onPressed: () {
                                  if (state.isLast) {
                                   } else {
                                    _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                                  }
                                },
                              ),
                            ],
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            height: 52.h,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                              ),
                              onPressed: () {
                                context.goNamed('login');
                              },
                              child: Text(t.getStarted, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w800)),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
