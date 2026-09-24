# Android production E2E matrix

Run these gates on a physical Android device after the approved canonical Quran database and package manifest are present under `assets/database/`.

| Flow | Required verification |
| --- | --- |
| Canonical bootstrap | Cold start installs/validates the bundled DB, opens the exact verified path, and never falls back to demo content. |
| Reader | Open Quran, change page, toggle translation, tap an ayah, background the app, lock/unlock the device, and verify playback/MediaSession state remains coherent. |
| Word audio | Tap an uncached word for immediate remote playback, wait for cache completion, disable network, tap the same word, and verify local playback. Confirm `.part` files are never played. |
| Hifz | Start a valid range, verify missing chapter metadata/timing lazily syncs, pause/resume/stop, relaunch, and resume the checkpoint. Invalid Surah/ayah bounds must be rejected before playback. |
| Study/navigation | Reach Quran, Hifz, Revision, Progress, Memorization Test, and Bookmarks from the primary navigation; create a bookmark and confirm it appears in Bookmarks. |
| Tafsir | Install the verified Abu Bakar Zakaria package, open tafsir from an ayah, confirm source attribution, then repeat offline. |

## Commands

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter test integration_test -d <android-device-id>
flutter build apk --debug
flutter build apk --release
```

For release profiling, use a physical device:

```bash
flutter run --profile -d <android-device-id>
```

Capture startup time, reader page-scroll jank, word-tap-to-audio latency for cached and uncached audio, Hifz transition latency, memory after 15 minutes of reader use, and background playback stability for at least 10 minutes with the screen off.
