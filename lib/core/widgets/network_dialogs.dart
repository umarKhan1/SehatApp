import 'package:flutter/material.dart';
import 'package:sehatapp/l10n/app_localizations.dart';

/// Helper class to show network-related dialogs
class NetworkDialogs {
  /// Show a dialog when there's no internet connection for calls
  static Future<void> showNoInternetForCall(BuildContext context) async {
    final tx = AppLocalizations.of(context)!;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tx.checkYourConnection),
        content: Text(tx.noInternetForCall),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(tx.ok),
          ),
        ],
      ),
    );
  }

  /// Show a dialog when there's no internet connection for creating posts
  static Future<void> showNoInternetForPost(BuildContext context) async {
    final tx = AppLocalizations.of(context)!;

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(tx.checkYourConnection),
        content: Text(tx.noInternetForPost),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(tx.ok),
          ),
        ],
      ),
    );
  }
}
