import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quran_tutor_app/core/localization/app_localizations.dart';
import 'package:quran_tutor_app/core/theme/cubit/theme_cubit.dart';

/// Theme toggle widget that can be used in settings/profile
class ThemeToggle extends StatelessWidget {

  const ThemeToggle({
    super.key,
    this.showTitle = true,
    this.useDropdown = false,
  });
  final bool showTitle;
  final bool useDropdown;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        if (useDropdown) {
          return _buildDropdown(context, l10n, state);
        }
        return _buildSegmentedButton(context, l10n, state);
      },
    );
  }

  Widget _buildSegmentedButton(BuildContext context, AppLocalizations l10n, ThemeState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showTitle)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              l10n.t('settings.theme.title'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        SegmentedButton<ThemeMode>(
          segments: [
            ButtonSegment(
              value: ThemeMode.light,
              label: Text(l10n.t('settings.theme.light')),
              icon: const Icon(Icons.light_mode),
            ),
            ButtonSegment(
              value: ThemeMode.dark,
              label: Text(l10n.t('settings.theme.dark')),
              icon: const Icon(Icons.dark_mode),
            ),
            ButtonSegment(
              value: ThemeMode.system,
              label: Text(l10n.t('settings.theme.system')),
              icon: const Icon(Icons.settings_system_daydream),
            ),
          ],
          selected: {state.themeMode},
          onSelectionChanged: (newSelection) {
            final themeMode = newSelection.first;
            _setTheme(context, themeMode);
          },
        ),
      ],
    );
  }

  Widget _buildDropdown(BuildContext context, AppLocalizations l10n, ThemeState state) {
    return ListTile(
      leading: Icon(_getThemeIcon(state.themeMode)),
      title: Text(l10n.t('settings.theme.title')),
      subtitle: Text(_getThemeLabel(l10n, state.themeMode)),
      trailing: DropdownButton<ThemeMode>(
        value: state.themeMode,
        underline: const SizedBox(),
        items: [
          DropdownMenuItem(
            value: ThemeMode.light,
            child: Row(
              children: [
                const Icon(Icons.light_mode, size: 20),
                const SizedBox(width: 8),
                Text(l10n.t('settings.theme.light')),
              ],
            ),
          ),
          DropdownMenuItem(
            value: ThemeMode.dark,
            child: Row(
              children: [
                const Icon(Icons.dark_mode, size: 20),
                const SizedBox(width: 8),
                Text(l10n.t('settings.theme.dark')),
              ],
            ),
          ),
          DropdownMenuItem(
            value: ThemeMode.system,
            child: Row(
              children: [
                const Icon(Icons.settings_system_daydream, size: 20),
                const SizedBox(width: 8),
                Text(l10n.t('settings.theme.system')),
              ],
            ),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            _setTheme(context, value);
          }
        },
      ),
    );
  }

  void _setTheme(BuildContext context, ThemeMode themeMode) {
    final cubit = context.read<ThemeCubit>();
    switch (themeMode) {
      case ThemeMode.light:
        cubit.setLight();
      case ThemeMode.dark:
        cubit.setDark();
      case ThemeMode.system:
        cubit.setSystem();
    }
  }

  IconData _getThemeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.settings_system_daydream;
    }
  }

  String _getThemeLabel(AppLocalizations l10n, ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return l10n.t('settings.theme.light');
      case ThemeMode.dark:
        return l10n.t('settings.theme.dark');
      case ThemeMode.system:
        return l10n.t('settings.theme.system');
    }
  }
}

/// Simple theme toggle button for quick theme switching
class ThemeToggleButton extends StatelessWidget {
  const ThemeToggleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return IconButton(
          icon: Icon(
            state.isDark ? Icons.dark_mode : Icons.light_mode,
          ),
          onPressed: () => context.read<ThemeCubit>().toggle(),
          tooltip: AppLocalizations.of(context).t('settings.theme.toggle'),
        );
      },
    );
  }
}
