import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatapp/core/constants/app_strings.dart';
import 'package:sehatapp/core/theme/app_theme.dart';
import 'package:sehatapp/core/widgets/buttons/primary_button.dart';
import 'package:sehatapp/core/widgets/inputs/app_text_field.dart';
import 'package:sehatapp/features/auth/bloc/validation/login_validation.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<LoginValidationCubit, LoginValidationState>(
          builder: (context, state) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 80.h),
                    Text(AppStrings.loginWelcome, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                    SizedBox(height: 8.h),
                    Text(AppStrings.loginSubtitle, style: Theme.of(context).textTheme.bodyMedium),
                    SizedBox(height: 24.h),
                    AppTextField(
                      label: AppStrings.emailLabel,
                      hint: AppStrings.emailHint,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: context.read<LoginValidationCubit>().onEmailChanged,
                    ),
                    SizedBox(height: 16.h),
                    AppTextField(
                      label: AppStrings.passwordLabel,
                      hint: AppStrings.passwordHint,
                      obscureText: !state.passwordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(state.passwordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => context.read<LoginValidationCubit>().togglePasswordVisibility(),
                      ),
                      onChanged: context.read<LoginValidationCubit>().onPasswordChanged,
                    ),
                    SizedBox(height: 8.h),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(AppStrings.forgotPassword, style: Theme.of(context).textTheme.bodyMedium?.copyWith(decoration: TextDecoration.underline, decorationColor: AppTheme.primary, color: AppTheme.primary)),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    PrimaryButton(
                      label: AppStrings.login,
                      enabled: state.isValid && !state.submitting,
                      onPressed: () => context.read<LoginValidationCubit>().submit(),
                    ),
                    SizedBox(height: 40.h),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Text(AppStrings.orLoginWith, style: Theme.of(context).textTheme.bodySmall),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Expanded(
                          child: _SocialButton(label: AppStrings.facebook, icon: Icons.facebook, onPressed: () {}),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _SocialButton(label: AppStrings.google, icon: Icons.g_mobiledata, onPressed: () {}),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(AppStrings.dontHaveAccount, style: Theme.of(context).textTheme.bodyMedium),
                        TextButton(
                          onPressed: () => context.goNamed('signup'),
                          child: const Text(AppStrings.signup, style: TextStyle(color: AppTheme.primary))),
                      ],
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label, required this.icon, required this.onPressed});
  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.h,
      child: TextButton.icon(
        style: TextButton.styleFrom(
          backgroundColor: const Color(0xFFF5F6FA),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          foregroundColor: Colors.black,
        ),
        onPressed: onPressed,
        icon: Icon(icon, size: 24.sp, color: label == AppStrings.facebook ? Colors.blue : Colors.red),
        label: Text(label, style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: label == AppStrings.facebook ? Colors.blue : Colors.red,
          fontWeight: FontWeight.bold,
        )),
      ),
    );
  }
}
