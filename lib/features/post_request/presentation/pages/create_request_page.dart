import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sehatapp/core/constants/app_options.dart';
import 'package:sehatapp/core/localization/app_texts.dart';
import 'package:sehatapp/features/profile/presentation/widgets/labeled_dropdown.dart';
import 'package:sehatapp/features/profile/presentation/widgets/labeled_multiline_field.dart';
import 'package:sehatapp/features/post_request/bloc/create_request_cubit.dart';

class CreateRequestPage extends StatefulWidget {
  const CreateRequestPage({super.key});

  @override
  State<CreateRequestPage> createState() => _CreateRequestPageState();
}

class _CreateRequestPageState extends State<CreateRequestPage> {
  void _showCupertinoDatePicker(BuildContext context) {
    final tx = AppTexts.of(context);
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) {
        return Container(
          height: 260,
          color: Colors.white,
          child: Column(
            children: [
              SizedBox(
                height: 44,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(tx.cancel)),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: Text(tx.save),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: BlocBuilder<CreateRequestCubit, CreateRequestState>(
                  builder: (context, state) {
                    return CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.date,
                      initialDateTime: state.date ?? DateTime.now(),
                      maximumDate: DateTime.now(),
                      onDateTimeChanged: (d) {
                        context.read<CreateRequestCubit>().setDate(d);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<String> _cities(String? country) => country == null ? [] : (AppOptions.citiesByCountry[country] ?? []);

  @override
  Widget build(BuildContext context) {
    final tx = AppTexts.of(context);
    return BlocProvider(
      create: (_) => CreateRequestCubit(),
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 8.h),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).maybePop()),
                    Expanded(child: Center(child: Text(tx.createRequestBlood, style: Theme.of(context).textTheme.titleLarge))),
                    SizedBox(width: 48.w),
                  ],
                ),
                SizedBox(height: 12.h),
                Expanded(
                  child: SingleChildScrollView(
                    child: BlocBuilder<CreateRequestCubit, CreateRequestState>(
                      builder: (context, state) {
                        final cities = _cities(state.country);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Post Title
                            Text(tx.nameLabel, style: Theme.of(context).textTheme.bodyMedium),
                            SizedBox(height: 8.h),
                            TextField(
                              decoration: InputDecoration(
                                hintText: tx.nameHint,
                                filled: true,
                                fillColor: const Color(0xFFF8F8F8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                              ),
                            ),

                            SizedBox(height: 12.h),
                            // Select Group (Blood type)
                            LabeledDropdown<String>(
                              label: tx.selectGroupLabel,
                              value: state.bloodGroup,
                              items: AppOptions.bloodGroups,
                              hint: tx.bloodGroupHint,
                              onChanged: (v) => context.read<CreateRequestCubit>().setBloodGroup(v),
                            ),

                            SizedBox(height: 12.h),
                            // Amount of Request Blood
                            Text(tx.howManyBagsLabel, style: Theme.of(context).textTheme.bodyMedium),
                            SizedBox(height: 8.h),
                            TextField(
                              decoration: InputDecoration(
                                hintText: tx.typeMessageHint,
                                filled: true,
                                fillColor: const Color(0xFFF8F8F8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                              ),
                            ),

                            SizedBox(height: 12.h),
                            // Date
                            Text(tx.dobLabel, style: Theme.of(context).textTheme.bodyMedium),
                            SizedBox(height: 8.h),
                            InkWell(
                              onTap: () => _showCupertinoDatePicker(context),
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8F8F8),
                                  borderRadius: BorderRadius.circular(10.r),
                                  border: Border.all(color: Colors.black12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      state.date == null
                                          ? tx.selectDate
                                          : '${_two(state.date!.day)} ${_month(state.date!.month)} ${state.date!.year}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                                    ),
                                    const Icon(Icons.calendar_today, size: 18),
                                  ],
                                ),
                              ),
                            ),

                            SizedBox(height: 12.h),
                            // Hospital Name
                            Text(tx.hospitalLabel, style: Theme.of(context).textTheme.bodyMedium),
                            SizedBox(height: 8.h),
                            TextField(
                              decoration: InputDecoration(
                                hintText: tx.hospitalName,
                                filled: true,
                                fillColor: const Color(0xFFF8F8F8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                              ),
                            ),

                            SizedBox(height: 12.h),
                            // Why do you need blood?
                            LabeledMultilineField(
                              label: tx.whyNeedBloodTitle,
                              hint: tx.aboutYourselfHint,
                              initialText: '',
                              onChanged: (v) {},
                            ),

                            SizedBox(height: 12.h),
                            // Contact person Name
                            Text(tx.contactPersonLabel, style: Theme.of(context).textTheme.bodyMedium),
                            SizedBox(height: 8.h),
                            TextField(
                              decoration: InputDecoration(
                                hintText: tx.nameHint,
                                filled: true,
                                fillColor: const Color(0xFFF8F8F8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                              ),
                            ),

                            SizedBox(height: 12.h),
                            // Mobile number
                            Text(tx.mobileNumberLabel, style: Theme.of(context).textTheme.bodyMedium),
                            SizedBox(height: 8.h),
                            TextField(
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                hintText: tx.mobileNumberLabel,
                                filled: true,
                                fillColor: const Color(0xFFF8F8F8),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                              ),
                            ),

                            SizedBox(height: 12.h),
                            // Country dropdown
                            LabeledDropdown<String>(
                              label: tx.countryLabel,
                              value: state.country,
                              items: AppOptions.countries,
                              hint: tx.countryHint,
                              onChanged: (v) => context.read<CreateRequestCubit>().setCountry(v),
                            ),

                            SizedBox(height: 12.h),
                            // City dropdown
                            LabeledDropdown<String>(
                              label: tx.cityLabel,
                              value: state.city,
                              items: cities,
                              hint: tx.cityHint,
                              onChanged: (v) => context.read<CreateRequestCubit>().setCity(v),
                            ),

                            SizedBox(height: 20.h),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                ),
                                child: Text(AppTexts.of(context).getStarted, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                              ),
                            ),
                            SizedBox(height: 16.h),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _two(int n) => n.toString().padLeft(2, '0');
  String _month(int m) {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[m-1];
  }
}
