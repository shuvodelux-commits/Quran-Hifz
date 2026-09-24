# Offline Quran Audio Architecture

## Remote-first reciter metadata

The app requests the complete chapter-reciter catalog and the selected
reciter/Surah metadata through the Quran backend. Quran Foundation credentials
remain on the backend and are never shipped in the app.

The existing build-time generator also creates a small verified fallback:

```text
assets/audio/
├── reciters_v1.json
└── chapters_v1/
    ├── {reciterId}-1.json
    ├── {reciterId}-2.json
    └── ... {reciterId}-114.json
```

When the backend is unavailable, the app loads `reciters_v1.json` and the
matching bundled chapter metadata for the fallback reciter. A successful live
catalog is cached locally. For every other reciter, chapter metadata is fetched
only after the user chooses a Surah to stream or download.

Runtime flow:

```text
QuranBackendChapterAudioSource
        │ backend unavailable for bundled reciter
        ▼
BundledChapterAudioSource fallback
        │
        ▼
QuranAudioSyncService
        ├── timing/audio metadata -> UserDatabase
        └── optional download -> FileAudioDownloadRepository -> filesystem
```

Downloaded local files remain preferred by the existing audio resolver, so a
downloaded Surah can replay without network access.

## SQLite

Stores only metadata:

- audio key
- remote URL
- local path
- format
- file size
- download status
- ayah timestamps
- word timestamps
- sync checkpoints

Do not store audio BLOBs in SQLite.

## Filesystem

```text
quran_audio/
├── reciters/
│   └── {reciterId}/
│       ├── 001.mp3
│       ├── 002.mp3
│       └── ...
└── words/
    └── 001/
        └── 001/
            ├── 001.mp3
            ├── 002.mp3
            └── ...
```

## Main recitation

One Surah audio file can provide:

- full Surah playback
- exact ayah playback by seek position
- repeat N times
- automatic next ayah
- word highlighting via segment timestamps

## Word tap audio

Dedicated word files remain separate because tapping one word should start
immediately.

Relative QF word paths such as:

```text
wbw/001_001_001.mp3
```

resolve against:

```text
https://audio.qurancdn.com/
```

## Codec decision

Keep Quran Foundation source MP3 unchanged for now.

Do not transcode or redistribute QF content until applicable permission and
Developer Terms have been confirmed.

If the project later owns or has explicit permission to encode its own source
audio, Opus mono around 24–32 kbps is a good lightweight speech target.
