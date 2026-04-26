import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_constants.dart';

/// App localizations delegate
class AppLocalizations {
  final Locale locale;
  late Map<String, dynamic> _localizedStrings;

  AppLocalizations(this.locale);

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  /// Load the language JSON file
  Future<bool> load() async {
    String jsonString = await rootBundle
        .loadString('\${AppConstants.translationsPath}/\${locale.languageCode}.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    _localizedStrings = jsonMap;
    return true;
  }

  /// Translate a key with optional parameters
  String translate(String key, {Map<String, dynamic>? args}) {
    List<String> keys = key.split('.');
    dynamic value = _localizedStrings;
    
    for (String k in keys) {
      if (value is Map<String, dynamic>) {
        value = value[k];
      } else {
        return key;
      }
    }
    
    if (value == null) return key;
    
    String result = value.toString();
    
    if (args != null) {
      args.forEach((paramKey, paramValue) {
        result = result.replaceAll('{\$paramKey}', paramValue.toString());
      });
    }
    
    return result;
  }

  /// Short alias for translate
  String t(String key, {Map<String, dynamic>? args}) => 
      translate(key, args: args);

  /// Check if current locale is Arabic
  bool get isArabic => locale.languageCode == 'ar';

  /// Check if current locale is English
  bool get isEnglish => locale.languageCode == 'en';
}

/// App localizations delegate
class _AppLocalizationsDelegate 
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppConstants.supportedLocales
        .map((l) => l.languageCode)
        .contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    AppLocalizations localizations = AppLocalizations(locale);
    await localizations.load();
    return localizations;
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

/// Extension for easier access to translations
extension AppLocalizationsExtension on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
  
  String tr(String key, {Map<String, dynamic>? args}) => 
      AppLocalizations.of(this).translate(key, args: args);
}
