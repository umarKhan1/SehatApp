import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PermissionsService {
  static const String _onboardingCompleteKey =
      'permissions_onboarding_complete';

  /// Check if user has completed permissions onboarding
  Future<bool> hasCompletedOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  /// Mark permissions onboarding as complete
  Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, true);
  }

  /// Request all app permissions
  Future<Map<Permission, PermissionStatus>> requestAllPermissions() async {
    final permissions = [
      Permission.notification,
      Permission.microphone,
      Permission.camera,
    ];

    final statuses = await permissions.request();
    return statuses;
  }

  /// Check status of all permissions
  Future<Map<Permission, PermissionStatus>> checkPermissionsStatus() async {
    return {
      Permission.notification: await Permission.notification.status,
      Permission.microphone: await Permission.microphone.status,
      Permission.camera: await Permission.camera.status,
    };
  }

  /// Request notification permission only
  Future<PermissionStatus> requestNotificationPermission() async {
    return await Permission.notification.request();
  }

  /// Request microphone permission only
  Future<PermissionStatus> requestMicrophonePermission() async {
    return await Permission.microphone.request();
  }

  /// Request camera permission only
  Future<PermissionStatus> requestCameraPermission() async {
    return await Permission.camera.request();
  }

  /// Check if notification permission is granted
  Future<bool> isNotificationGranted() async {
    return await Permission.notification.isGranted;
  }

  /// Check if microphone permission is granted
  Future<bool> isMicrophoneGranted() async {
    return await Permission.microphone.isGranted;
  }

  /// Check if camera permission is granted
  Future<bool> isCameraGranted() async {
    return await Permission.camera.isGranted;
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }
}
