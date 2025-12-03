// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sehatapp/features/more/presentation/pages/language_page.dart';
import 'package:sehatapp/features/more/presentation/widgets/settings_switch_tile.dart';
import 'package:sehatapp/features/more/presentation/widgets/settings_tile.dart';
import 'package:sehatapp/l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _mood = true;
  bool _notifications = true;

  void _shareApp() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.shareApp)));
  }

  void _changeLanguage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LanguagePage()));
  }

  Future<bool?> _showConfirmDialog({required String title, required String message, required List<Widget> actions}) {
    return showDialog<bool>(
      context: context,

      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
        contentPadding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
        titlePadding: EdgeInsets.fromLTRB(24.w, 16.h, 16.w, 0),
        title: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
        content: Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black54),
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: EdgeInsets.symmetric(vertical: 12.h),
        actions: actions
            .map((w) => Padding(padding: EdgeInsets.symmetric(horizontal: 8.w), child: w))
            .toList(),
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final t = AppLocalizations.of(context)!;
    final primary = Theme.of(context).primaryColor;
    final result = await _showConfirmDialog(
      title: t.deleteAccount,
      message: t.areYouSureDeleteAccount,
      actions: [
        OutlinedButton(
          
          onPressed: () => Navigator.of(context).pop(true),
          style: OutlinedButton.styleFrom(
            
            foregroundColor: primary,
            side: BorderSide(color: primary),
            fixedSize: Size(100.w, 40.h),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
          child: Text(t.yes),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: FilledButton.styleFrom(
            backgroundColor: primary,
             fixedSize: Size(100.w, 40.h),
            padding: EdgeInsets.symmetric(horizontal: 10  .w, vertical: 12.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
          child: Text(t.no),
        ),
      ],
    );
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.deleteAccount)));
    }
  }

  Future<void> _confirmLogout() async {
    final t = AppLocalizations.of(context)!;
    final primary = Theme.of(context).primaryColor;
    final result = await _showConfirmDialog(
      title: t.logout,
      message: t.areYouSureLogout,
      actions: [
        OutlinedButton(
          onPressed: () => Navigator.of(context).pop(false),
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: BorderSide(color: primary),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
          child: Text(t.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: primary,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          ),
          child: Text(t.logout),
        ),
      ],
    );
    if (result == true) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.logout)));
    }
  }

  void _deleteAccount() {
    _confirmDeleteAccount();
  }

  void _logout() {
    _confirmLogout();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
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
                  Expanded(child: Center(child: Text(t.settings, style: Theme.of(context).textTheme.titleLarge))),
                  SizedBox(width: 48.w),
                ],
              ),
              SizedBox(height: 12.h),
              Expanded(
                child: ListView(
                  children: [
                    SettingsTile(icon: Icons.language, color: const Color(0xFFFFE9C4), title: t.language, onTap: _changeLanguage),
                    divider,
                    SettingsSwitchTile(icon: Icons.mood, color: const Color(0xFFEFFAF1), title: t.mood, value: _mood, onChanged: (v) => setState(() => _mood = v)),
                    divider,
                    SettingsSwitchTile(icon: Icons.notifications_active, color: const Color(0xFFE9E9FF), title: t.notifications, value: _notifications, onChanged: (v) => setState(() => _notifications = v)),
                    divider,
                    SettingsTile(icon: Icons.share, color: const Color(0xFFE9F5FF), title: t.shareApp, onTap: _shareApp),
                    divider,
                    SettingsTile(icon: Icons.delete_forever, color: const Color(0xFFFFE9EE), title: t.deleteAccount, onTap: _deleteAccount),
                    divider,
                    SettingsTile(icon: Icons.logout, color: const Color(0xFFFFE9E0), title: t.logout, onTap: _logout),
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
