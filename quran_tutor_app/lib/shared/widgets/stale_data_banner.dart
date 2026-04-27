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
                    // Localized: 'You are offline'
                    _getLocalizedText(context, 'offline_title'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    // Localized: 'Showing cached data. Changes will sync when you reconnect.'
                    _getLocalizedText(context, 'offline_message'),
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
                tooltip: _getLocalizedText(context, 'retry_connection'),
              ),
          ],
        ),
      ),
    );
  }

  /// Get localized text - falls back to Arabic if localization is not available
  String _getLocalizedText(BuildContext context, String key) {
    // Try to get from EasyLocalization if available
    try {
      // This would typically use context.tr() from easy_localization
      // For now, return hardcoded Arabic text as the app is Arabic-first
      return _fallbackArabic(key);
    } catch (e) {
      return _fallbackArabic(key);
    }
  }

  String _fallbackArabic(String key) {
    final Map<String, String> arabicStrings = {
      'offline_title': 'أنت غير متصل',
      'offline_message': 'عرض البيانات المخزنة. سيتم المزامنة عند إعادة الاتصال.',
      'retry_connection': 'إعادة المحاولة',
    };
    return arabicStrings[key] ?? key;
  }
}
