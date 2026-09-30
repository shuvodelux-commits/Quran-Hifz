# Bangladesh Hijri Calendar Specification

## Scope
- Home keeps Today’s Ayah and Current Salah content but removes their decorative leading icons.
- Add Calendar & Hijri Date settings in Bangla/English.
- Hijri day boundary is user-selectable: Maghrib (default) or 12:00 AM.
- Bangladesh baseline is AlAdhan HJCoSA for the effective Gregorian day, shifted one day earlier.
- Because 100% equivalence with Bangladesh official moon sighting is not established, keep a manual relative correction: 1 day earlier, Bangladesh default, or 1 day later.
- Manual correction is month-scoped and stops applying when the uncorrected Bangladesh baseline enters a new Hijri month.
- Prayer-time calculation is unchanged.
- Use the same corrected Hijri-date source on Home and the prayer calendar.
- If HJCoSA cannot be fetched, fall back to the existing local hijri_core conversion for the same effective Gregorian source day.

## Date resolution
1. Start with the local civil date.
2. In Maghrib mode, at or after the calculated Maghrib time, advance the civil date by one day. In midnight mode, do not advance it.
3. Shift one Gregorian day earlier for the Bangladesh default.
4. Apply the optional relative correction (-1/0/+1 Gregorian day).
5. Convert the resulting Gregorian date with HJCoSA. On network failure, use hijri_core.
6. Format centrally so Home/calendar agree.

## Persistence
Persist the day-boundary setting, relative correction, and the Hijri year-month scope of a non-zero correction in AppPreferences.

## Tests
Cover Maghrib/midnight boundaries, baseline and correction shifts across Gregorian/Hijri boundaries, month-scoped reset, preference persistence/defaults, settings UI, calendar/Home use of the corrected date, and removal of the two decorative icons.
