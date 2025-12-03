import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sehatapp/core/theme/app_theme.dart';

class NextButton extends StatelessWidget {
  const NextButton({super.key, required this.isContinue, required this.onPressed});
  final bool isContinue;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56.w,
      height: 56.w,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          shape: const CircleBorder(),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Icon(
          size: 20,
          isContinue ? Icons.check : Icons.arrow_forward_ios,
          color: Colors.white,
        ),
      ),
    );
  }
}
