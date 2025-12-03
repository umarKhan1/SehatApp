// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatapp/core/constants/app_strings.dart';
import 'package:sehatapp/core/widgets/buttons/primary_button.dart';
import 'package:sehatapp/features/profile/bloc/profile_setup_cubit.dart';

class ProfileSetupStep2Page extends StatelessWidget {
  const ProfileSetupStep2Page({super.key});

  Future<void> _pickDob(BuildContext context, ProfileSetupState state) async {
    final now = DateTime.now();
    final initial = state.dob ?? DateTime(now.year - 18, now.month, now.day);
    final first = DateTime(now.year - 100);
    final last = now;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (picked != null) {
      context.read<ProfileSetupCubit>().setDob(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure step resets to 1 when popping via system back or gesture
    return PopScope(
    
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
       context.read<ProfileSetupCubit>()
          .prevStep();
        }
      },
      child: BlocListener<ProfileSetupCubit, ProfileSetupState>(
        listenWhen: (prev, curr) => prev.submitting != curr.submitting || prev.isValid != curr.isValid,
        listener: (context, state) {
          // Handle completion navigation later (e.g., to home) after submit success
        },
        child: BlocBuilder<ProfileSetupCubit, ProfileSetupState>(
          builder: (context, state) {
            return Scaffold(
             
              body: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 24.h),
                        IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    context.read<ProfileSetupCubit>().prevStep();
                    context.pop();
                  },
                ),
                        
                        Center(
                          child: Container(
                            width: 88.w,
                            height: 88.w,
                            decoration: const BoxDecoration(color: Color(0xFFFFEEEE), shape: BoxShape.circle),
                            child: const Icon(Icons.cake_outlined, color: Colors.redAccent, size: 36),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Center(
                          child: Text(AppStrings.basicInformation, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        ),
                        SizedBox(height: 24.h),
                        Text(AppStrings.dobLabel, style: Theme.of(context).textTheme.bodyMedium),
                        SizedBox(height: 8.h),
                        InkWell(
                          onTap: () => _pickDob(context, state),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.black12),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  state.dob != null ? _formatDate(state.dob!) : 'Select date',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const Icon(Icons.calendar_today, size: 18),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Text(
                            '${AppStrings.yourAgePrefix}${state.age ?? '--'}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Text(AppStrings.genderLabel, style: Theme.of(context).textTheme.bodyMedium),
                        SizedBox(height: 8.h),
                        _Dropdown<String>(
                          value: state.gender.isEmpty ? null : state.gender,
                          items: const ['Male', 'Female', 'Other'],
                          onChanged: (v) => context.read<ProfileSetupCubit>().onGenderChanged(v ?? ''),
                        ),
                        SizedBox(height: 16.h),
                        Text(AppStrings.donateWishLabel, style: Theme.of(context).textTheme.bodyMedium),
                        SizedBox(height: 8.h),
                        _Dropdown<String>(
                          value: state.wantToDonate == null ? null : (state.wantToDonate! ? 'Yes' : 'No'),
                          items: const ['Yes', 'No'],
                          onChanged: (v) => context.read<ProfileSetupCubit>().onWantToDonateChanged(v == 'Yes'),
                        ),
                        SizedBox(height: 16.h),
                        Text(AppStrings.aboutYourselfLabel, style: Theme.of(context).textTheme.bodyMedium),
                        SizedBox(height: 8.h),
                        _MultilineBox(
                          initialText: state.about,
                          onChanged: context.read<ProfileSetupCubit>().onAboutChanged,
                          hint: AppStrings.aboutYourselfHint,
                        ),
                        SizedBox(height: 24.h),
                        PrimaryButton(
                          label: AppStrings.nextLabel,
                          enabled: state.isValid && !state.submitting,
                          onPressed: () async {
                            await context.read<ProfileSetupCubit>().submit();
                            if (context.mounted) {
                              context.goNamed('shell');
                            }
                          },
                        ),
                        SizedBox(height: 24.h),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    return '${_two(d.day)} ${_month(d.month)} ${d.year}';
  }

  String _two(int n) => n.toString().padLeft(2, '0');
  String _month(int m) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    return months[m-1];
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({required this.value, required this.items, required this.onChanged});
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: DropdownButton<T>(
        isExpanded: true,
        borderRadius: BorderRadius.circular(10.r),
        value: value,
        underline: const SizedBox.shrink(),
        items: items.map((e) => DropdownMenuItem<T>(value: e, child: Text('$e'))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}

class _MultilineBox extends StatefulWidget {
  const _MultilineBox({required this.onChanged, required this.hint, this.initialText});
  final ValueChanged<String> onChanged;
  final String hint;
  final String? initialText;
  @override
  State<_MultilineBox> createState() => _MultilineBoxState();
}

class _MultilineBoxState extends State<_MultilineBox> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText ?? '');
  }

  @override
  void didUpdateWidget(covariant _MultilineBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    final nextText = widget.initialText ?? '';
    if (nextText != _controller.text) {
      _controller.value = TextEditingValue(
        text: nextText,
        selection: TextSelection.collapsed(offset: nextText.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black12),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: TextField(
        controller: _controller,
        onChanged: widget.onChanged,
        maxLines: 6,
        decoration: InputDecoration(
          hintText: widget.hint,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
