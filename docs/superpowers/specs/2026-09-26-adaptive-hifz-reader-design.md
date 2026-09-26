# Quran Hifz — Adaptive Mushaf Reader Design

Date: 2026-09-26
Status: Approved design

## Goal

Redesign the Hifz Quran reading experience so it feels like a calm Madani Mushaf while remaining genuinely readable on a phone.

The reader must preserve Quran page identity, Surah transitions, Bismillah, ayah markers, Juz/Hizb context, Hifz selection state, audio repetition, and word/ayah interaction. It must not force all content into a fixed 15-line viewport when the user increases Quran text size.

The visual direction combines:

- a warm, quiet Mushaf-like surface;
- adaptive Quran text that can grow without becoming cramped;
- stable 604-page anchors for Hifz spatial memory;
- minimal app chrome;
- compact Hifz audio controls;
- repetition-first memorization workflow.

The design takes inspiration from physical Madani Mushaf reading and modern Hifz applications such as Sahab Hifz, without copying their branding, artwork, or proprietary ornamental assets.

## Core principle

The page number remains stable; the screen height does not.

A Quran page is a logical Hifz anchor, not a requirement that exactly 15 rendered lines fit inside one phone viewport.

At normal text size, the reading section should visually resemble a Mushaf page. At larger text sizes, the same Quran content is allowed to reflow vertically and the section becomes taller.

The reader must never:

- shrink Quran text merely to preserve 15 rows;
- create horizontal scrolling;
- stretch Arabic words into visibly unnatural spacing;
- clip diacritics;
- split the Quran into disconnected ayah cards;
- lose page, Surah, or Juz/Hizb context when font size changes.

## Rendering strategy

### Primary adaptive font

Adaptive Hifz reading uses a scalable Uthmani/Madani Unicode Quran font compatible with the verified `text_qpc_hafs` Quran Foundation text already used by the project.

The target family is QPC Hafs / Uthmanic Hafs style rather than a page-specific QCF glyph font.

Reason:

- Unicode text can scale continuously.
- It can wrap naturally on narrow screens.
- It does not require switching among 604 page-specific font files.
- It preserves Quran Foundation's verified Quran text model.
- It is better suited to accessibility and Hifz users who prefer larger text.

QCF/QPC page-glyph rendering may remain available as a separate strict Mushaf mode in the future, but it is not the primary renderer for this adaptive Hifz screen.

### Quran text flow

Each logical Quran page renders as one continuous RTL Quran text flow.

Ayah markers remain inline with the Quran text.

Ayahs must not become separate card rows or separate paragraphs unless the source layout explicitly requires a Surah boundary.

Normal text should use balanced line wrapping and natural Arabic spacing. Large-text mode must prioritize readable shaping over strict printed-page line boundaries.

The renderer may use the project's canonical Quran page metadata to determine which ayahs/words belong to each logical page.

### Text sizing

The default Hifz Quran size should be noticeably more readable than a literal 15-line page compressed into a phone viewport.

Initial target ranges:

- default: approximately 30–32 logical px;
- comfortable-large: approximately 34–36 logical px;
- large: approximately 38–40 logical px.

These are design targets, not hard-coded guarantees. Actual rendered size must be tuned against the selected Quran font and real Android text scaling.

Line height should be font-relative and generous enough that stacked Quran diacritics never collide. Initial target is approximately 1.8–2.0 times font size, adjusted after real-device measurement.

The final implementation must use rendered measurements rather than assuming that one numeric size behaves identically across fonts and Android text-scale settings.

## Page structure

The page should read as one coherent Mushaf section.

A typical section contains:

1. optional Quran text continuing from the previous Surah;
2. Surah transition block if a new Surah begins on this page;
3. Bismillah where canonically applicable;
4. continuous Quran text;
5. subtle page metadata footer.

The logical page anchor remains the canonical 1–604 page number even if the rendered section is taller than one screen.

### Page header

The persistent app header is minimal.

Preferred structure:

- centered calligraphic/current Surah name;
- small secondary label such as Surah number or English/Bangla name;
- back/navigation control;
- one compact appearance/action control.

The Quran text must remain the visual focus.

### Surah transition

A new Surah beginning within a page uses a centered divider that feels Quranic but restrained.

Requirements:

- visually distinct from normal Quran text;
- does not dominate the page;
- uses the existing calligraphic Surah-name resource where appropriate;
- keeps enough vertical breathing room before and after;
- remains stable when Quran text size changes.

Avoid copying Sahab's specific ornamentation.

### Bismillah

Bismillah is centered beneath the Surah divider.

Existing canonical rules remain:

- Al-Fatihah must not receive a duplicate standalone Bismillah;
- At-Tawbah must not receive a standalone Bismillah;
- other applicable Surahs receive it once.

The existing QPC V4 Bismillah glyph asset may be used if it visually matches the adaptive page. It must remain centered and must not cause surrounding Quran text to reflow incorrectly.

## Page metadata

Each logical page should retain compact Hifz anchors such as:

- Juz number;
- Hizb / quarter-Hizb where available;
- page number.

Example:

`Juz 22 · ¾ Hizb 44                         Page 440`

The metadata footer is deliberately subtle. It is a memory anchor, not a toolbar.

When the next logical page begins, a small divider/page marker may appear so a large-text user can still tell that Page 440 ended and Page 441 began.

## Scroll behavior

The adaptive reader is vertically scrollable.

Scrolling should feel like moving through a continuous Mushaf, not through independent cards.

When the user changes font size:

- preserve the current ayah/word anchor whenever possible;
- do not jump to the top of the Surah;
- recalculate layout around the same logical content position.

Page boundaries stay deterministic even though physical screen positions change.

## Hifz interaction

### Word and ayah interaction

Existing word tap, long-press, ayah tap, audio-follow, and memorization selection behavior should be preserved.

Interactive regions must not require visible borders or buttons around every word.

### Active audio state

During playback:

- current ayah receives a soft warm highlight;
- current word may receive a slightly stronger highlight;
- highlight must not change line metrics;
- avoid solid high-saturation boxes around Quran text.

### Hifz range

Selected Hifz range should use a subtle treatment, such as a soft underline or low-opacity background.

Selection styling must not make the Quran resemble an editor.

### Hide/reveal

Hide/reveal remains a Hifz practice feature.

The control belongs in the compact Hifz control layer, not permanently inside the Quran text.

The hidden state must retain enough stable markers that the learner does not lose page/ayah context.

## Hifz repetition model

The compact selector labels are:

- `1×`
- `2×`
- `3×`
- `5×`

These values mean **repetition count**, not audio playback speed.

Hifz audio playback itself remains at normal 1.0× speed in this flow.

### Progressive build sequence

For a selected range, the memorization sequence grows cumulatively.

Example for ayahs 1–3 with repetition count `3×`:

1. Ayah 1 × 3
2. Ayah 2 × 3
3. Ayahs 1–2 together × 3
4. Ayah 3 × 3
5. Ayahs 1–3 together × 3
6. final full selected range 1–3 × 1

The final full-range pass is always once unless a future explicitly configured preset says otherwise.

For a longer selected range, the same pattern continues:

- new ayah repeated individually;
- accumulated range from selection start through that ayah repeated;
- continue until selection end;
- one final full-range pass.

For a one-ayah selection, avoid redundant duplicate phases: repeat the single ayah according to the selected count, then end cleanly rather than replaying an identical “full range” unless the current preset model explicitly requires that behavior.

### Existing sequence compatibility

The project already contains a Hifz sequence builder, repeat counters, and session progression.

Implementation should adapt that existing domain logic rather than create a second independent audio-loop engine.

The new repeat selector should map cleanly to the existing preset/session model.

## Compact Hifz player

The player remains visually compact so it does not obscure Quran text.

Collapsed state should show:

- play/pause;
- current ayah or current cumulative range;
- repeat progress such as `Repeat 2/3`;
- repetition selector `1× 2× 3× 5×`;
- small progress indicator for the current Hifz sequence.

The selector must clearly communicate repetition, for example through contextual labeling or tooltip/accessibility text such as “Repeat count: 3”.

It must never be labeled or announced as playback speed.

### Expanded controls

A compact expandable sheet may expose:

- selected range;
- reciter;
- pause-between-repeats;
- hide/reveal mode;
- repeat count;
- restart current Hifz sequence;
- stop Hifz session.

Do not place all of these controls permanently over the Quran.

## Audio behavior

Audio continues to use the existing Quran audio/Hifz session engine.

Requirements:

- normal 1.0× playback speed;
- repeat counts 1/2/3/5;
- current repeat index visible;
- current sequence step visible;
- pause/resume preserves the current repeat and step;
- stopping clears the active Hifz playback state cleanly;
- changing repeat count applies predictably to the active/new sequence, with behavior covered by tests.

If the current engine cannot safely mutate repeat count mid-step, the UI should apply the new count beginning with the next sequence start rather than corrupt current progression.

## Offline behavior

The adaptive reader must use bundled Quran text/page metadata already available locally.

Basic Hifz reading, font rendering, page anchors, Surah boundaries, Bismillah, and repetition sequencing must not require a network request.

Audio availability continues to follow the project's existing recitation/audio caching behavior.

## Accessibility

- Quran text respects the app's Hifz font-size setting.
- App chrome should not scale so aggressively that it crowds out Quran text.
- All player controls need semantic labels.
- Repeat buttons must announce “repeat one/two/three/five times,” not ambiguous `1×` alone.
- Current ayah highlighting cannot be the only indication of playback state.
- Contrast must remain sufficient in light/sepia/dark themes if those themes are retained.

## Visual direction

Primary visual tone:

- warm ivory outer background;
- near-white Quran surface;
- black/dark Quran text;
- muted gold/stone ayah and metadata accents;
- restrained green/teal interaction accent consistent with the app;
- rounded page surface;
- minimal ornamentation;
- no heavy cards between ayahs.

The screen should feel closer to a premium physical Mushaf than a dashboard.

### UI typography

The Hifz screen uses separate font families by content type:

- Quran Arabic: QPC Hafs / Uthmanic Hafs-compatible font with verified `text_qpc_hafs`.
- Bangla UI: **SolaimanLipi**.
- English UI: Inter.
- Surah calligraphy: existing SurahNameV4 asset.
- Bismillah: existing QPC V4 Bismillah glyph/font.

SolaimanLipi applies to Bangla headings, labels, helper text, pattern descriptions, Hifz progress text, dialogs, sheets, and Bangla metadata. It must not be used for Quran Arabic.

Initial Bangla UI sizing targets:

- sheet/page heading: 22–24 logical px;
- section heading: 17–18 logical px;
- primary label/body: 15–16 logical px;
- helper/secondary text: 13–14 logical px;
- compact metadata: 11–12 logical px.

These values are starting targets and must be checked on the real Android device because SolaimanLipi has different visual density and vertical metrics from Inter.

## Current architecture to preserve

The current project already provides useful pieces that should be reused where possible:

- canonical 604-page metadata;
- Hifz page/session state;
- Hifz sequence builder;
- Quran audio controller with repeat progress;
- word and ayah interaction;
- Surah-name font;
- Bismillah font/glyph;
- existing Hifz settings;
- WebView/Flutter Mushaf rendering experiments.

The redesign should replace the strict fixed-height/15-row presentation constraint, not discard the underlying Hifz domain model.

## Recommended implementation boundary

Introduce an adaptive Hifz Quran surface separate from the strict fixed-page renderer.

The adaptive surface owns:

- logical page grouping;
- Quran text flow;
- page/surah/Bismillah anchors;
- font size and line-height adaptation;
- active/selected Quran text styling.

The Hifz session/audio layer owns:

- sequence generation;
- repeat count;
- current step/repeat;
- play/pause/stop;
- current ayah/range state.

The compact player only renders state and sends user intents.

This separation prevents typography/layout changes from affecting Hifz sequence correctness.

## Testing requirements

### Sequence tests

For each repeat option `1×`, `2×`, `3×`, `5×`:

- verify individual-ayah repeat counts;
- verify cumulative range repeat counts;
- verify final full-range pass occurs once;
- verify one-ayah selection does not create accidental duplicate phases;
- verify pause/resume preserves repeat position;
- verify stop resets active Hifz playback cleanly.

### Layout tests

Verify:

- canonical page identity remains stable at multiple font sizes;
- Surah transition stays between the correct Quran words/ayahs;
- Bismillah rules remain correct;
- no horizontal overflow at supported phone widths;
- large text causes vertical growth/reflow instead of text shrinking;
- active-word/ayah styling does not alter measured line height;
- page footer belongs to the correct logical page.

### Real-device checks

On the connected Android device verify at minimum:

- small/default/large Hifz font sizes;
- Surah transition page such as page 440;
- long ayahs;
- page-to-page scrolling;
- repeat counts 1/2/3/5;
- active audio highlighting;
- hide/reveal;
- orientation/font-scale behavior if supported.

## Acceptance criteria

The redesign is complete when:

1. The Hifz reader visually feels like a coherent Mushaf rather than a list of ayah cards.
2. Default Quran text is comfortably readable on a phone.
3. Increasing text size never forces ugly compression or horizontal scrolling.
4. Logical 604-page anchors remain visible and correct.
5. Surah and Bismillah transitions remain canonical.
6. The compact Hifz player exposes repeat counts `1× 2× 3× 5×`.
7. Those values control repetition count, not playback speed.
8. Progressive cumulative repetition follows the approved sequence model.
9. Existing Hifz word/ayah/audio/session functionality is preserved.
10. Core reading and repetition behavior work offline except where audio itself requires uncached remote media.

## Visual prototype reference

Magic Patterns inspiration canvas:

`https://www.magicpatterns.com/inspiration/236bad9a-5a0c-4b37-8866-0c05bcb2d200`

The preferred direction is a combination of:

- Adaptive Mushaf
- Hifz Focus + Audio

The automatic Magic Patterns AI generator was unavailable because the connected account had insufficient generation credits, so the research comparison was represented through a manually authored Magic Patterns inspiration canvas instead.
