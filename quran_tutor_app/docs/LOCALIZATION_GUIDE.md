# Localization Guide

## Key Naming Convention

All translation keys follow the pattern: `feature.context.message`

### Structure
```
feature    = auth | validation | error | pending | rejected | settings | app
context    = login | signup | theme | language | etc.
message    = The specific message key
```

## Examples

### Auth Feature
```json
"auth": {
  "login": {
    "title": "Sign In",
    "email_label": "Email",
    "submit": "Sign In"
  },
  "signup": {
    "title": "Create Account",
    "password_label": "Password"
  },
  "errors": {
    "invalid_credentials": "Invalid email or password"
  }
}
```

### Validation Feature
```json
"validation": {
  "required": "This field is required",
  "password_min_length": "Password must be at least {min} characters",
  "name_arabic_required": "Name is required",
  "password_mismatch": "Passwords do not match"
}
```

## Usage in Code

### Basic Translation
```dart
// Using the extension
text: context.tr('auth.login.title')

// Or using the localizations directly
final l10n = AppLocalizations.of(context);
text: l10n.t('auth.login.title')
```

### With Parameters
```dart
text: context.tr(
  'validation.password_min_length',
  args: {'min': '8'},
)
```

### Checking Locale
```dart
if (context.locale.languageCode == 'ar') {
  // RTL specific logic
}

// Or using localizations
final l10n = AppLocalizations.of(context);
if (l10n.isArabic) {
  // Arabic specific logic
}
```

## Migration Checklist

When adding a new screen/feature:

1. Add all user-facing strings to both `en.json` and `ar.json`
2. Use the format `feature.context.message`
3. Replace hardcoded strings with `context.tr('key')`
4. Test in both Arabic and English
5. Verify RTL layout works correctly

## Common Patterns

### Form Labels
```dart
Text(context.tr('auth.signup.email_label'))
TextField(
  decoration: InputDecoration(
    hintText: context.tr('auth.signup.email_hint'),
  ),
)
```

### Validation Messages
```dart
// In validators, return the key
static String? validateEmail(String? value) {
  if (value?.isEmpty ?? true) {
    return 'validation.required';  // Return key, not string
  }
  return null;
}

// In UI, localize the key
final error = validator(value);
if (error != null) {
  return Text(context.tr(error));
}
```

### Error Handling
```dart
ErrorScreen(
  failure: failure,
  onRetry: () => refetch(),
)

// ErrorScreen automatically uses:
// - error.title for the title
// - error.go_home for the button
// - error.retry for retry button
```
