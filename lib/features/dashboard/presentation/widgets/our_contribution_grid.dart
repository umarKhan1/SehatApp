import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sehatapp/core/localization/app_texts.dart';

class ContributionStat {
  ContributionStat({required this.value, required this.label, required this.bg, required this.valueColor});
  final String value;
  final String label;
  final Color bg;
  final Color valueColor;
}

class OurContributionGrid extends StatelessWidget {
  const OurContributionGrid({super.key, required this.stats});
  final List<ContributionStat> stats;

  @override
  Widget build(BuildContext context) {
    final tx = AppTexts.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(tx.ourContributionTitle, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        SizedBox(height: 12.h),
        LayoutBuilder(
          builder: (context, constraints) {
            // Determine columns based on available width
            final width = constraints.maxWidth;
            final crossAxisCount = width < 520 ? 2 : 3; // small -> 2x2, large -> 3x3
            // Adjust aspect ratio so cards fit without overflow on smaller screens
            final childAspectRatio = width < 520 ? 1.5 : 1.6;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 12.h,
                crossAxisSpacing: 12.w,
                childAspectRatio: childAspectRatio,
              ),
              itemCount: stats.length,
              itemBuilder: (context, i) => _ContributionCard(stat: stats[i]),
            );
          },
        ),
      ],
    );
  }
}

class _ContributionCard extends StatelessWidget {
  const _ContributionCard({required this.stat});
  final ContributionStat stat;
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: stat.bg,
        borderRadius: BorderRadius.circular(16.r),
      ),
      padding: EdgeInsets.all(16.w),
      child: Column(
      
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            stat.value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(color: stat.valueColor, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            stat.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
