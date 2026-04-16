# Repository Guidelines

## Project Overview

Steel Buddy is a Flutter B2B steel marketplace app connecting manufacturers, distributors, dealers, and end users. The backend is a REST API at `https://api.steelbuddy.in/api`, with Firebase for authentication and push notifications.

## Project Structure & Module Organization

```
lib/
  main.dart             # App entry, Firebase init, ProviderScope, named routing
  splash_screen.dart
  core/theme/           # AppTheme
  models/               # Plain Dart data models (no business logic)
  services/             # api_service.dart (40+ REST methods), authentication.dart, fcm_service.dart
  providers/            # Riverpod state: auth_provider, role_provider, login_provider, dashboard_providers
  features/
    authentication/     # Login + OTP screens
    onboarding/         # GetStartedScreen 1-3
    dashboard/          # Widgets: appbar, bottombar, search filters
    layout/             # Shell layout
    screens/            # All other screens (enquiry, quotation, profile, notifications, etc.)
```

All state is managed via `flutter_riverpod`. Providers in `lib/providers/` own state; screens consume via `ConsumerWidget`/`ConsumerStatefulWidget`. `api_service.dart` is the single HTTP client — add new endpoints there, not in screens.

## Build, Test, and Development Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run on connected device/emulator
flutter run --release    # Release mode
flutter build apk        # Android APK
flutter build ios        # iOS
flutter test             # Run all tests
flutter test test/widget_test.dart  # Run single test file
flutter analyze          # Static analysis
```

## Coding Style & Naming Conventions

Linter: `flutter_lints` via `analysis_options.yaml`. Many rules are suppressed (`avoid_print`, `unused_local_variable`, `use_build_context_synchronously`, etc.) — do not re-enable unless intentional.

- Files: mostly `snake_case.dart`; a few existing files use kebab-case (e.g., `delivery-terms.dart`) or PascalCase (e.g., `GetStartedScreen1.dart`) — follow `snake_case` for new files
- Classes: `PascalCase`; providers: `camelCase` with `Provider` suffix (e.g., `authProvider`)
- Models live in `lib/models/`; each model is a single file with `fromJson`/`toJson`

## Testing Guidelines

Framework: `flutter_test`. Currently only `test/widget_test.dart` exists. Run tests with `flutter test`.

## Commit & Pull Request Guidelines

Commits follow short, lowercase descriptive phrases (no conventional-commits prefix):
- `enquiry and quotation changes`
- `category filter for products updated`
- `android app gradle corrections`

PRs are merged from feature branches (pattern: contributor forks → PR into `master`).
