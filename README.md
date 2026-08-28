# BIM (Business in Map) — Flutter app

Frontend for the BIM backend at `C:\xampp\htdocs\testing` (Laravel v2 API).
The API contract lives there — never guess a request/response shape:

- `docs/api/openapi-v2.yaml` — the spec.
- `docs/api/BIM-v2.postman_collection.json` — 412 ready-made requests, one
  per route, regenerate with `php docs/api/generate-postman.php`.

See `..\..\..\Users\moham\OneDrive\Desktop\هام للتطبيق الجديد\business-in-map-roadmap.md`
for the product roadmap. Two corrections against that document, confirmed
with the backend's actual design — read before building payment or account
screens:

1. **The wallet never pays for a menu order / booking / retail item /
   prescription.** Those are cash outside the app, always. The wallet (and
   the Paymob top-up gateway) only moves platform fees, deposits, and
   guarantees. Don't wire a "pay with wallet" button into any checkout flow.
2. **Accounts aren't just customer/business.** Arbitrator, delivery driver,
   pharmacy, doctor, clinic, etc. all exist as roles on the same login —
   `AuthUser.type`/`isBusiness` today is the minimal cut; extend it rather
   than assuming a strict binary.

## Run it

```bash
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2/testing/public/api/v2
```

`API_BASE_URL` defaults to the Android-emulator alias for the XAMPP host
(`10.0.2.2`). A physical device, desktop, or web build needs the machine's
LAN IP instead — Chrome/Windows builds can also hit `localhost` directly:

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost/testing/public/api/v2
```

## Structure

```
lib/
  main.dart              # entry point, wraps app in ProviderScope
  app/
    app.dart             # MaterialApp.router + theme + localization wiring
    router.dart           # go_router routes + auth-aware redirects
    theme/                # design tokens (app_colors.dart) + ThemeData (app_theme.dart)
  core/
    env/                  # build-time config (--dart-define)
    network/              # Dio wrapper (ApiClient) + ApiException
    storage/              # TokenStorage (flutter_secure_storage)
    providers/             # riverpod providers for the above
  features/
    auth/                 # login/register/account-type screens + AuthController
    home/                 # placeholder landing screens (customer/business)
    splash/               # shown while the stored session is checked
  l10n/
    arb/                  # app_ar.arb (template) + app_en.arb — edit these,
                           # never the generated app_localizations*.dart
```

## Conventions

- **State**: Riverpod. One `Provider`/`StateNotifierProvider` per concern in
  `core/providers` or a feature's `application/` folder — no global mutable
  singletons.
- **Networking**: always through `ApiClient` (never a bare `Dio` instance),
  so every screen gets the same auth header, envelope unwrap, and
  `ApiException` error shape for free.
- **i18n**: Arabic (`app_ar.arb`) is the template locale, not a translation
  of English — mirrors the backend's own `resources/lang/ar.json` convention.
  Run `flutter gen-l10n` after editing an `.arb` file (or just `flutter run`,
  which regenerates automatically).
- **New feature module**: copy the `auth/` folder's shape —
  `data/` (API + models) → `application/` (controller/state) →
  `presentation/` (screens/widgets). Check the OpenAPI spec or Postman
  collection for the exact request/response shape before writing the
  `data/` layer.

## Not wired in yet (by design, not oversight)

- `google_maps_flutter` / `geolocator` / `geocoding` — needs a Google Maps
  API key per platform; add when the Discovery/Location module starts.
- `firebase_messaging` — needs a Firebase project + `google-services.json`;
  add when push notifications are wired.
- Payment gateway SDK — top-up only (see wallet note above); add when the
  Wallet module starts.
