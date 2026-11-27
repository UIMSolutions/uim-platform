/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Schedule arithmetic of tasks and task chains: a schedule fires at
/// startAt and then every period (interval minutes, hour, day, week,
/// calendar month). "manual" never fires.
module uim.platform.datasphere.domain.services.schedules;

import uim.platform.datasphere;

mixin(ShowModule!());

@safe:

enum int minIntervalMinutes = 5;
enum int maxIntervalMinutes = 7 * 24 * 60;

/// Check the schedule parameters.
void validateSchedule(ScheduleFrequency frequency, int intervalMinutes) {
  if (frequency == ScheduleFrequency.interval)
    requireRange(intervalMinutes, minIntervalMinutes, maxIntervalMinutes, "Interval (minutes)");
  else if (intervalMinutes != 0)
    requireRange(intervalMinutes, minIntervalMinutes, maxIntervalMinutes, "Interval (minutes)");
}

/// The first firing strictly after `after` (std time), 0 for manual
/// schedules. A schedule without startAt starts at `after`.
long nextRunAfter(ScheduleFrequency frequency, int intervalMinutes, long startAt, long after) @trusted {
  if (frequency == ScheduleFrequency.manual)
    return 0;
  auto start = startAt > 0 ? startAt : after;
  if (start > after)
    return start;
  if (frequency == ScheduleFrequency.monthly) {
    // calendar months: count from the start to keep the day of month stable
    auto months = 1;
    auto t = plusMonths(start, months);
    while (t <= after) {
      months++;
      t = plusMonths(start, months);
    }
    return t;
  }
  long period;
  final switch (frequency) {
  case ScheduleFrequency.interval:
    period = (intervalMinutes > 0 ? intervalMinutes : 60) * hnsecsPerMinuteL;
    break;
  case ScheduleFrequency.hourly:
    period = hnsecsPerHourL;
    break;
  case ScheduleFrequency.daily:
    period = hnsecsPerDayL;
    break;
  case ScheduleFrequency.weekly:
    period = 7 * hnsecsPerDayL;
    break;
  case ScheduleFrequency.manual, ScheduleFrequency.monthly:
    assert(false);
  }
  auto periods = (after - start) / period + 1;
  return start + periods * period;
}

/// "every 30 min", "daily", "manual" (lists, CLI).
string scheduleText(ScheduleFrequency frequency, int intervalMinutes) {
  if (frequency == ScheduleFrequency.interval)
    return "every " ~ intervalMinutes.to!string ~ " min";
  return cast(string) frequency;
}

///
unittest {
  auto start = parseIsoTime("2026-01-31T02:00:00Z");
  auto at = parseIsoTime("2026-02-01T10:00:00Z");
  assert(nextRunAfter(ScheduleFrequency.manual, 0, start, at) == 0);
  assert(isoTimeText(nextRunAfter(ScheduleFrequency.daily, 0, start, at)) == "2026-02-02T02:00:00Z");
  assert(isoTimeText(nextRunAfter(ScheduleFrequency.hourly, 0, start, at)) == "2026-02-01T11:00:00Z");
  assert(isoTimeText(nextRunAfter(ScheduleFrequency.interval, 45, start, at)) == "2026-02-01T10:15:00Z");
  assert(isoTimeText(nextRunAfter(ScheduleFrequency.weekly, 0, start, at)) == "2026-02-07T02:00:00Z");
  assert(isoTimeText(nextRunAfter(ScheduleFrequency.monthly, 0, start, at)) == "2026-02-28T02:00:00Z");
  assert(isoTimeText(nextRunAfter(ScheduleFrequency.monthly, 0, start, parseIsoTime("2026-03-01"))) == "2026-03-31T02:00:00Z");
  assert(nextRunAfter(ScheduleFrequency.daily, 0, plusDays(at, 3), at) == plusDays(at, 3), "future start");
  assert(nextRunAfter(ScheduleFrequency.hourly, 0, 0, at) == plusSeconds(at, 3600));
  validateSchedule(ScheduleFrequency.interval, 15);
  assert(failsWith(DspErrorKind.invalid, () { validateSchedule(ScheduleFrequency.interval, 1); }));
  assert(scheduleText(ScheduleFrequency.interval, 15) == "every 15 min");
}
