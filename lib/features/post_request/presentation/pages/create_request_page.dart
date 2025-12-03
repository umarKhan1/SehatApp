import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/cupertino.dart';
import 'package:sehatapp/core/constants/app_options.dart';
import 'package:sehatapp/features/profile/presentation/widgets/labeled_dropdown.dart';
import 'package:sehatapp/features/profile/presentation/widgets/labeled_multiline_field.dart';

class CreateRequestPage extends StatefulWidget {
  const CreateRequestPage({super.key});

  @override
  State<CreateRequestPage> createState() => _CreateRequestPageState();
}

class _CreateRequestPageState extends State<CreateRequestPage> {
  String? _bloodGroup;
  String? _country;
  String? _city;
  DateTime? _date;

  void _showCupertinoDatePicker() {
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
                    TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Done'),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: _date ?? DateTime.now(),
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (d) {
                    setState(() => _date = d);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<String> get _cities => _country == null ? [] : (AppOptions.citiesByCountry[_country] ?? []);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  Expanded(child: Center(child: Text('Create Request', style: Theme.of(context).textTheme.titleLarge))),
                  SizedBox(width: 48.w),
                ],
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post Title
                      Text('Post Title', style: Theme.of(context).textTheme.bodyMedium),
                      SizedBox(height: 8.h),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Type title',
                          filled: true,
                          fillColor: const Color(0xFFF8F8F8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                        ),
                      ),

                      SizedBox(height: 12.h),
                      // Select Group (Blood type) using AppOptions
                      LabeledDropdown<String>(
                        label: 'Select Group',
                        value: _bloodGroup,
                        items: AppOptions.bloodGroups,
                        hint: 'Blood group',
                        onChanged: (v) => setState(() => _bloodGroup = v),
                      ),

                      SizedBox(height: 12.h),
                      // Amount of Request Blood
                      Text('Amount of Request Blood', style: Theme.of(context).textTheme.bodyMedium),
                      SizedBox(height: 8.h),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Type how much',
                          filled: true,
                          fillColor: const Color(0xFFF8F8F8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                        ),
                      ),

                      SizedBox(height: 12.h),
                      // Date (Cupertino picker)
                      Text('Date', style: Theme.of(context).textTheme.bodyMedium),
                      SizedBox(height: 8.h),
                      InkWell(
                        onTap: _showCupertinoDatePicker,
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
                                _date == null
                                    ? 'Select Date'
                                    : '${_two(_date!.day)} ${_month(_date!.month)} ${_date!.year}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87),
                              ),
                              const Icon(Icons.calendar_today, size: 18),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 12.h),
                      // Hospital Name
                      Text('Hospital Name', style: Theme.of(context).textTheme.bodyMedium),
                      SizedBox(height: 8.h),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Type hospital name',
                          filled: true,
                          fillColor: const Color(0xFFF8F8F8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                        ),
                      ),

                      SizedBox(height: 12.h),
                      // Why do you need blood? using global LabeledMultilineField
                      LabeledMultilineField(
                        label: 'Why do you need blood?',
                        hint: 'Type why',
                        initialText: '',
                        onChanged: (v) {},
                      ),

                      SizedBox(height: 12.h),
                      // Contact person Name
                      Text('Contact person Name', style: Theme.of(context).textTheme.bodyMedium),
                      SizedBox(height: 8.h),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Type name',
                          filled: true,
                          fillColor: const Color(0xFFF8F8F8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                        ),
                      ),

                      SizedBox(height: 12.h),
                      // Mobile number
                      Text('Mobile number', style: Theme.of(context).textTheme.bodyMedium),
                      SizedBox(height: 8.h),
                      TextField(
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          hintText: 'Type mobile number',
                          filled: true,
                          fillColor: const Color(0xFFF8F8F8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: Colors.black12)),
                        ),
                      ),

                      SizedBox(height: 12.h),
                      // Country dropdown using AppOptions
                      LabeledDropdown<String>(
                        label: 'Country',
                        value: _country,
                        items: AppOptions.countries,
                        hint: 'Select country',
                        onChanged: (v) {
                          setState(() {
                            _country = v;
                            // reset city when country changes
                            _city = null;
                          });
                        },
                      ),

                      SizedBox(height: 12.h),
                      // City dropdown dependent on country
                      LabeledDropdown<String>(
                        label: 'City',
                        value: _city,
                        items: _cities,
                        hint: 'Select city',
                        onChanged: (v) => setState(() => _city = v),
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
                          child: Text('Get Started', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white)),
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            ],
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
