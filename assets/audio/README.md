# Generated reciter audio metadata

`reciters_v1.json` and `chapters_v1/<reciterId>-<surah>.json` are generated
from verified Quran Foundation Content API data by
`tool/quran_audio/fetch_verified_reciter_audio.dart`.

Do not hand-author or fabricate production Quran audio metadata. The generated
files are intentionally absent from this source handoff until the credentialed
production generator is run and validated.

The generator stages and validates the complete catalog before replacing only
these two generated targets. Hand-maintained files under `assets/audio/` are
preserved. Quran Foundation client secrets/access tokens must remain in the
developer/build environment and must never be copied into this directory.
