# Quran IndoPak font

`DigitalKhattIndoPak.otf` is the DigitalKhatt IndoPak Unicode Quran font.
It is used only for IndoPak Quran text in Quran reading surfaces,
Bismillah, and the Quran font preview.

- Font download: https://fonts.quran.ws/fonts/indopak/
- Font file: https://fonts.quran.ws/assets/fonts/digital-khatt-indopak.otf
- Original font project and license: https://github.com/DigitalKhatt/indopakfont
- License: SIL Open Font License 1.1; copyright © 2024–2025 Amine Anane
  and © 2024–2025 Tarteel Inc. The required notice and terms are in `OFL.txt`.
- SHA-256 of the bundled, unmodified OTF:
  `59a5e78c530de236a365354d558b37706f37d782f7ee95c3c9b7fe9e0fad042a`

The font site labels this face “DigitalKhatt IndoPak,” matching the embedded
family name reported by `fc-scan`. It is distinct from Quran Foundation's
QuranWBW IndoPak font. Bundling this OFL face avoids redistributing the
QuranWBW font without a separate grant.

`NotoNaskhArabic.ttf` is the Noto Naskh Arabic variable font used for the
Uthmani Quran style. It is distributed under the Apache License 2.0; the
license text is in `LICENSE-NotoNaskhArabic.txt`.

## QUL Surah name font v4

`surah-name-v4.ttf` is QUL resource #457, a ligature-based Surah-name font.
The app renders `surah001` through `surah114` with the Flutter family alias
`SurahNameV4`; accessibility semantics keep the corresponding Arabic Surah
name instead of exposing the ligature key.

- Resource page: https://qul.tarteel.ai/resources/font/457
- Font file: https://static-cdn.tarteel.ai/qul/fonts/surah-names/v4/surah-name-v4.ttf
- SHA-256 of the bundled TTF:
  `026cfe8ac461531a7b1c8e4edd05ce3343f09e9c73447ff14c6bc93f3193d661`
- QUL documents using this font in applications, including platform-specific
  integration for Android/iOS. The resource page does not currently publish a
  separate redistribution license text; confirm redistribution terms before a
  public store release.
