import 'package:flutter/material.dart';

class SuccessNotification extends StatelessWidget {
  final String message;
  final VoidCallback? onDismiss;
  final Duration duration;

  const SuccessNotification({
    super.key,
    required this.message,
    this.onDismiss,
    this.duration = const Duration(seconds: 3),
  });

  static void show(
    BuildContext context, {
    required String message,
    VoidCallback? onDismiss,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: SuccessNotification(
          message: message,
          onDismiss: onDismiss,
          duration: duration,
        ),
        backgroundColor: Colors.green.shade50,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.check_circle,
          color: Colors.green.shade700,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              color: Colors.green.shade900,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (onDismiss != null)
          IconButton(
            icon: Icon(
              Icons.close,
              color: Colors.green.shade700,
              size: 20,
            ),
            onPressed: onDismiss,
          ),
      ],
    );
  }
} 