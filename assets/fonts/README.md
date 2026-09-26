# Quran font assets

## Quran Foundation body fonts

`UthmanicHafs1Ver18.ttf` is the adaptive QPC Hafs / Uthmani Quran body font.
It is bundled from Quran Foundation and registered as `QPC Hafs`.

- Source: https://verses.quran.foundation/fonts/quran/hafs/uthmanic_hafs/UthmanicHafs1Ver18.ttf
- Retrieved: 2026-09-26
- SHA-256:
  `a0636e68e375af9552470d67773936f54d536e6586ce2608311b2fe7f9cbec3a`

`indopak-nastaleeq-waqf-lazim-v4.2.1.ttf` is the adaptive IndoPak Quran
body font. It is bundled from Quran Foundation and registered as
`IndoPak Nastaleeq`.

- Source: https://verses.quran.foundation/fonts/quran/hafs/nastaleeq/indopak/indopak-nastaleeq-waqf-lazim-v4.2.1.ttf
- Retrieved: 2026-09-26
- SHA-256:
  `4c8f002e7538ef6351ac676eb0f2c1708ecd17f6f8a5fc4a19dbc8eaf4dddff5`

## Dedicated Bismillah font

`qpc-v4-tajweed-p1.ttf` is retained for the approved standalone Bismillah
glyph presentation. It is not exposed as a selectable Quran body font.

- SHA-256:
  `c698d2ba6b326a0d4a6b00c40581149127cd357092f2cd34f2d216fb8123462a`

## QUL Surah name font v4

`surah-name-v4.ttf` is QUL resource #457, a ligature-based Surah-name font.
The app renders `surah001` through `surah114` with the Flutter family alias
`SurahNameV4`; accessibility semantics keep the corresponding Arabic Surah
name instead of exposing the ligature key.

- Resource page: https://qul.tarteel.ai/resources/font/457
- Font file: https://static-cdn.tarteel.ai/qul/fonts/surah-names/v4/surah-name-v4.ttf
- SHA-256:
  `026cfe8ac461531a7b1c8e4edd05ce3343f09e9c73447ff14c6bc93f3193d661`

QUL documents using the Surah-name font in applications, including
platform-specific Android/iOS integration. Its resource page does not
currently publish a separate redistribution license text; confirm
redistribution terms before a public store release.

The strict QCF V2 and QCF V4 Tajweed choices use page-specific fonts at
runtime and are therefore not registered here as static Flutter font
families.
