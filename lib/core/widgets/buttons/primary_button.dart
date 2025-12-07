import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sehatapp/core/theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool enabled;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final isEnabled = enabled && !loading;
    return SizedBox(
      height: 52.h,
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled ? AppTheme.primary : AppTheme.primary.withAlpha(120),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        ),
        onPressed: isEnabled ? onPressed : null,
        child: loading
            ? SizedBox(height: 20.w, width: 20.w, child: const CircularProgressIndicator(strokeWidth: 2.2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
            : Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
