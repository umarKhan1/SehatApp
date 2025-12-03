import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sehatapp/core/localization/app_texts.dart';
import 'package:sehatapp/features/blood_request/presentation/pages/blood_request_details_page.dart';
import 'package:sehatapp/features/blood_request/presentation/widgets/blood_request_card.dart';
import 'package:sehatapp/features/blood_request/presentation/widgets/blood_request_item.dart';

class BloodRequestPage extends StatelessWidget {
  const BloodRequestPage({super.key, this.group});
  final String? group;

  @override
  Widget build(BuildContext context) {
    final items = List.generate(
      5,
      (i) => BloodRequestItem(
        title: 'Emergency ${group ?? 'B+'} Blood Needed',
        hospital: 'Hospital Name',
        date: '12 Feb 2022',
        bloodGroup: group ?? 'B+',
      ),
    );
    final tx = AppTexts.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with back and centered title
              Row(
                children: [
                  IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.of(context).maybePop()),
                  Expanded(
                      child: Center(
                          child: Text(tx.bloodRequestTitle,
                              style: Theme.of(context).textTheme.titleLarge))),
                  SizedBox(width: 48.w),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Text(tx.bloodRequestBreadcrumb,
                      style: Theme.of(context).textTheme.bodyMedium),
                  SizedBox(width: 8.w),
                  const Icon(Icons.location_on, color: Colors.redAccent, size: 18),
                  Text('Dhaka',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.w700)),
                ],
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: ListView.separated(
                  itemCount: items.length,
                  separatorBuilder: (_, _) => SizedBox(height: 12.h),
                  itemBuilder: (context, i) {
                    final item = items[i];
                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BloodRequestDetailsPage(
                              title: item.title,
                              bloodGroup: item.bloodGroup,
                            ),
                          ),
                        );
                      },
                      child: BloodRequestCard(item: item),
                    );
                  },
                ),
              ),
              SizedBox(height: 12.h),
              Center(
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.redAccent),
                    borderRadius: BorderRadius.circular(24.r),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: const Offset(0, 6))
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(tx.bloodWithGroup(group ?? 'B+'),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w700)),
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
