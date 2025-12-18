import 'package:flutter/material.dart';

/// Helper class to show network-related dialogs
class NetworkDialogs {
  /// Show a dialog when there's no internet connection for calls
  static Future<void> showNoInternetForCall(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Check your connection'),
        content: const Text(
          'No internet connection available. Please check your connection and try again.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Show a dialog when there's no internet connection for creating posts
  static Future<void> showNoInternetForPost(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Check your connection'),
        content: const Text(
          'No internet connection. Please connect to the internet to create a post.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
