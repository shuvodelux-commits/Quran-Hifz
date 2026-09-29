# Hijri-first Calendar Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the Gregorian-month prayer-card list with a compact Hijri-first Calendar that shows Bangla/Gregorian ranges, selected-day prayer details, verified Islamic reminders, app-wide accent colors, and Graphite Dark mode without changing the existing prayer engine.

**Architecture:** Add a small pure Hijri parsing/month-composition layer over the existing `PrayerScheduleRepository`, plus a local Islamic-event rule table. The presentation layer consumes one validated `HijriCalendarMonth`, renders a compact month grid, and derives all selected-day data from the selected `PrayerSchedule`; no second prayer calculator, Hijri astronomy package, or location model is introduced.

**Tech Stack:** Flutter, Dart, Riverpod, Material 3, existing `PrayerScheduleRepository`, existing Bangladesh Bangla calendar helper, `share_plus`, Flutter widget/unit tests.

**Spec:** `docs/superpowers/specs/2026-09-29-hijri-calendar-redesign-design.md`

## Global Constraints

- Keep `PrayerScheduleRepository` as the only prayer-time/Hijri-date source of truth.
- Do not add a Hijri astronomy/conversion package or a second location model.
- Reuse `banglaCalendarDate()` for Bangladesh Bangla dates.
- Bangla UI uses the app's existing Solaimani Lipi typography and current type scale.
- Calendar spacing follows the app's existing 8 px rhythm; avoid heavy raised-card stacks.
- Light mode uses the selected app accent; Dark mode uses the existing effective Graphite accent.
- Selected date uses `colorScheme.primaryContainer`; event dots use `colorScheme.primary`.
- Prohibited-prayer windows preserve the existing formulas exactly.
- Islamic reminder data is local/offline and stores its source and displayed grade.
- Do not add a fake Hijri “adjust days” control in this task.
- GitHub Actions are not required; local Flutter tests/analyzer/device verification are authoritative.

## Review Focus

1. **Malformed or unexpected Hijri strings:** parser must return failure, never invent a date; pinned in Task 1 parser tests.
2. **Hijri month crossing Gregorian year/month boundaries or incomplete three-month windows:** loader must expand once and reject duplicate/missing days; pinned in Task 3 loader tests.
3. **Rapid previous/next navigation with futures completing out of order:** stale data must not replace the currently requested month; pinned in Task 5 widget/provider test.
4. **Narrow phone plus enlarged text:** grid/detail content must not overflow at 360×780 and supported enlarged text scale; pinned in Task 7 layout tests.
5. **Month-wide reminders versus fixed-date events:** Shawwal reminder must not create arbitrary day dots while Ayyam al-Bid/Ashura/Arafah/Qadr rules do; pinned in Task 2 event tests.

---

## File Structure

**Create**
- `lib/features/home/data/hijri_calendar_month.dart` — Hijri date parsing, month identity/arithmetic, validated month composition.
- `lib/features/home/data/islamic_calendar_events.dart` — fixed-date and month-wide verified reminder rules.
- `lib/features/home/presentation/widgets/calendar/calendar_month_grid.dart` — compact weekday header and selectable Hijri month grid.
- `lib/features/home/presentation/widgets/calendar/calendar_selected_day_details.dart` — selected date, Suhur/Iftar, salat times, prohibited windows, reminders, share affordance.
- `test/features/home/data/hijri_calendar_month_test.dart`
- `test/features/home/data/islamic_calendar_events_test.dart`
- `test/features/home/presentation/calendar_month_grid_test.dart`
- `test/features/home/presentation/calendar_selected_day_details_test.dart`

**Modify**
- `lib/features/home/presentation/prayer_calendar_page.dart:11-495` — replace Gregorian month/list state with Hijri month request/state, compact header, grid, details, picker.
- `lib/core/localization/app_locale_text.dart:33-94` — localized Gregorian range/month helpers and public Hijri month-name helper if needed.
- `lib/features/home/data/bangla_calendar.dart:31-61` — Bangla range formatting helper.
- `test/features/home/presentation/prayer_calendar_page_test.dart` — integration/state/theme/navigation coverage.
- `test/features/home/data/bangla_calendar_test.dart` — range formatting.
- relevant existing Home/theme tests only where a public behavior changes.

### Task 1: Hijri Date Core Model and Arithmetic

**Files:**
- Create: `lib/features/home/data/hijri_calendar_month.dart`
- Test: `test/features/home/data/hijri_calendar_month_test.dart`

**Interfaces:**
- Produces:
  - `class HijriDateParts { int day; String month; int year; }`
  - `class HijriMonthKey { String month; int year; }`
  - `HijriDateParts? parseHijriDate(String value)`
  - `HijriMonthKey nextHijriMonth(HijriMonthKey current)`
  - `HijriMonthKey previousHijriMonth(HijriMonthKey current)`
  - `int hijriMonthDelta(HijriMonthKey from, HijriMonthKey to)`
  - canonical `hijriMonthOrder` matching the existing prayer-data names.

- [ ] **Step 1: Write failing parser and month-arithmetic tests**

Add tests named:

- `parseHijriDate accepts canonical PrayerSchedule format`
- `parseHijriDate trims harmless whitespace but rejects malformed or unknown month names`
- `nextHijriMonth rolls Dhu al-Hijjah into Muharram of next year`
- `previousHijriMonth rolls Muharram into Dhu al-Hijjah of previous year`
- `hijriMonthDelta handles positive negative and cross-year jumps`

Key assertions:

```dart
expect(
  parseHijriDate('13 Rabi al-Thani 1448 AH'),
  const HijriDateParts(day: 13, month: 'Rabi al-Thani', year: 1448),
);
expect(parseHijriDate('bad value'), isNull);
expect(parseHijriDate('13 Unknown 1448 AH'), isNull);
expect(
  nextHijriMonth(const HijriMonthKey(month: 'Dhu al-Hijjah', year: 1448)),
  const HijriMonthKey(month: 'Muharram', year: 1449),
);
```

- [ ] **Step 2: Run the tests and verify RED**

Run:

`flutter test test/features/home/data/hijri_calendar_month_test.dart`

Expected: compile/test failure because the new model/functions do not exist.

- [ ] **Step 3: Implement the pure model/parser/arithmetic**

Implement the exact interfaces above in `hijri_calendar_month.dart`.

Parser requirements:
- accept `<day> <canonical month> <year> AH`;
- trim outer/repeated whitespace;
- day must be 1–30;
- year must be positive;
- month must be in the existing 12-name canonical order;
- return `null` for malformed input.

- [ ] **Step 4: Run Task 1 tests and verify GREEN**

Run:

`flutter test test/features/home/data/hijri_calendar_month_test.dart`

Expected: all Task 1 tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/features/home/data/hijri_calendar_month.dart   test/features/home/data/hijri_calendar_month_test.dart
git commit -m "feat: add Hijri calendar date model"
```

### Task 2: Verified Islamic Reminder Rules

**Files:**
- Create: `lib/features/home/data/islamic_calendar_events.dart`
- Create: `test/features/home/data/islamic_calendar_events_test.dart`

**Interfaces:**
- Consumes: `HijriDateParts`, `HijriMonthKey` from Task 1.
- Produces:
  - `class IslamicCalendarEvent`
  - `List<IslamicCalendarEvent> islamicEventsFor(HijriDateParts date)`
  - `List<IslamicCalendarEvent> islamicMonthRemindersFor(HijriMonthKey month)`

- [ ] **Step 1: Write failing event-rule tests**

Cover these exact rules:

- 13, 14, 15 every Hijri month → Ayyam al-Bid day 1/2/3, source `Jamiʿ at-Tirmidhi 761`, grade `Hasan / হাসান`.
- 10 Muharram → Ashura, source `Sahih al-Bukhari 1892`, grade `Sahih / সহিহ`.
- 9 Dhu al-Hijjah → Arafah fasting, source `Sahih Muslim 1162a`, grade `Sahih / সহিহ`.
- Ramadan 21/23/25/27/29 → odd-night Laylat al-Qadr reminder, source `Sahih al-Bukhari 2017`, grade `Sahih / সহিহ`.
- Shawwal → one month-wide six-fast reminder, source `Sahih Muslim 1164b/1164c`, grade `Sahih / সহিহ`.
- Shawwal month-wide reminder must not appear from `islamicEventsFor()` and therefore cannot create a day dot.
- A normal date such as 18 Rabi al-Thani returns no date-specific event.

- [ ] **Step 2: Run the event tests and verify RED**

Run:

`flutter test test/features/home/data/islamic_calendar_events_test.dart`

Expected: compile/test failure because the event API does not exist.

- [ ] **Step 3: Implement the event model and rules**

`IslamicCalendarEvent` fields:

```dart
final String id;
final String titleBangla;
final String titleEnglish;
final String subtitleBangla;
final String subtitleEnglish;
final String source;
final String gradeBangla;
final String gradeEnglish;
final bool monthWide;
```

Keep rules deterministic, local, and side-effect-free.

- [ ] **Step 4: Run Task 2 tests and verify GREEN**

Run:

`flutter test test/features/home/data/islamic_calendar_events_test.dart`

Expected: all event-rule tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/features/home/data/islamic_calendar_events.dart   test/features/home/data/islamic_calendar_events_test.dart
git commit -m "feat: add verified Islamic calendar reminders"
```

### Task 3: Compose a True Hijri Month from Existing Prayer Schedules

**Files:**
- Modify: `lib/features/home/data/hijri_calendar_month.dart`
- Modify: `test/features/home/data/hijri_calendar_month_test.dart`
- Consume: `lib/features/home/data/prayer_schedule.dart`
- Consume: `lib/features/home/data/islamic_calendar_events.dart`

**Interfaces:**
- Consumes: Task 1 Hijri model/arithmetic and Task 2 event rules.
- Produces:
  - `class HijriCalendarDay { DateTime gregorianDate; HijriDateParts hijri; PrayerSchedule schedule; List<IslamicCalendarEvent> events; }`
  - `class HijriCalendarMonth { HijriMonthKey key; List<HijriCalendarDay> days; }`
  - `class HijriCalendarMonthLoader`
  - `Future<HijriCalendarMonth> HijriCalendarMonthLoader.load({...})`
  - `DateTime HijriCalendarMonthLoader.estimateAnchor({required HijriMonthKey from, required DateTime fromAnchor, required HijriMonthKey to})`

Use this load signature:

```dart
Future<HijriCalendarMonth> load({
  required HijriMonthKey target,
  required DateTime anchorDate,
  required String location,
  required double latitude,
  required double longitude,
  required int utcOffsetMinutes,
  required AsrSchool school,
});
```

- [ ] **Step 1: Write failing month-composition tests with a fake `PrayerScheduleRepository`**

Add tests named:

- `loader composes a 30-day Hijri month spanning two Gregorian months`
- `loader accepts a complete 29-day month only when next Hijri day 1 is present`
- `loader de-duplicates overlapping Gregorian source rows by calendar date`
- `loader rejects a target missing Hijri day 1`
- `loader rejects a gap or duplicate Hijri day`
- `loader expands one Gregorian month when the initial search window is incomplete`
- `loader handles December to January Gregorian rollover`
- `estimateAnchor moves by about 29.53 days per Hijri month delta without becoming the Hijri authority`

The fake repository must record requested Gregorian `(year, month)` pairs so tests can assert the initial anchor-1/anchor/anchor+1 window and one-side expansion.

For 29-day validation, include the next Gregorian day's schedule parsed as `1 <next Hijri month> <year> AH`; without that boundary row, expect the loader to treat the month as incomplete.

- [ ] **Step 2: Run Task 3 tests and verify RED**

Run:

`flutter test test/features/home/data/hijri_calendar_month_test.dart`

Expected: failures for missing loader/month classes.

- [ ] **Step 3: Implement month composition**

Implementation requirements:
- normalize source dates to `DateTime(year, month, day)`;
- fetch anchor previous/current/next Gregorian months;
- de-duplicate by normalized Gregorian date;
- parse each schedule's `hijriDate`;
- retain target month/year rows;
- validate day 1, strict +1 day sequence, and 29/30 end boundary using the next Hijri month day 1;
- attach `islamicEventsFor(parsedHijri)` to each retained day;
- expand once on the missing Gregorian side when initial source rows cannot prove completeness;
- throw a descriptive `StateError` after the permitted expansion if still incomplete;
- calculate direct-jump search anchors using `hijriMonthDelta * 29.53059` days rounded to the nearest day.

- [ ] **Step 4: Run Task 3 tests and verify GREEN**

Run:

`flutter test test/features/home/data/hijri_calendar_month_test.dart test/features/home/data/islamic_calendar_events_test.dart`

Expected: all Task 1–3 data tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/features/home/data/hijri_calendar_month.dart   test/features/home/data/hijri_calendar_month_test.dart
git commit -m "feat: compose Hijri months from prayer schedules"
```

### Task 4: Localized Gregorian and Bangla Date Ranges

**Files:**
- Modify: `lib/core/localization/app_locale_text.dart:33-94`
- Modify: `lib/features/home/data/bangla_calendar.dart:31-61`
- Modify: `test/features/home/data/bangla_calendar_test.dart`
- Modify: `test/core/localization/app_locale_text_test.dart`.

**Interfaces:**
- Produces:
  - `String localGregorianDateRange(DateTime start, DateTime end, AppLanguage language)`
  - `String localHijriMonthName(String canonicalMonth, AppLanguage language)`
  - `String banglaCalendarRange(DateTime start, DateTime end, {bool english = false})`

- [ ] **Step 1: Write failing range/localization tests**

Pin these behaviors:

- Bangla same-year Gregorian range: `১২ সেপ্টেম্বর – ১১ অক্টোবর ২০২৬`.
- English same-year Gregorian range: `12 September – 11 October 2026`.
- Cross-year range shows both years.
- Bangla-calendar range derives both endpoints using `banglaCalendarDate()`, omits duplicate year when equal, and includes both years when crossing Bangla year.
- `localHijriMonthName('Rabi al-Thani', bangla)` returns `রবিউস সানি`.
- Unknown canonical Hijri month falls back to the input string instead of throwing.

- [ ] **Step 2: Run the range tests and verify RED**

Run the focused localization/Bangla tests.

Expected: failures because the new range helpers do not exist.

- [ ] **Step 3: Implement the helpers without changing existing single-date output**

Do not alter `localGregorianDate()`, `localHijriDate()`, or `banglaCalendarDate()` behavior.

Range functions may parse the existing Bangla single-date strings only if that remains deterministic; otherwise expose a small structured Bangla-date helper internally and keep the public single-date result unchanged.

- [ ] **Step 4: Run Task 4 tests and verify GREEN**

Run:

`flutter test test/features/home/data/bangla_calendar_test.dart test/core/localization/app_locale_text_test.dart`

Expected: all range and existing date tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/core/localization/app_locale_text.dart \
  lib/features/home/data/bangla_calendar.dart \
  test/features/home/data/bangla_calendar_test.dart \
  test/core/localization/app_locale_text_test.dart
git commit -m "feat: add localized calendar date ranges"
```

### Task 5: Compact Hijri Month Grid

**Files:**
- Create: `lib/features/home/presentation/widgets/calendar/calendar_month_grid.dart`
- Create: `test/features/home/presentation/calendar_month_grid_test.dart`

**Interfaces:**
- Consumes: `HijriCalendarMonth`, `HijriCalendarDay`, `AppLanguage`.
- Produces:

```dart
class CalendarMonthGrid extends StatelessWidget {
  const CalendarMonthGrid({
    super.key,
    required this.month,
    required this.selectedDate,
    required this.language,
    required this.onSelected,
  });

  final HijriCalendarMonth month;
  final DateTime selectedDate;
  final AppLanguage language;
  final ValueChanged<HijriCalendarDay> onSelected;
}
```

- [ ] **Step 1: Write failing widget tests for grid structure and theme**

Tests must assert:

- root key `calendar-month-grid`;
- weekday headers are Sunday-first;
- leading blank count is `month.days.first.gregorianDate.weekday % 7`;
- each populated cell shows Hijri day large and Gregorian day secondary;
- selected cell key is `calendar-day-<yyyy>-<m>-<d>` and its decorated surface is `colorScheme.primaryContainer`;
- a day with `events.isNotEmpty` renders `calendar-event-dot-<yyyy>-<m>-<d>` using `colorScheme.primary`;
- a day without events renders no event dot;
- tapping a cell returns that exact `HijriCalendarDay`;
- Dark theme's selected surface/dot derive from Graphite theme tokens;
- 360 px width does not overflow.

- [ ] **Step 2: Run grid tests and verify RED**

Run:

`flutter test test/features/home/presentation/calendar_month_grid_test.dart`

Expected: compile failure because `CalendarMonthGrid` does not exist.

- [ ] **Step 3: Implement the compact grid**

Use:
- no raised card around every day;
- `GridView`/manual 7-column layout with scrolling disabled so the page owns vertical scroll;
- existing text theme, not hard-coded font family;
- 48 dp minimum tap target even when the visual selection shape is smaller;
- localized digits through `localDigits`;
- one event dot maximum per date.

- [ ] **Step 4: Run Task 5 tests and verify GREEN**

Run:

`flutter test test/features/home/presentation/calendar_month_grid_test.dart`

Expected: all grid tests pass with no overflow diagnostics.

- [ ] **Step 5: Commit**

```bash
git add lib/features/home/presentation/widgets/calendar/calendar_month_grid.dart   test/features/home/presentation/calendar_month_grid_test.dart
git commit -m "feat: add compact Hijri calendar grid"
```

### Task 6: Selected-Day Prayer Details and Event Lists

**Files:**
- Create: `lib/features/home/presentation/widgets/calendar/calendar_selected_day_details.dart`
- Create: `lib/features/home/presentation/widgets/calendar/calendar_event_list.dart`
- Create: `test/features/home/presentation/calendar_selected_day_details_test.dart`
- Create: `test/features/home/presentation/calendar_event_list_test.dart`

**Interfaces:**
- Consumes: `HijriCalendarDay`, `HijriCalendarMonth`, Task 2 event metadata, Task 4 date helpers.
- Produces:

```dart
class CalendarSelectedDayDetails extends StatelessWidget {
  const CalendarSelectedDayDetails({
    super.key,
    required this.day,
    required this.language,
    required this.onShare,
  });

  final HijriCalendarDay day;
  final AppLanguage language;
  final VoidCallback onShare;
}

class CalendarEventList extends StatelessWidget {
  const CalendarEventList({
    super.key,
    required this.month,
    required this.language,
  });

  final HijriCalendarMonth month;
  final AppLanguage language;
}
```

- [ ] **Step 1: Write failing selected-day tests**

Pin:
- root key `calendar-selected-details`;
- localized full Hijri date, Gregorian date + weekday, and Bangla date are visible;
- Suhur end equals selected schedule Fajr;
- Iftar equals selected schedule sunset;
- Fajr/Dhuhr/Asr/Maghrib/Isha all use the selected schedule values;
- location label is the selected schedule location;
- prohibited windows are exactly sunrise→+15, Dhuhr-5→Dhuhr, sunset-15→sunset;
- tapping Share calls `onShare` once;
- a fixed-date event renders title, description, source, and grade;
- no selected-day event section appears when `day.events` is empty.

- [ ] **Step 2: Write failing month-event-list tests**

Pin:
- fixed-date events are sorted by Hijri day;
- month-wide Shawwal reminder is included once;
- month-wide reminder does not pretend to have a specific day;
- rows use dividers/neutral surfaces rather than one raised card per event;
- long Bangla title does not overflow at 360 px.

- [ ] **Step 3: Run Task 6 tests and verify RED**

Run:

`flutter test test/features/home/presentation/calendar_selected_day_details_test.dart test/features/home/presentation/calendar_event_list_test.dart`

Expected: compile failures because the widgets do not exist.

- [ ] **Step 4: Implement selected-day details**

Use one compact vertical section:
- date identity;
- one horizontal Suhur/Iftar strip;
- responsive five-prayer row/wrap;
- compact prohibited-time row;
- optional selected-day reminder block;
- share icon in the date header.

Use `Theme.of(context).textTheme` and semantic ColorScheme tokens only.

- [ ] **Step 5: Implement month event list**

Collect:
- every date-specific event from `month.days`;
- `islamicMonthRemindersFor(month.key)`.

Do not duplicate the same event id.

- [ ] **Step 6: Run Task 6 tests and verify GREEN**

Run the two Task 6 test files.

Expected: all pass and no overflow diagnostics.

- [ ] **Step 7: Commit**

```bash
git add lib/features/home/presentation/widgets/calendar/calendar_selected_day_details.dart   lib/features/home/presentation/widgets/calendar/calendar_event_list.dart   test/features/home/presentation/calendar_selected_day_details_test.dart   test/features/home/presentation/calendar_event_list_test.dart
git commit -m "feat: add calendar day details and reminders"
```

### Task 7: Prayer Calendar Page Orchestration, Hijri Navigation, Picker, and Share

**Files:**
- Modify: `lib/features/home/presentation/prayer_calendar_page.dart:11-495`
- Modify: `test/features/home/presentation/prayer_calendar_page_test.dart`
- Reuse: Task 3 loader, Task 4 date helpers, Task 5 grid, Task 6 detail/event widgets.

**Interfaces:**
- Replace the current Gregorian `_MonthRequest`/`_monthlyPrayersProvider` with a Hijri-month request/provider keyed by:
  - target `HijriMonthKey`;
  - Gregorian anchor date;
  - location name/latitude/longitude/UTC offset;
  - `AsrSchool`.
- Page state stores:
  - current target `HijriMonthKey?`;
  - current Gregorian search anchor;
  - selected Gregorian date.
- Initial target comes from the current `prayerScheduleProvider` schedule's `hijriDate`.

- [ ] **Step 1: Rewrite the page integration tests first**

Replace the old Gregorian-list expectations with tests named:

- `calendar opens on current Hijri month and selects today`
- `month header shows Hijri title Gregorian range and Bangla range`
- `previous and next arrows navigate by Hijri month`
- `tapping a grid date updates the selected-day detail only`
- `rapid month navigation ignores stale future completion`
- `retry reloads the currently requested Hijri month`
- `no configured location keeps the existing location-required state`
- `Bangla app title is দিনপঞ্জিকা and English title is Calendar`
- `light accent reaches selected cell and event dot`
- `dark mode uses Graphite selected state`
- `selected-day share text includes Hijri Gregorian Bangla date and five prayers`

Use a fake `PrayerScheduleRepository` that returns deterministic Gregorian months spanning one Hijri month boundary. Use completers in the stale-future test so the older request resolves after the newer one.

- [ ] **Step 2: Run page integration tests and verify RED**

Run:

`flutter test test/features/home/presentation/prayer_calendar_page_test.dart`

Expected: failures because the page still exposes Gregorian dropdowns/list cards.

- [ ] **Step 3: Replace Gregorian month state/provider with Hijri month composition**

Implementation rules:
- derive initial `HijriMonthKey` from the loaded current schedule;
- create `HijriCalendarMonthLoader(ref.watch(prayerScheduleRepositoryProvider))`;
- watch only the provider for the current request key so Riverpod discards stale family results naturally;
- when a month loads, keep today selected if today is in that month; otherwise select the first valid day unless a preserved selected day belongs to the month;
- remove `_ScrollController`, `_dayKeys`, `_revealTodayAfterLayout`, old Gregorian dropdowns, `_CalendarDayCard`, `_TimeStrip`, and `_AvoidChip`.

- [ ] **Step 4: Build the compact page shell**

Render in one page-owned `ListView`:

1. compact month-navigation header;
2. `CalendarMonthGrid`;
3. subtle section separator/spacing;
4. `CalendarSelectedDayDetails`;
5. `CalendarEventList`.

The month header must show:
- localized Hijri month/year;
- `localGregorianDateRange(first, last, language)`;
- `banglaCalendarRange(first, last, english: language == AppLanguage.english)`.

Use current app typography; do not add Calendar-specific font sizes except where a cell needs a constrained secondary size already supported by the type scale.

- [ ] **Step 5: Implement previous/next Hijri navigation**

Previous:
- target = `previousHijriMonth(current.key)`;
- anchor = current first Gregorian date minus one day.

Next:
- target = `nextHijriMonth(current.key)`;
- anchor = current last Gregorian date plus one day.

Selection updates after the new month loads, not before.

- [ ] **Step 6: Implement the direct Hijri month/year bottom sheet**

Tapping the month title opens a bottom sheet with:
- 12 canonical Hijri months localized through `localHijriMonthName`;
- year choices current Hijri year ±5;
- current selection indicated by app accent.

On confirm:
- target = selected `HijriMonthKey`;
- anchor = loader `estimateAnchor(from: current.key, fromAnchor: selected/current month's known Gregorian midpoint or first date, to: target)`.

Do not add an always-visible Gregorian picker.

- [ ] **Step 7: Preserve selected-day Share behavior**

Move the existing `SharePlus.instance.share` call into a page method invoked by `CalendarSelectedDayDetails.onShare`.

Share text must include:
- localized Hijri date;
- localized Gregorian date;
- Bangla date for Bangla UI;
- all five prayer names/times.

Do not include fabricated event text in the share payload unless the selected day actually has a verified event.

- [ ] **Step 8: Run Task 7 tests and verify GREEN**

Run:

`flutter test test/features/home/presentation/prayer_calendar_page_test.dart`

Expected: all integration tests pass.

- [ ] **Step 9: Run Calendar-focused regression set**

Run:

```bash
flutter test   test/features/home/data/hijri_calendar_month_test.dart   test/features/home/data/islamic_calendar_events_test.dart   test/features/home/data/bangla_calendar_test.dart   test/core/localization/app_locale_text_test.dart   test/features/home/presentation/calendar_month_grid_test.dart   test/features/home/presentation/calendar_selected_day_details_test.dart   test/features/home/presentation/calendar_event_list_test.dart   test/features/home/presentation/prayer_calendar_page_test.dart
```

Expected: all Calendar-focused tests pass.

- [ ] **Step 10: Commit**

```bash
git add lib/features/home/presentation/prayer_calendar_page.dart   test/features/home/presentation/prayer_calendar_page_test.dart
git commit -m "feat: redesign Calendar around Hijri months"
```

### Task 8: Accessibility, Full Regression, Device Acceptance, and Branch Finish

**Files:**
- Modify only the Calendar files/tests discovered by failures.
- Do not refactor unrelated modules in this task.

**Interfaces:**
- Consumes the completed Calendar implementation from Tasks 1–7.
- Produces no new public API; this task proves release readiness.

- [ ] **Step 1: Add the final narrow-screen and enlarged-text regressions**

Add/extend widget tests so the full Calendar page:
- renders at 360×780 with no overflow;
- renders at the app-supported enlarged text scale without overflow;
- keeps 48 dp tap targets for month arrows/grid dates;
- wraps salat/prohibited-time details instead of clipping;
- keeps long Bangla event/source text readable.

Run the new tests once before fixes and confirm any uncovered issue fails for the expected layout reason.

- [ ] **Step 2: Run Home/prayer/theme regression suites**

Run at minimum:

```bash
flutter test   test/features/home   test/core/localization/app_locale_text_test.dart   test/app/app_theme_test.dart   test/features/settings/application/app_preferences_controller_test.dart   test/features/settings/presentation/settings_page_test.dart
```

Expected: all pass.

- [ ] **Step 3: Run the full local test suite**

Run:

`flutter test`

Expected: all tests pass. If an unrelated historical failure exists, record its exact test name and baseline evidence before proceeding; do not silently omit it.

- [ ] **Step 4: Run static and diff verification**

Run:

```bash
flutter analyze
git diff --check
git status --short --branch
```

Expected:
- `flutter analyze` → `No issues found!`;
- `git diff --check` → no output;
- only intended Calendar changes are present.

- [ ] **Step 5: Build and install the exact APK**

Run:

```bash
flutter build apk --debug
adb connect 192.168.10.9:5555
adb -s 192.168.10.9:5555 install -r build/app/outputs/flutter-apk/app-debug.apk
```

Verify local APK SHA-256 equals the installed `base.apk` SHA-256.

If the ADB endpoint is unreachable, report device verification as pending rather than claiming success.

- [ ] **Step 6: Execute the approved device checklist**

Verify on the OPPO:

- correct current Hijri month;
- Gregorian range crossing month boundary;
- Bangla range;
- previous/next Hijri navigation;
- direct month/year jump;
- selected date changes all three date systems;
- Suhur/Iftar update;
- five prayers update;
- three prohibited windows update;
- event dots only on fixed-date events;
- Ayyam al-Bid 13/14/15 shows Hasan;
- Shawwal reminder is month-wide only;
- current Light accent appears in selection/dots;
- Dark mode is Graphite;
- typography/spacing match Home/Quran/Settings;
- share still launches with the correct selected-day content.

Capture screenshots of Light and Dark Calendar states for visual review.

- [ ] **Step 7: Final whole-branch review**

Review:
- no duplicate prayer/Hijri/location engine;
- no hard-coded accent colors;
- no Calendar-only font family;
- no unverified event presented as hadith-backed;
- no fixed Shawwal day assignment;
- no stale Gregorian list/card code left behind;
- no unrelated files reformatted.

- [ ] **Step 8: Commit final acceptance-only fixes if any**

If device/accessibility validation required code changes, rerun the affected RED/GREEN test and commit only those fixes:

`git commit -m "fix: finalize Hijri calendar responsive states"`

If no changes were required, do not create an empty commit.

- [ ] **Step 9: Push the branch**

Push `feat/hifz-page-continuous-reader` after local verification. Do not trigger or depend on GitHub Actions.
