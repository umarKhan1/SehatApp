import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sehatapp/core/services/permissions_service.dart';
import 'package:sehatapp/features/notification/data/notification_service.dart';
import 'package:go_router/go_router.dart';

class PermissionsOnboardingPage extends StatefulWidget {
  const PermissionsOnboardingPage({super.key});

  @override
  State<PermissionsOnboardingPage> createState() =>
      _PermissionsOnboardingPageState();
}

class _PermissionsOnboardingPageState extends State<PermissionsOnboardingPage> {
  final _permissionsService = PermissionsService();
  int _currentStep = 0;
  bool _isRequesting = false;

  final List<_PermissionInfo> _permissions = [
    _PermissionInfo(
      permission: Permission.notification,
      icon: Icons.notifications_active,
      title: 'Enable Notifications',
      description:
          'Stay updated with blood donation requests and important messages from the community.',
    ),
    _PermissionInfo(
      permission: Permission.microphone,
      icon: Icons.mic,
      title: 'Microphone Access',
      description:
          'Make voice calls to coordinate blood donations and connect with donors.',
    ),
    _PermissionInfo(
      permission: Permission.camera,
      icon: Icons.videocam,
      title: 'Camera Access',
      description:
          'Enable video calls for better communication and verification.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentPermission = _permissions[_currentStep];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Progress indicator
              Row(
                children: List.generate(
                  _permissions.length,
                  (index) => Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(
                        right: index < _permissions.length - 1 ? 8 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? Colors.redAccent
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  currentPermission.icon,
                  size: 60,
                  color: Colors.redAccent,
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                currentPermission.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                currentPermission.description,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),

              // Allow button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isRequesting ? null : _handleAllow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isRequesting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Enable ${currentPermission.title.replaceAll(' Access', '')}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 12),

              // Skip button
              TextButton(
                onPressed: _isRequesting ? null : _handleSkip,
                child: Text(
                  _currentStep == _permissions.length - 1
                      ? 'Skip for now'
                      : 'Skip',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleAllow() async {
    setState(() => _isRequesting = true);

    try {
      final permission = _permissions[_currentStep].permission;
      print('[PermissionsOnboarding] Requesting permission: $permission');

      final status = await permission.request();
      print('[PermissionsOnboarding] Permission status: $status');

      // Handle permanently denied permissions
      if (status.isPermanentlyDenied) {
        if (mounted) {
          final shouldOpenSettings = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Permission Required'),
              content: Text(
                'This permission was previously denied. Please enable it in Settings to continue.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Open Settings'),
                ),
              ],
            ),
          );

          if (shouldOpenSettings == true) {
            await openAppSettings();
          }
        }
        return; // Don't move to next step
      }

      // Initialize notification service immediately after user grants notification permission
      if (permission == Permission.notification && status.isGranted) {
        print('[PermissionsOnboarding] Initializing NotificationService');
        try {
          await NotificationService().init();
          print(
            '[PermissionsOnboarding] NotificationService initialized successfully',
          );
        } catch (e) {
          print('[PermissionsOnboarding] NotificationService init error: $e');
        }
      }

      await _moveToNextStep();
    } finally {
      if (mounted) {
        setState(() => _isRequesting = false);
      }
    }
  }

  Future<void> _handleSkip() async {
    await _moveToNextStep();
  }

  Future<void> _moveToNextStep() async {
    if (_currentStep < _permissions.length - 1) {
      setState(() => _currentStep++);
    } else {
      // Completed all steps
      await _permissionsService.markOnboardingComplete();

      if (mounted) {
        context.go('/shell');
      }
    }
  }
}

class _PermissionInfo {
  final Permission permission;
  final IconData icon;
  final String title;
  final String description;

  _PermissionInfo({
    required this.permission,
    required this.icon,
    required this.title,
    required this.description,
  });
}
