import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatapp/core/constants/app_strings.dart';
import 'package:sehatapp/core/constants/app_options.dart';
import 'package:sehatapp/core/widgets/buttons/primary_button.dart';
import 'package:sehatapp/core/widgets/inputs/app_text_field.dart';
import 'package:sehatapp/features/profile/bloc/profile_setup_cubit.dart';

class ProfileSetupStep1Page extends StatefulWidget {
  const ProfileSetupStep1Page({super.key});

  @override
  State<ProfileSetupStep1Page> createState() => _ProfileSetupStep1PageState();
}

class _ProfileSetupStep1PageState extends State<ProfileSetupStep1Page> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    final s = context.read<ProfileSetupCubit>().state;
    _nameCtrl = TextEditingController(text: s.name);
    _phoneCtrl = TextEditingController(text: s.phone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileSetupCubit, ProfileSetupState>(
      listenWhen: (prev, curr) => prev.step != curr.step,
      listener: (context, state) {
        if (state.step == 2) {
          // When using legacy step pages, still push step2 for backward compatibility
          context.pushNamed('profileSetupStep2');
        }
      },
      child: BlocBuilder<ProfileSetupCubit, ProfileSetupState>(
        builder: (context, state) {
          final List<String> countries = AppOptions.countries;
          final List<String> bloodGroups = AppOptions.bloodGroups;
          final List<String> cities = AppOptions.citiesByCountry[state.country] ?? const [];
          final bool cityEnabled = state.country.isNotEmpty && cities.isNotEmpty;

          return Scaffold(
            
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 28.h),
                      Text(AppStrings.profileSetupOptionalNote, style: Theme.of(context).textTheme.bodyMedium),
                      SizedBox(height: 24.h),
                      Center(
                        child: Container(
                          width: 88.w,
                          height: 88.w,
                          decoration: const BoxDecoration(color: Color(0xFFFFEEEE), shape: BoxShape.circle),
                          child: const Icon(Icons.person_outline, color: Colors.redAccent, size: 36),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Center(
                        child: Text(AppStrings.personalInformation, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                      ),
                      SizedBox(height: 24.h),
                      AppTextField(
                        label: AppStrings.yourNameLabel,
                        hint: AppStrings.userNameHint,
                        controller: _nameCtrl,
                        onChanged: context.read<ProfileSetupCubit>().onNameChanged,
                      ),
                      SizedBox(height: 16.h),
                      AppTextField(
                        label: AppStrings.mobileNumberLabel,
                        hint: AppStrings.userNameHint,
                        keyboardType: TextInputType.phone,
                        controller: _phoneCtrl,
                        onChanged: context.read<ProfileSetupCubit>().onPhoneChanged,
                      ),
                      SizedBox(height: 16.h),
                      // Blood group dropdown
                      Text(AppStrings.selectGroupLabel, style: Theme.of(context).textTheme.bodyMedium),
                      SizedBox(height: 8.h),
                      _Dropdown<String>(
                        value: state.bloodGroup.isEmpty ? null : state.bloodGroup,
                        items: bloodGroups,
                        hint: AppStrings.bloodGroupHint,
                        onChanged: (v) => context.read<ProfileSetupCubit>().onBloodGroupChanged(v ?? ''),
                      ),
                      SizedBox(height: 16.h),
                      // Country dropdown
                      Text(AppStrings.countryLabel, style: Theme.of(context).textTheme.bodyMedium),
                      SizedBox(height: 8.h),
                      _Dropdown<String>(
                        value: state.country.isEmpty ? null : state.country,
                        items: countries,
                        hint: AppStrings.countryHint,
                        onChanged: (v) {
                          final val = v ?? '';
                          final cubit = context.read<ProfileSetupCubit>()
                          ..onCountryChanged(val);
                          if (!(AppOptions.citiesByCountry[val] ?? const []).contains(state.city)) {
                            cubit.onCityChanged('');
                          }
                        },
                      ),
                      SizedBox(height: 16.h),
                      // City dropdown (depends on country)
                      Text(AppStrings.cityLabel, style: Theme.of(context).textTheme.bodyMedium),
                      SizedBox(height: 8.h),
                      AbsorbPointer(
                        absorbing: !cityEnabled,
                        child: Opacity(
                          opacity: cityEnabled ? 1.0 : 0.5,
                          child: _Dropdown<String>(
                            value: state.city.isEmpty ? null : state.city,
                            items: cities,
                            hint: AppStrings.cityHint,
                            onChanged: (v) => context.read<ProfileSetupCubit>().onCityChanged(v ?? ''),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      PrimaryButton(
                        label: AppStrings.nextLabel,
                        enabled: state.isValid,
                        onPressed: () {
                          context.read<ProfileSetupCubit>().nextStep();
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
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  const _Dropdown({required this.value, required this.items, required this.onChanged, this.hint});
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String? hint;
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
        hint: hint != null ? Text(hint!) : null,
        underline: const SizedBox.shrink(),
        items: items.map((e) => DropdownMenuItem<T>(value: e, child: Text('$e'))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
