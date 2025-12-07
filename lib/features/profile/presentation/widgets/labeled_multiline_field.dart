import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LabeledMultilineField extends StatefulWidget {
  const LabeledMultilineField({super.key, required this.label, required this.hint, required this.initialText, required this.onChanged});
  final String label;
  final String hint;
  final String initialText;
  final ValueChanged<String> onChanged;

  @override
  State<LabeledMultilineField> createState() => _LabeledMultilineFieldState();
}

class _LabeledMultilineFieldState extends State<LabeledMultilineField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialText);
  }

  @override
  void didUpdateWidget(covariant LabeledMultilineField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update the controller when the initial text prop truly changed
    // and differs from the current controller value. This avoids clearing
    // user input on normal rebuilds when initialText is a constant.
    if (oldWidget.initialText != widget.initialText && widget.initialText != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.initialText,
        selection: TextSelection.collapsed(offset: widget.initialText.length),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(widget.label, style: Theme.of(context).textTheme.bodyMedium),
        SizedBox(height: 8.h),
        Container(
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
        ),
      ],
    );
  }
}
