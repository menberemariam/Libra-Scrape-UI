// lib/widgets/error_widget.dart
import 'package:flutter/material.dart';

class CustomErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const CustomErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.errorContainer.withValues(alpha: 0.7),
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 34,
                color: scheme.error,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'We couldn’t load the library',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 380),
              child: Text(
                _readableMessage(message),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try again'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Keeps internal error prefixes out of the customer-facing message.
  String _readableMessage(String raw) {
    var text = raw
        .replaceFirst('ApiException: ', '')
        .replaceFirst('NetworkException: ', '')
        .replaceFirst('NotFoundException: ', '');
    if (text.startsWith('Error loading items: ')) {
      text = text.substring('Error loading items: '.length);
    }
    if (text.length > 220) {
      text = '${text.substring(0, 220)}…';
    }
    return text;
  }
}
