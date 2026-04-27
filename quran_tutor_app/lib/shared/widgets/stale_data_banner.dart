import 'package:flutter/material.dart';

/// Banner shown when offline data is displayed
class StaleDataBanner extends StatelessWidget {
  final VoidCallback? onRefresh;
  final bool isVisible;

  const StaleDataBanner({
    super.key,
    this.onRefresh,
    this.isVisible = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.orange.withOpacity(0.9),
      child: SafeArea(
        child: Row(
          children: [
            const Icon(
              Icons.signal_wifi_off,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'You are offline',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Showing cached data. Changes will sync when you reconnect.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                  ),
                ],
              ),
            ),
            if (onRefresh != null)
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: onRefresh,
                tooltip: 'Retry connection',
              ),
          ],
        ),
      ),
    );
  }
}
