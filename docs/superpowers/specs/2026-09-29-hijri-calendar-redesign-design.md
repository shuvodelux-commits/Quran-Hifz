# Hijri-first Calendar Redesign Design

**Date:** 2026-09-29  
**Status:** Approved design, pending written-spec review  
**Repository:** `shuvodelux-commits/Quran-Hifz`

## 1. Goal

Replace the current Gregorian-month list of prayer cards with the approved compact **Hijri-first দিনপঞ্জিকা / Calendar** experience while preserving the app's existing prayer-time, location, Asr-school, Bangla-calendar, localization, theme, and sharing behavior.

The redesigned Calendar must:

1. show one true Hijri month at a time, even when that month spans two Gregorian months;
2. show Hijri day as the primary grid number and Gregorian day as the secondary number;
3. show the Hijri month/year plus Gregorian and Bangladesh Bangla-calendar date ranges;
4. let the user select any date in the month;
5. update the selected-date section with that day's Hijri, Gregorian, and Bangla dates;
6. show that date's Suhur end, Iftar, five salat times, and existing prohibited-prayer windows;
7. show verified Islamic fasting/reminder events from local rule data;
8. use the existing app typography, spacing, accent-color system, and Graphite Dark mode;
9. keep the layout compact and information-first, without heavy stacks of cards.

## 2. Existing System and Non-regression Boundary

The current Calendar is implemented in:

- `lib/features/home/presentation/prayer_calendar_page.dart`;
- `lib/features/home/data/prayer_schedule.dart`;
- `lib/features/home/data/bangla_calendar.dart`;
- shared localization/theme providers.

The existing `PrayerScheduleRepository` remains the authority for:

- selected location;
- latitude/longitude;
- UTC offset;
- Hanafi/standard Asr selection;
- Fajr, Dhuhr, Asr, Maghrib, and Isha;
- sunrise and sunset;
- daily Hijri date returned by the current prayer data path;
- offline monthly calculations and the existing online calendar path.

Do not create a second prayer calculator or a second location model.

The existing Bangladesh Bangla calendar helper remains the authority for Bangla dates.

The redesign must not alter Home prayer cards, normal prayer calculations, location setup, Asr-school settings, or global theme behavior.
## 3. Why the Calendar Must Become Hijri-first

A Gregorian month and a Hijri month do not share boundaries. A Hijri month such as Rabi al-Thani may begin in September and end in October.

Therefore the current model—requesting one Gregorian month and rendering every Gregorian day—cannot simply be restyled into the approved UI.

The Calendar needs a small month-composition layer that uses existing Gregorian prayer-month data to construct one canonical Hijri month.

## 4. New Calendar Data Model

Add a focused calendar model, for example:

```dart
class HijriDateParts {
  const HijriDateParts({
    required this.day,
    required this.month,
    required this.year,
  });

  final int day;
  final String month;
  final int year;
}

class HijriCalendarDay {
  const HijriCalendarDay({
    required this.gregorianDate,
    required this.hijri,
    required this.schedule,
    required this.events,
  });

  final DateTime gregorianDate;
  final HijriDateParts hijri;
  final PrayerSchedule schedule;
  final List<IslamicCalendarEvent> events;
}

class HijriCalendarMonth {
  const HijriCalendarMonth({
    required this.month,
    required this.year,
    required this.days,
  });

  final String month;
  final int year;
  final List<HijriCalendarDay> days;
}
```

The parser accepts the app's existing canonical prayer-data format such as:

`13 Rabi al-Thani 1448 AH`

It must reject malformed values cleanly instead of silently inventing dates.

## 5. Hijri Month Loading

### 5.1 Initial month

The initial Calendar month is derived from today's loaded `PrayerSchedule.hijriDate`.

The current Gregorian day is selected when it belongs to that Hijri month.

### 5.2 Gregorian source window

A `HijriCalendarMonthLoader` composes one Hijri month from the existing `PrayerScheduleRepository.loadMonth()` API.

Given the target Hijri month/year, a Gregorian anchor date, the current location, and the current Asr-school setting, the loader requests the anchor Gregorian month plus its previous and next Gregorian months.

It merges schedules by Gregorian date, parses each schedule's Hijri date, keeps only rows matching the requested Hijri month/year, sorts by Gregorian date, and validates that:

- Hijri day 1 exists;
- the final Hijri day is 29 or 30;
- days increase monotonically;
- there are no duplicate Hijri days.

If the composition is incomplete or malformed, return a recoverable Calendar error instead of guessing.

### 5.3 Previous and next Hijri month

The left/right arrows move by one Hijri month.

For next month, use the day after the current Hijri month's last Gregorian date as the new anchor and increment the Hijri month/year.

For previous month, use the day before the current Hijri month's first Gregorian date as the new anchor and decrement the Hijri month/year.

This keeps navigation tied to the same prayer-data Hijri source already used by the app.

### 5.4 Direct month jump

Tapping the centered Hijri month title opens a compact bottom sheet for Hijri month/year selection.

This replaces the always-visible Gregorian month/year dropdowns while preserving direct navigation capability.

For a non-adjacent jump, calculate an **estimated Gregorian search anchor only** from the currently known Hijri/Gregorian mapping and the Hijri-month delta (about 29.53 days per lunar month). The estimate is never displayed and is never treated as the Hijri authority.

Load the estimated Gregorian month plus adjacent Gregorian months, then accept only dates whose existing `PrayerSchedule.hijriDate` matches the requested Hijri month/year. If the target month is incomplete, expand the search window by one Gregorian month on the missing side and retry.

This keeps the existing prayer data as the source of truth while allowing direct jumps without adding a second Hijri calendar engine.

The bottom sheet initially offers the current Hijri year ±5 years, matching the current Calendar's practical direct-jump range. Previous/next arrow navigation is not constrained by that picker range.

The bottom sheet must use the app's standard controls, text styles, spacing, and accent colors.

## 6. Month Header

The page title is localized:

- Bangla: **দিনপঞ্জিকা**
- English: **Calendar**

The month header is centered between previous/next circular arrow controls.

Bangla example:

**রবিউস সানি ১৪৪৮**  
`১২ সেপ্টেম্বর – ১১ অক্টোবর ২০২৬`  
`২৮ ভাদ্র – ২৫ আশ্বিন ১৪৩৩ বঙ্গাব্দ`

The first line is the strongest text. Gregorian and Bangla ranges are secondary.

Range helpers use the actual first and last `HijriCalendarDay.gregorianDate`; they must not assume a fixed Gregorian offset.

For compact display, when both endpoints share the same year, show the year once at the end of the range. When the year changes, show a year on both endpoints. Apply the same rule to the Bangla range.

No fake “তারিখ সমন্বয়” control is added in this task because the repository currently has no Hijri-offset preference or adjustment workflow.

## 7. Month Grid

The grid uses Sunday through Saturday columns.

Each populated cell shows:

- Hijri day — primary, larger;
- Gregorian day — smaller, secondary;
- one small event dot when one or more date-specific verified events exist.

Empty leading/trailing positions are blank.

The cell key is stable by Gregorian date, for example `calendar-day-2026-9-29`.

### Selected state

The selected day uses `Theme.colorScheme.primaryContainer` with `onPrimaryContainer` text and the app's existing compact rounded-corner treatment.

It must not use a hard-coded yellow, green, blue, or purple.

### Event marker

Event dots use `colorScheme.primary`.

Multiple events on one date still render one dot to keep the month grid clean.

In Dark mode the existing effective Graphite accent therefore controls both selected state and event markers.

## 8. Selected Date Detail

Selecting any grid day updates one compact detail section below the month grid.

The section is keyed as `calendar-selected-details` and must not turn the page back into a long list of daily cards.

### 8.1 Date identity

Primary:

**১৮ রবিউস সানি ১৪৪৮**

Secondary:

**মঙ্গলবার, ২৯ সেপ্টেম্বর ২০২৬**  
**১৪ আশ্বিন ১৪৩৩ বঙ্গাব্দ**

The weekday and digits follow the current app language.

### 8.2 Suhur and Iftar strip

Use one compact horizontal surface, not two large cards:

- **সেহরির শেষ** = selected day's Fajr time;
- **ইফতার** = selected day's sunset/Maghrib boundary.

Both values come directly from the selected day's existing `PrayerSchedule`.

### 8.3 Five salat times

Show all five existing prayer times in one compact responsive row or wrap:

- ফজর
- যোহর
- আসর
- মাগরিব
- ইশা

The section also shows the selected schedule's existing location label.

Do not calculate these times again in the Calendar UI.

### 8.4 Prohibited prayer windows

Preserve the current Calendar formulas exactly:

- after sunrise: `sunrise → sunrise + 15 min`;
- before Dhuhr: `Dhuhr - 5 min → Dhuhr`;
- before sunset: `sunset - 15 min → sunset`.

Present them under **নিষিদ্ধ সময় / Prohibited times** as three compact columns.

This is semantic warning information, so warning/prohibition iconography may use the app's semantic error/warning color rather than the user accent.

### 8.5 Share

Preserve the existing “Share day” capability.

The selected-day share output includes the localized Gregorian date, localized Hijri date, Bangla date when Bangla UI is active, and all five salat times.

The share action lives in the selected-date header/action area rather than repeating on every grid cell.

## 9. Verified Islamic Event Rules

Add a small local, testable rule table. It must not depend on live network data.

Each event stores:

- stable id;
- Bangla and English title;
- Bangla and English short description;
- source reference;
- displayed grade;
- whether it belongs to a fixed Hijri date or to the whole Hijri month.

Do not label every event “Sahih.” Display the actual source grade.

### 9.1 Ayyam al-Bid

Every Hijri month:

- 13th — **আইয়ামে বীয — ১ম দিন**
- 14th — **আইয়ামে বীয — ২য় দিন**
- 15th — **আইয়ামে বীয — ৩য় দিন**

Description: voluntary fasting.

Source: **Jamiʿ at-Tirmidhi 761**.  
Displayed grade: **Hasan / হাসান**.

### 9.2 Ashura

10 Muharram:

**আশুরার রোজা**

Source: **Sahih al-Bukhari 1892**.  
Displayed grade: **Sahih / সহিহ**.

### 9.3 Arafah fasting

9 Dhu al-Hijjah:

**আরাফার রোজা**

Source: **Sahih Muslim 1162a**.  
Displayed grade: **Sahih / সহিহ**.

### 9.4 Laylat al-Qadr reminder

Ramadan 21, 23, 25, 27, and 29:

**লাইলাতুল কদর অনুসন্ধানের বিজোড় রাত**

Source: **Sahih al-Bukhari 2017**.  
Displayed grade: **Sahih / সহিহ**.

The UI describes these as nights in which to seek Laylat al-Qadr. It must not claim that one of these calendar dates is definitively Laylat al-Qadr.

### 9.5 Six days of Shawwal

Shawwal shows one month-wide reminder:

**শাওয়ালের ছয় রোজা**

Source: **Sahih Muslim 1164b/1164c**.  
Displayed grade: **Sahih / সহিহ**.

Because the hadith does not assign six fixed Shawwal dates, this reminder does not create event dots on arbitrary dates.

## 10. Event Presentation

When the selected date has one or more date-specific events, show a compact **আজকের আমল ও গুরুত্বপূর্ণ দিন / This day's reminders** section below prayer data.

If the selected date has no event, omit the section rather than inventing a generic event.

Below selected-day information show:

**এই মাসের আমল ও গুরুত্বপূর্ণ দিন**

List date-specific events in the current Hijri month plus any month-wide reminder.

Each event row shows title, short description, source/grade, and a chevron or details affordance when source details are available.

Use dividers and restrained surfaces instead of independent raised cards.

## 11. Typography and Visual System

The Calendar uses the same application typography established in `app_theme.dart`.

Rules:

- Bangla uses the global Solaimani Lipi configuration;
- no Calendar-only font family;
- page/month title uses the existing title scale;
- body and metadata use existing body styles;
- regular weights dominate;
- use the existing 8 px spacing rhythm;
- touch targets remain at least 48 dp;
- avoid large shadows and heavy colored card headers.

The Calendar must feel like the same product as Home, Quran, and Settings.

## 12. Accent and Dark Mode

No Calendar-specific accent palette is introduced.

Use semantic theme tokens:

- selected date: `primaryContainer`;
- event dot and active month affordances: `primary`;
- secondary text: `onSurfaceVariant`;
- separators: `outlineVariant`;
- neutral surfaces: `surface`, `surfaceContainerLow`, `surfaceContainer`;
- prohibited-time warning: semantic error/warning treatment.

Light mode follows the selected Graphite, Rose, Mint, Lavender, or Sky accent.

Dark mode follows the app's existing effective **Graphite** rule and must not reintroduce generated blue/purple Material accents.

## 13. Loading, Error, and Offline Behavior

Preserve the current requirement that prayer Calendar data needs a configured location.

### Loading

Show the existing compact progress indicator while the Hijri month is being composed.

### No location

Keep the existing localized location-required state. Do not request or persist a second location specifically for Calendar.

### Month load error

Show a compact retry state using the current theme.

Retry invalidates or reloads the Hijri month composition.

### Offline

When the app is using the existing offline `PrayerScheduleRepository` path, Hijri month composition continues to work from its calculated monthly schedules.

Islamic events and Bangla dates remain entirely local, so this redesign adds no new network dependency.

## 14. State and Interaction

Calendar state owns:

- selected Hijri month/year;
- Gregorian anchor date;
- selected Gregorian date inside the composed Hijri month.

Rules:

- initial selected date is today when today belongs to the initial Hijri month;
- tapping a grid cell selects that Gregorian date and updates the detail section;
- selected state survives ordinary widget rebuilds;
- locale/theme changes redraw the Calendar without reinterpreting dates;
- changing Hijri month selects the first valid day of the new month unless a meaningful selected day can be preserved.

## 15. File Boundaries

Expected focused additions/changes:

- `lib/features/home/presentation/prayer_calendar_page.dart` — redesigned screen and interaction;
- new `lib/features/home/data/hijri_calendar_month.dart` — Hijri parsing and month composition;
- new `lib/features/home/data/islamic_calendar_events.dart` — verified local event rules;
- existing `lib/features/home/data/bangla_calendar.dart` — reuse, with only small display/range helpers if needed;
- corresponding tests under `test/features/home/...`.

If `prayer_calendar_page.dart` becomes too large, extract visual-only widgets into a nearby `widgets/calendar/` folder.

Do not move or refactor unrelated Home code.

## 16. Test Strategy

Follow TDD for each behavior.

### Unit tests

Cover:

- valid Hijri-date parsing;
- malformed Hijri input;
- composing one Hijri month across two Gregorian months;
- 29-day and 30-day Hijri months;
- previous/next Hijri month and year rollover;
- duplicate/missing Hijri-day rejection;
- Gregorian range from actual first/last day;
- Bangla range from actual first/last day;
- Ayyam al-Bid 13/14/15 with Hasan metadata;
- Ashura rule;
- Arafah rule;
- Ramadan odd-night reminder;
- Shawwal month-wide reminder with no arbitrary day dot.

### Widget tests

Cover:

- compact 7-column month grid;
- Sunday-first weekday headers;
- initial current-day selection;
- tapping a date updates all selected-date values;
- Suhur/Iftar use the selected schedule;
- five salat times use the selected schedule;
- prohibited windows use the selected schedule;
- selected-day event section;
- month event list;
- share action remains available;
- Light accent changes selected cell/event dot;
- Dark mode uses Graphite;
- Bangla UI uses Bangla labels/digits/date;
- English UI remains usable;
- no overflow at 360×780;
- enlarged text-scale regression.

### Regression validation

Run at minimum:

- Calendar unit/widget tests;
- Home presentation tests;
- Bangla-calendar tests;
- prayer-schedule/offline-calculator tests;
- theme/settings tests;
- full `flutter test`;
- `flutter analyze`;
- `git diff --check`.

GitHub Actions are not required for this task. Local validation is the source of truth.

## 17. Device Acceptance

On the connected Android device verify:

1. Calendar opens without overflow or visual jump.
2. Initial month is the correct current Hijri month.
3. Gregorian range can cross a Gregorian month boundary.
4. Bangla range matches the same first/last Gregorian dates.
5. Previous/next arrows navigate by Hijri month.
6. Direct Hijri month/year jump works.
7. Selected day is visibly accent-tinted without a heavy card.
8. Selecting several dates updates Hijri/Gregorian/Bangla date text.
9. Suhur/Iftar update per selected date.
10. All five salat times update per selected date.
11. All three prohibited-time windows update per selected date.
12. Event dots correspond only to actual date-specific rules.
13. Ayyam al-Bid shows 13/14/15 and displays Hasan, not Sahih.
14. Shawwal six-fast reminder is month-wide rather than pinned to arbitrary dates.
15. Light mode follows the chosen accent.
16. Dark mode uses Graphite.
17. Typography and spacing visually match Home/Quran/Settings.
18. Share-day still works.

## 18. Explicit Non-goals

This task does not:

- replace the prayer-time calculation engine;
- introduce a new Hijri astronomy package;
- add a user-controlled Hijri date offset;
- claim locally observed moon-sighting dates;
- add unverified cultural commemorations as hadith-backed events;
- create fake Lessons/Reflections/event actions;
- redesign bottom navigation;
- change Home prayer-time logic;
- change the global typography scale.

## 19. Completion Criteria

The redesign is complete only when:

- the visible month is a real composed Hijri month rather than a Gregorian month with Hijri labels;
- all selected-day data comes from that selected day's existing `PrayerSchedule`;
- Hijri, Gregorian, and Bangla dates are visible as approved;
- verified event metadata is accurate and graded honestly;
- theme/accent/Dark behavior is inherited from the app-wide system;
- the screen is compact and information-first;
- the full local validation suite passes.

## 20. Source Verification Notes

The event references in this spec were cross-checked against Sunnah.com before implementation:

- Jamiʿ at-Tirmidhi 761 explicitly names the 13th, 14th, and 15th and is graded Hasan.
- Sahih al-Bukhari 1892 identifies 10 Muharram as Ashura and records the Prophet's fasting of it.
- Sahih Muslim 1162a records the virtue of fasting Arafah and Ashura.
- Sahih al-Bukhari 2017 instructs seeking Laylat al-Qadr in the odd nights of the last ten nights of Ramadan.
- Sahih Muslim 1164b/1164c establishes fasting six days of Shawwal without assigning fixed dates.

The implementation must preserve this distinction between fixed-date rules, odd-night reminders, and month-wide reminders.
