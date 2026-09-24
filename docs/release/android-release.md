# Android release build

The release build must never use Flutter's debug signing key.

## 1. Materialize the Gradle wrapper

If the wrapper JAR/scripts are absent, run this once on the pinned Flutter workstation:

```bash
flutter create --platforms=android .
```

Review the generated Android diff before keeping it. Preserve the existing package id, MediaSession manifest wiring, and release-signing configuration.

## 2. Create a private upload keystore

Example:

```bash
keytool -genkeypair -v \
  -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 4096 -validity 10000 \
  -alias upload
```

Do not commit the keystore or passwords.

## 3. Configure signing

```bash
cp android/key.properties.example android/key.properties
```

Edit `android/key.properties` locally with the real passwords and alias.

## 4. Run the release preflight

```bash
python3 tool/release/check_release_ready.py
```

The checker refuses release readiness when the canonical Quran DB/manifest/report, dedicated upload signing, Gradle wrapper, or background-audio Android wiring is missing.

## 5. Flutter quality gates and release build

```bash
flutter analyze
flutter test --concurrency=1 --reporter expanded
flutter test integration_test -d <ANDROID_DEVICE_ID> --reporter expanded
flutter build appbundle --release
```

Upload the generated AAB only after physical-device Quran, word-audio, ayah-repeat, Hifz persistence, Tafsir, and background-playback checks pass.
