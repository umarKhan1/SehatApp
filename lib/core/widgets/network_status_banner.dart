import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sehatapp/core/network/network_status_cubit.dart';

/// Top banner that shows when offline with retry button
class NetworkStatusBanner extends StatelessWidget {
  const NetworkStatusBanner({super.key, required this.child, this.onRetry});

  final Widget child;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkStatusCubit, NetworkStatus>(
      builder: (context, state) {
        return Column(
          children: [
            // Show banner only when disconnected
            if (state is NetworkDisconnected || state is NetworkChecking)
              _buildBanner(context, state),
            // Main content
            Expanded(child: child),
          ],
        );
      },
    );
  }

  Widget _buildBanner(BuildContext context, NetworkStatus state) {
    final isChecking = state is NetworkChecking;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.red,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Warning icon
            Icon(Icons.wifi_off, color: Colors.white, size: 20.sp),
            SizedBox(width: 12.w),
            // Message
            Expanded(
              child: Text(
                isChecking
                    ? 'Checking connection...'
                    : 'No internet connection',
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
            // Retry button
            if (!isChecking)
              TextButton(
                onPressed: () {
                  context.read<NetworkStatusCubit>().retry();
                  onRetry?.call();
                },
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Retry',
                  style: GoogleFonts.poppins(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            // Loading indicator when checking
            if (isChecking)
              SizedBox(
                width: 16.w,
                height: 16.h,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
