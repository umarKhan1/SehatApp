import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:sehatapp/core/theme/app_theme.dart';
import 'package:sehatapp/core/widgets/buttons/primary_button.dart';
import 'package:sehatapp/core/widgets/inputs/app_text_field.dart';
import 'package:sehatapp/features/auth/bloc/validation/signup_validation_cubit.dart';
import 'package:sehatapp/l10n/app_localizations.dart';

class SignupPage extends StatelessWidget {
  const SignupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      body: BlocListener<SignupValidationCubit, SignupValidationState>(
        listenWhen: (prev, curr) => prev.success != curr.success && curr.success,
        listener: (context, state) {
          context.goNamed('profileSetupStep1');
        },
        child: BlocBuilder<SignupValidationCubit, SignupValidationState>(
          builder: (context, state) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 80.h),
                    Text(t.signupTitle, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                    SizedBox(height: 8.h),
                    Text(t.signupSubtitle, style: Theme.of(context).textTheme.bodyMedium),
                    SizedBox(height: 24.h),
                    AppTextField(
                      label: t.nameLabel,
                      hint: t.nameHint,
                      onChanged: context.read<SignupValidationCubit>().onNameChanged,
                    ),
                    SizedBox(height: 16.h),
                    AppTextField(
                      label: t.emailLabel,
                      hint: t.emailHint,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: context.read<SignupValidationCubit>().onEmailChanged,
                    ),
                    SizedBox(height: 16.h),
                    AppTextField(
                      label: t.passwordLabel,
                      hint: t.passwordHint,
                      obscureText: !state.passwordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(state.passwordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => context.read<SignupValidationCubit>().togglePasswordVisibility(),
                      ),
                      onChanged: context.read<SignupValidationCubit>().onPasswordChanged,
                    ),
                    SizedBox(height: 16.h),
                    AppTextField(
                      label: t.confirmPasswordLabel,
                      hint: t.confirmPasswordHint,
                      obscureText: !state.confirmPasswordVisible,
                      suffixIcon: IconButton(
                        icon: Icon(state.confirmPasswordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => context.read<SignupValidationCubit>().toggleConfirmPasswordVisibility(),
                      ),
                      onChanged: context.read<SignupValidationCubit>().onConfirmPasswordChanged,
                    ),
                    SizedBox(height: 16.h),
                    PrimaryButton(
                      label: t.signUp,
                      enabled: state.isValid && !state.submitting,
                      onPressed: () => context.read<SignupValidationCubit>().submit(),
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                          child: Text(t.orLoginWith, style: Theme.of(context).textTheme.bodySmall),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Expanded(
                          child: _SocialButton(label: t.facebook, icon: Icons.facebook, onPressed: () {}),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _SocialButton(label: t.google, icon: Icons.g_mobiledata, onPressed: () {}),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(t.alreadyHaveAccount, style: Theme.of(context).textTheme.bodyMedium),
                        TextButton(
                          onPressed: () => context.goNamed('login'),
                          child: Text(t.login ,style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w900
                          )),
                        ),
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
        icon: Icon(icon, size: 24.sp, color: label.toLowerCase().contains('facebook') ? Colors.blue : Colors.red),
        label: Text(label, style: Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: label.toLowerCase().contains('facebook') ? Colors.blue : Colors.red,
          fontWeight: FontWeight.bold,
        )),
      ),
    );
  }
}
