[Reading 455 lines from start (total: 455 lines, 0 remaining)]

# First-Install Onboarding, Visual System, and Quran Reader Redesign

Date: 2026-09-25  
Status: Approved design; implementation not started

## Intent

Quran Hifz is still in active development and the public app name is not final. This change introduces a polished first-install experience and refreshes the default app visual language without changing Quran data, reader logic, audio behavior, Hifz behavior, or user-configurable Quran appearance settings.

The approved direction is Islamic, clean, restrained, and modern: cool blue as the primary brand color, white/off-white surfaces, subtle gold accents, minimal Islamic geometry, and clean outline navigation icons.

## Scope

This change includes four connected areas:

1. First-install onboarding:
   - Language
   - Location
   - Developer message / dedication
   - Enter app
2. Default light-theme visual refresh:
   - new blue primary color system
   - cleaner outlined bottom-navigation icons
   - consistent primary/tint/pressed states
3. Quran Surah reader presentation refresh:
   - compact reference-style top app bar
   - blue Surah information card
   - decorative Arabic Surah name
   - redesigned standalone Bismillah card
4. Development-phase onboarding persistence:
   - onboarding appears whenever completion is not stored
   - partial progress resumes after app restart
   - final completion is stored only after the last page

## Non-goals

This change must not:

- alter bundled Quran text or translation data
- modify Quran authenticity/source rules
- replace the user's selected Quran ayah font
- change font-size, line-height, Tajweed, translation, bookmark, audio, reciter, download, or reading-position behavior
- change Hifz logic
- delete existing user data
- add analytics, ads, telemetry, or tracking
- finalize the app's public product name

## Reference Lock

Live Refero research was unavailable because the connected Refero account has no active subscription. The design is therefore locked to:

1. the user's supplied blue/white Quran UI reference screenshots
2. the user-approved Superpowers visual companion mockup
3. the existing app's Material 3 component system
4. bundled design craft guidance for restrained product color and consistent outline iconography

### Preserve

- Main app/header blue sampled from the supplied reference: #27687E
- Deeper blue sampled from the supplied reference: #205766
- Quran Surah information-card blue sampled from the supplied close-up: #275F70
- Gold accent sampled/normalized from the supplied reference: approximately #D5A44B
- Warm off-white canvas: approximately #F7F6F1
- Cards: white
- Light primary tint: a low-saturation tint derived from #27687E
- Clean outline icon language throughout bottom navigation
- Minimal, non-illustrative Islamic geometry in onboarding
- Generous whitespace and compact card radii
- Quran Surah header using blue card + calligraphic Arabic name
- Standalone Bismillah inside a simple white/off-white rounded card

### Reject

- bright teal as the dominant default color
- filled/heavy mixed navigation icon styles
- busy mosque illustrations
- ornamental visual clutter
- gradients or glow effects across ordinary product UI
- forcing one decorative font onto Quran ayah text
- hardcoding the temporary app name throughout onboarding

## 1. First-Install Onboarding

### Entry rule

The app checks a local onboarding completion state before showing the normal shell.

- If onboarding is complete: open the app normally.
- If onboarding is incomplete: show onboarding.
- Because the app is still in development, no legacy-user bypass is required.

### Progress state

Persist both:

- current onboarding step
- completion flag

Expected values:

- language
- location
- developerMessage
- completed

If the app closes during onboarding, reopening returns to the unfinished step.

The completion flag is written only after the final primary action.

### Step 1 — Language

Heading:
- Bangla: "আপনার ভাষা নির্বাচন করুন"
- English: "Choose your language"

Options:
- বাংলা
- English

Behavior:
- selection immediately updates onboarding UI language
- save into the existing app preferences repository
- language remains editable later in Settings

Visual treatment:
- subtle Islamic hero/header block
- small crescent/star detail
- restrained Bismillah line
- no logo/product-name dependency

### Step 2 — Set Location

Heading:
- Bangla: "লোকেশন সেট করুন"
- English: "Set location"

Order of actions:
1. Use current location
2. Choose manually
3. Set up later

The heading and location controls remain at the top of the location step.

#### Current location

Reuse the existing prayer-location repository/configuration flow.

Permission and GPS behavior should use the existing geolocator path.

Do not claim that no network is ever used. Privacy copy may state that the developer does not collect or sell personal information; setup may still require internet for supported features.

#### Manual location

Reuse the existing Bangladesh location list and prayer setup logic.

#### Set up later

Location is optional during onboarding.

If skipped:
- continue to the developer message
- do not fabricate or guess a prayer location
- the Home prayer area should show a compact "Set location / লোকেশন সেট করুন" prompt instead of pretending prayer times are configured
- tapping that prompt opens the existing location selection flow

### Step 3 — Developer Message

Heading:
- Bangla: "ডেভেলপারের পক্ষ থেকে"
- English equivalent

The page should present a calm Islamic dedication card, not a legal-looking dialog.

Approved Bangla content direction:

"এই কুরআন অ্যাপটি সম্পূর্ণ বিজ্ঞাপনমুক্ত। ডেভেলপার এই অ্যাপের মাধ্যমে ব্যবহারকারীর ব্যক্তিগত তথ্য সংগ্রহ বা বিক্রি করেন না। অ্যাপের প্রয়োজনীয় তথ্য আপনার ডিভাইসেই সংরক্ষিত থাকে; কিছু ফিচার, যেমন লোকেশন সেটআপ ও অনলাইন অডিও/কনটেন্ট ব্যবহারের সময় ইন্টারনেট প্রয়োজন হতে পারে।

এই অ্যাপটি ডেভেলপার তাঁর বাবা মরহুম জারজিস হোসেন প্রামাণিক-এর জন্য উৎসর্গ করেছেন।

সকলের কাছে বিনীত অনুরোধ—আমার বাবার মাগফিরাতের জন্য দোয়া করবেন। সম্ভব হলে আপনাদের সালাতে অন্তত একবার তাঁর জন্য দোয়া করবেন—এই আশা রাখছি।

অ্যাপ ব্যবহারে কোনো সমস্যা, ভুল বা পরামর্শ থাকলে নিচের ইমেইলে জানাতে পারেন। ইনশাআল্লাহ, যথাসম্ভব দ্রুত সমাধানের চেষ্টা করব।"

Support email:
- the final address is not yet supplied
- do not show a fake or placeholder email address in the shipped UI
- keep the support-email value centralized and render the email row only when a real address is configured

Primary action:
- Bangla: "আল কুরআন শুরু করুন"
- English: "Start Al Quran"

Do not hardcode "Quran Hifz" into new onboarding pages because the final app name is not decided.

### Islamic onboarding styling

Use:
- subtle mihrab/arch geometry
- small crescent/star accents
- restrained gold accent
- white/off-white canvas
- reference main blue #27687E for buttons and key emphasis
- compact Bismillah / short Arabic line in the hero area
- no large decorative mosque illustration
- no animated ornamental clutter

Touch targets remain at least 44 logical pixels.

## 2. Default App Color System

Update the default light theme from the current bright teal family to the approved blue family.

Reference-sampled direction:
- app primary/header: #27687E
- pressed/deeper state: #205766
- Quran Surah information card: #275F70
- gold accent: approximately #D5A44B
- warm canvas: approximately #F7F6F1
- card surface: #FFFFFF
- primary tint: a low-saturation cool tint derived from #27687E
- on-primary: white

Color-role rule:
- use #27687E for app-level primary controls, selected navigation, and major blue header/hero surfaces
- use #205766 only for darker/pressed/depth states
- use #275F70 specifically for the Quran Surah information card and closely related Quran header treatment
- use gold only for small metadata/accent details; never as the dominant action color
- preserve white/off-white surfaces rather than flooding ordinary cards with blue

Apply the primary family consistently to:
- primary buttons
- selected navigation
- active links/actions
- selected chips
- key interactive accents
- Quran Surah header

Do not indiscriminately paint all cards blue.

Existing alternate themes (dark, green, women) should keep their distinct behavior unless a token relationship requires a small compatibility adjustment.

## 3. Bottom Navigation

Use one consistent clean outline icon language.

Destinations:
- Home: outlined home
- Dua: clean outlined prayer/dua symbol
- Quran: outlined open book
- Calendar: outlined calendar
- More: outlined grid/menu

Rules:
- unselected: muted neutral
- selected: approved blue
- selected state may use a subtle blue tint indicator/background
- avoid mixing filled and outline icon styles
- preserve existing labels, localization, order, tap behavior, and navigation state
- maintain 44+ logical-pixel tap targets

## 4. Quran Surah List

Preserve:
- Surah/Juz/Bookmarks tabs
- search
- Hifz and Tafsir actions
- last-read behavior
- quick-scroll rail
- localization
- all current navigation

Refresh Surah rows so the Arabic Surah name uses a decorative Quranic face consistent with the approved reference.

The decorative Surah-name font is presentation-only and must not override Quran ayah font settings.

Preferred existing candidates:
- KFGQPC Hafs Uthmanic
- AlQalamQuranMajeed

Choose the one that visually matches the approved mockup best during device QA.

## 5. Quran Reader Header

Preserve all current reader capabilities.

### App bar

Reference direction:
- back arrow
- centered Surah number + localized name
- compact chevron for Surah navigation
- clean outline actions
- keep translation, bookmarks, reciter/audio, and appearance/settings accessible

Controls may be regrouped for clarity, but none may silently disappear.

### Surah information card

Use:
- Quran-card blue #275F70 sampled from the supplied close-up
- approximately 10–12 logical-pixel radius
- white primary text
- restrained gold text only for narrow metadata emphasis
- left side: localized Surah name/meaning, verse count, revelation place
- right side: large decorative Arabic Surah name

Arabic Surah name:
- fixed decorative presentation font
- independent of user ayah font preference
- RTL-aware
- scaled responsively to avoid clipping

## 6. Bismillah

Keep all existing canonical content and display rules.

Do not modify:
- BismillahText
- Tajweed data source
- shouldShowStandaloneBismillah policy
- Al-Fatihah behavior
- At-Tawbah exception

Presentation:
- separate white/off-white rounded card
- centered Arabic text
- simple, uncluttered surface
- adequate horizontal and vertical breathing room
- Quran-script/font behavior remains compatible with existing user settings unless the standalone header requires a dedicated safe presentation style
- Tajweed behavior remains intact where currently supported

The new design must not introduce a hardcoded non-canonical Bismillah string into product code.

## 7. Privacy Copy Accuracy

The app currently contains no Firebase Analytics, Sentry, Crashlytics, advertising SDK, or telemetry SDK.

The app does use network-capable features such as:
- prayer-location configuration
- online/downloadable Quran audio or related content

Therefore onboarding language must avoid an absolute claim that no data ever leaves the device.

Approved privacy meaning:
- developer does not collect or sell users' personal information through the app
- local app state remains stored locally unless a feature inherently contacts an external service
- some features require internet

## 8. Architecture

Introduce an onboarding feature boundary rather than embedding first-run logic directly into the shell.

Suggested structure:

- lib/features/onboarding/domain/onboarding_state.dart
- lib/features/onboarding/domain/onboarding_repository.dart
- lib/features/onboarding/data/user_database_onboarding_repository.dart
- lib/features/onboarding/application/onboarding_controller.dart
- lib/features/onboarding/presentation/onboarding_flow.dart
- lib/features/onboarding/presentation/language_onboarding_page.dart
- lib/features/onboarding/presentation/location_onboarding_page.dart
- lib/features/onboarding/presentation/developer_message_page.dart

App root:
- opening splash remains
- Quran content bootstrap remains
- add an onboarding gate before normal QuranHifzShell entry

Persistence should use the existing local UserDatabase/AppSettings mechanism unless implementation discovery identifies a clearly safer existing pattern.

Do not add a new dependency solely for onboarding persistence.

## 9. Error Handling

Language save failure:
- remain on the language step
- show a concise localized error
- do not advance until the preference is persisted

GPS/location failure:
- show existing/reused failure messaging
- allow retry
- allow manual selection
- allow "Set up later"

Manual location configuration failure:
- remain on the location step
- show retry feedback
- preserve selected language

Final completion save failure:
- do not enter the app as completed
- show retry feedback
- preserve developer page state

## 10. Accessibility and Responsiveness

- all important action targets >= 44 logical pixels
- visible semantics/tooltips for icon-only controls
- maintain sufficient contrast for blue/white and secondary text
- support normal Android text scaling without clipping
- avoid decorative Arabic/Islamic motifs interfering with screen-reader order
- make decorative geometry non-semantic
- maintain RTL rendering for Arabic
- test common phone widths including the current OPPO device

## 11. Testing

Use TDD for implementation.

Required focused tests:

### Onboarding
- incomplete state opens onboarding
- completed state opens normal shell
- selected language persists and immediately changes onboarding labels
- progress persists between steps
- restart resumes unfinished step
- GPS path can continue after success
- manual location uses existing configuration flow
- location can be skipped
- skipped location produces "Set location" Home prompt
- final completion is saved only from final CTA
- final CTA text is "Start Al Quran" / "আল কুরআন শুরু করুন"

### Theme/navigation
- default light theme primary token reflects approved blue
- bottom navigation preserves five destinations/order
- selected/unselected icon state remains accessible and consistent

### Quran reader
- existing settings remain wired
- decorative Surah name does not change ayah font preference
- Bismillah visibility policy remains unchanged
- Bismillah widget still uses canonical text and Tajweed rules
- all current reader actions remain available
- Surah list search/tabs/last-read behavior remains unchanged

### Regression
- flutter analyze
- full flutter test
- release/debug build as appropriate
- actual Android installation
- visual QA against the approved reference screenshots and Superpowers mockup

## 12. Device Verification

On the OPPO test device:

1. clear only the app's onboarding state or use a clean install
2. verify Language screen
3. switch language and confirm live UI update
4. verify Set Location page order
5. test "Set up later"
6. confirm Developer Message page
7. confirm "Start Al Quran"
8. relaunch and verify onboarding does not repeat after completion
9. verify Home location prompt when skipped
10. configure location later and verify prayer content updates
11. open Quran Surah list
12. verify new Arabic Surah-name presentation
13. open a Surah
14. verify new blue Surah card and Bismillah card
15. verify translation, bookmark, reciter/audio, Tajweed, font, font size, line height, and reading-position behavior still work
16. compare rendered UI to the approved screenshots/mockup

## 13. Support Email Configuration

The support email is intentionally unresolved. The app must not display a fake address or "[Support email]" placeholder. Keep the value centralized and hide the email row while no real address is configured. When the user supplies the final address later, it can be inserted without redesigning the onboarding flow.

[executed on device: cachyos-admi (1ed7c5e3-cab3-48bb-83af-abfddc350c1a)]