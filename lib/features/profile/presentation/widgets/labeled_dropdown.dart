import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LabeledDropdown<T> extends StatelessWidget {
  const LabeledDropdown({super.key, required this.label, required this.value, required this.items, required this.onChanged, this.hint});
  final String label;
  final T? value;
  final List<T> items;
  final ValueChanged<T?> onChanged;
  final String? hint;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        SizedBox(height: 8.h),
        Container(
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
        ),
      ],
    );
  }
}
