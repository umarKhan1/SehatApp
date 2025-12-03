import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../widgets/settings_tile.dart';
import '../widgets/settings_switch_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _mood = true;
  bool _notifications = true;

  void _shareApp() {
    // TODO: integrate share_plus later
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share App coming soon')));
  }

  void _changeLanguage() {
    // TODO: show language picker bottom sheet
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Language picker coming soon')));
  }

  void _deleteAccount() {
    // TODO: confirm & delete account
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Delete account coming soon')));
  }

  void _logout() {
    // TODO: sign out & navigate to login
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Logout coming soon')));
  }

  @override
  Widget build(BuildContext context) {
    final divider = const Divider(height: 1);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              Row(
                children: [
                  IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).maybePop()),
                  Expanded(child: Center(child: Text('Settings', style: Theme.of(context).textTheme.titleLarge))),
                  SizedBox(width: 48.w),
                ],
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: ListView(
                  children: [
                    SettingsTile(icon: Icons.language, color: const Color(0xFFFFE9C4), title: 'Language', onTap: _changeLanguage),
                    divider,
                    SettingsSwitchTile(icon: Icons.mood, color: const Color(0xFFEFFAF1), title: 'Mood', value: _mood, onChanged: (v) => setState(() => _mood = v)),
                    divider,
                    SettingsSwitchTile(icon: Icons.notifications_active, color: const Color(0xFFE9E9FF), title: 'Notifications', value: _notifications, onChanged: (v) => setState(() => _notifications = v)),
                    divider,
                    SettingsTile(icon: Icons.share, color: const Color(0xFFE9F5FF), title: 'Share App', onTap: _shareApp),
                    divider,
                    SettingsTile(icon: Icons.delete_forever, color: const Color(0xFFFFE9EE), title: 'Delete Account', onTap: _deleteAccount),
                    divider,
                    SettingsTile(icon: Icons.logout, color: const Color(0xFFFFE9E0), title: 'Logout', onTap: _logout),
                    divider,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
