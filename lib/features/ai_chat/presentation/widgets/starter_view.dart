import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StarterView extends StatelessWidget {
  const StarterView({super.key, required this.onQuickAction});
  final Function(String) onQuickAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor.withValues(alpha: 0.05),
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // AI Icon
              Container(
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withValues(alpha: 0.7),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: 50.sp,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 24.h),

              // Title
              Text(
                'How can I help you?',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 12.h),

              // Subtitle
              Text(
                'Choose a topic or ask me anything',
                style: TextStyle(fontSize: 15.sp, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40.h),

              // Quick action chips
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 12.w,
                runSpacing: 12.h,
                children: [
                  _buildActionChip(
                    context,
                    icon: Icons.bloodtype,
                    label: 'Blood donation guidance',
                    onTap: () => onQuickAction('Blood donation guidance'),
                  ),
                  _buildActionChip(
                    context,
                    icon: Icons.health_and_safety,
                    label: 'Health advice',
                    onTap: () => onQuickAction('Health advice'),
                  ),
                  _buildActionChip(
                    context,
                    icon: Icons.summarize,
                    label: 'Summarize this text',
                    onTap: () => onQuickAction('Summarize this text'),
                  ),
                  _buildActionChip(
                    context,
                    icon: Icons.edit_note,
                    label: 'Write or improve content',
                    onTap: () => onQuickAction('Write or improve content'),
                  ),
                  _buildActionChip(
                    context,
                    icon: Icons.translate,
                    label: 'Translation',
                    onTap: () => onQuickAction('Translation'),
                  ),
                  _buildActionChip(
                    context,
                    icon: Icons.lightbulb_outline,
                    label: 'Brainstorm new ideas',
                    onTap: () => onQuickAction('Brainstorm new ideas'),
                  ),
                  _buildActionChip(
                    context,
                    icon: Icons.analytics_outlined,
                    label: 'Analyze this data or chart',
                    onTap: () => onQuickAction('Analyze this data or chart'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20.sp, color: Theme.of(context).primaryColor),
            SizedBox(width: 10.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
