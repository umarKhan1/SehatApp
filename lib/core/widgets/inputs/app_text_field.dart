import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.obscureText = false,
    this.onChanged,
    this.suffixIcon,
  });

  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            suffixIcon: suffixIcon,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
