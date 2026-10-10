# Bahasha Mobile

Flutter client for approved congregation members using the Bahasha Django Ninja
API.

## Local Development

Start the Django project first from the sibling `bahasha-system` directory:

```sh
docker compose up -d
```

Install Flutter dependencies and run the app:

```sh
flutter pub get
flutter run
```

The default API addresses are:

- Android emulator: `http://10.0.2.2:8000/api/v1`
- iOS simulator, desktop, and web: `http://127.0.0.1:8000/api/v1`

Override the endpoint for a physical phone or another environment:

```sh
flutter run --dart-define=API_BASE_URL=http://192.168.0.32:8000/api/v1
```

Production builds must use an HTTPS endpoint:

```sh
flutter build apk --dart-define=API_BASE_URL=https://example.org/api/v1
```

Android release signing reads `android/key.properties`. Keep that file and the
keystore outside Git. A minimal file contains:

```properties
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=/absolute/path/to/upload-keystore.jks
```

## Verification

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Authentication tokens are stored with `flutter_secure_storage`. Access tokens are
short-lived, refresh tokens rotate through the backend, and logout clears local
credentials even when the API cannot be reached.
