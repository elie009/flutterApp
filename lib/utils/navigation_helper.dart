import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationHelper {
  static void navigateTo(BuildContext context, String route,
      {Map<String, String>? params, Object? extra}) {
    if (params != null) {
      context.goNamed(route, pathParameters: params, extra: extra);
    } else {
      context.goNamed(route, extra: extra);
    }
  }

  static void navigateBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    }
  }

  static void showSnackBar(BuildContext context, String message,
      {Color? backgroundColor, Duration? duration}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration ?? const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void navigateToAddUtility(BuildContext context) {
    // For now, just show a snackbar. Can be extended to navigate to add utility screen
    showSnackBar(context, 'Add utility feature coming soon');
  }
}

