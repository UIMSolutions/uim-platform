/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// A schedule of a policy: while it is active, its instance limits replace
/// those of the policy (dynamic rules keep working inside them).
///
///   recurring     every week on daysOfWeek (1 = Monday … 7 = Sunday) or
///                 every month on daysOfMonth (1 … 31), from startTime to
///                 endTime (HH:MM local time; an end before the start runs
///                 over midnight), optionally limited to startDate … endDate
///   specificDate  once, from startDateTime to endDateTime (local time)
///
/// Local times use the time zone of the policy. A specific-date schedule
/// wins over a recurring one. initialMinInstanceCount raises the instances
/// once when the schedule starts.
module uim.platform.application_autoscaler.domain.entities.scaling_schedule;

import uim.platform.application_autoscaler;

mixin(ShowModule!());

@safe:

struct ScalingSchedule {
  mixin TenantEntity!ScheduleId;

  ScalingPolicyId policyId;
  string name;
  ScheduleKind kind = ScheduleKind.recurring;
  string startTime; /// recurring: "HH:MM"
  string endTime; /// recurring: "HH:MM"
  string[] daysOfWeek; /// recurring: "1" … "7"
  string[] daysOfMonth; /// recurring: "1" … "31"
  string startDate; /// recurring: optional first day "YYYY-MM-DD"
  string endDate; /// recurring: optional last day "YYYY-MM-DD"
  string startDateTime; /// specificDate: "YYYY-MM-DDTHH:MM"
  string endDateTime; /// specificDate: "YYYY-MM-DDTHH:MM"
  int instanceMinCount = 1;
  int instanceMaxCount = 5;
  int initialMinInstanceCount; /// 0 = none
  bool enabled = true;

  /// std time the current occurrence started, or 0 if the schedule is not active at now.
  long activeSince(long now, string zone) const @trusted {
    if (!enabled)
      return 0;
    if (kind == ScheduleKind.specificDate) {
      auto from = parseLocalDateTime(startDateTime, zone, "Start");
      auto to = parseLocalDateTime(endDateTime, zone, "End");
      return from <= now && now < to ? from : 0;
    }
    auto local = localTime(now, zone);
    auto minutes = local.hour * 60 + local.minute;
    auto start = parseClockTime(startTime, "Start time");
    auto end = parseClockTime(endTime, "End time");
    auto today = cast(Date) local;
    auto wraps = end <= start;
    Date day;
    if (minutes >= start && (wraps || minutes < end))
      day = today;
    else if (wraps && minutes < end)
      day = today - dur!"days"(1);
    else
      return 0;
    if (!occursOn(day))
      return 0;
    auto began = SysTime(DateTime(day, TimeOfDay(start / 60, start % 60)), local.timezone);
    return began.stdTime;
  }

  bool isActiveAt(long now, string zone) const {
    return activeSince(now, zone) > 0;
  }

  /// True if a recurring occurrence starts on the (local) day.
  bool occursOn(Date day) const @trusted {
    auto iso = day.toISOExtString;
    if (startDate.length && iso < startDate)
      return false;
    if (endDate.length && iso > endDate)
      return false;
    if (daysOfWeek.length)
      return daysOfWeek.canFind(isoWeekday(day.dayOfWeek).to!string);
    return daysOfMonth.canFind(day.day.to!string);
  }

  /// "Mon-Fri 08:00-18:00 → 3..10" (lists, CLI)
  string summary() const {
    auto limits = format("%d..%d", instanceMinCount, instanceMaxCount);
    if (kind == ScheduleKind.specificDate)
      return startDateTime ~ " – " ~ endDateTime ~ " → " ~ limits;
    auto days = daysOfWeek.length ? "weekdays " ~ daysOfWeek.join(",") : "days " ~ daysOfMonth.join(",");
    return days ~ " " ~ startTime ~ "-" ~ endTime ~ " → " ~ limits;
  }

  void validate() const @trusted {
    requireId(id.value, "Schedule ID");
    if (policyId.isNull)
      throw AasException.invalid("Policy is required");
    requireMaxLength(name, 200, "Name");
    requireRange(instanceMinCount, 1, maxInstancesLimit, "Minimum instances");
    requireRange(instanceMaxCount, 1, maxInstancesLimit, "Maximum instances");
    if (instanceMaxCount < instanceMinCount)
      throw AasException.invalid("Maximum instances must not be below minimum instances");
    if (initialMinInstanceCount != 0 && (initialMinInstanceCount < instanceMinCount || initialMinInstanceCount > instanceMaxCount))
      throw AasException.invalid("Initial minimum instances must be 0 or between the minimum and maximum instances");
    if (kind == ScheduleKind.specificDate) {
      auto from = parseLocalDateTime(startDateTime, "UTC", "Start");
      auto to = parseLocalDateTime(endDateTime, "UTC", "End");
      if (to <= from)
        throw AasException.invalid("The end must be after the start");
      if (startTime.length || endTime.length || daysOfWeek.length || daysOfMonth.length)
        throw AasException.invalid("A specific-date schedule has no start/end time and no days");
      return;
    }
    auto start = parseClockTime(startTime, "Start time");
    auto end = parseClockTime(endTime, "End time");
    if (start == end)
      throw AasException.invalid("Start and end time must differ");
    if (start == 1440)
      throw AasException.invalid("The start time must be before 24:00");
    if ((daysOfWeek.length == 0) == (daysOfMonth.length == 0))
      throw AasException.invalid("A recurring schedule needs either days of the week or days of the month");
    foreach (d; daysOfWeek)
      requireDay(d, 7, "Day of the week");
    foreach (d; daysOfMonth)
      requireDay(d, 31, "Day of the month");
    if (startDate.length)
      parseIsoTime(startDate, "Start date");
    if (endDate.length)
      parseIsoTime(endDate, "End date");
    if (startDate.length && endDate.length && endDate < startDate)
      throw AasException.invalid("The end date must not be before the start date");
    if (startDateTime.length || endDateTime.length)
      throw AasException.invalid("A recurring schedule has no start/end date-time");
  }
}

private void requireDay(string d, int max, string what) {
  int n;
  try
    n = d.to!int;
  catch (Exception)
    throw AasException.invalid(what ~ " '" ~ d ~ "' is not a number");
  requireRange(n, 1, max, what);
}

/// Days as canonical numbers: "Mon", "monday", "1" → "1"; sorted, unique.
string[] normalizeDays(const string[] values, bool weekdays) {
  enum string[] names = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"];
  int[] days;
  foreach (v; values) {
    auto t = v.strip.toLower;
    if (t.length == 0)
      continue;
    int n;
    if (weekdays && t.length >= 3 && names.canFind(t[0 .. 3]))
      n = cast(int) names.countUntil(t[0 .. 3]) + 1;
    else {
      try
        n = t.to!int;
      catch (Exception)
        throw AasException.invalid((weekdays ? "Day of the week" : "Day of the month") ~ " '" ~ v ~ "' is invalid");
    }
    requireRange(n, 1, weekdays ? 7 : 31, weekdays ? "Day of the week" : "Day of the month");
    if (!days.canFind(n))
      days ~= n;
  }
  days.sort();
  return days.map!(d => d.to!string).array;
}

///
unittest {
  ScalingSchedule s;
  s.id = ScheduleId("s");
  s.policyId = ScalingPolicyId("p");
  s.startTime = "08:00";
  s.endTime = "18:00";
  s.daysOfWeek = ["1", "2", "3", "4", "5"];
  s.validate();
  // 2026-11-25 is a Wednesday
  assert(s.isActiveAt(parseIsoTime("2026-11-25T09:00:00Z"), "UTC"));
  assert(s.activeSince(parseIsoTime("2026-11-25T09:00:00Z"), "UTC") == parseIsoTime("2026-11-25T08:00:00Z"));
  assert(!s.isActiveAt(parseIsoTime("2026-11-25T18:00:00Z"), "UTC"));
  assert(!s.isActiveAt(parseIsoTime("2026-11-28T09:00:00Z"), "UTC")); // Saturday
  // 07:30 UTC is 08:30 at +01:00
  assert(s.isActiveAt(parseIsoTime("2026-11-25T07:30:00Z"), "+01:00"));
  // over midnight: Friday 22:00 → Saturday 02:00 counts as Friday
  s.startTime = "22:00";
  s.endTime = "02:00";
  assert(s.isActiveAt(parseIsoTime("2026-11-28T01:00:00Z"), "UTC"));
  assert(!s.isActiveAt(parseIsoTime("2026-11-29T01:00:00Z"), "UTC")); // Sunday 01:00 belongs to Saturday
  s.startDate = "2026-12-01";
  assert(!s.isActiveAt(parseIsoTime("2026-11-28T01:00:00Z"), "UTC"));

  ScalingSchedule d;
  d.id = ScheduleId("d");
  d.policyId = ScalingPolicyId("p");
  d.kind = ScheduleKind.specificDate;
  d.startDateTime = "2026-12-24T08:00";
  d.endDateTime = "2026-12-26T20:00";
  d.instanceMinCount = 4;
  d.instanceMaxCount = 10;
  d.initialMinInstanceCount = 6;
  d.validate();
  assert(d.isActiveAt(parseIsoTime("2026-12-25T12:00:00Z"), "UTC") && !d.isActiveAt(parseIsoTime("2026-12-27T00:00:00Z"), "UTC"));
  d.endDateTime = "2026-12-24T07:00";
  assert(failsWith(AasErrorKind.invalid, () { d.validate(); }));

  assert(normalizeDays(["Fri", "mon", "1", " 3 "], true) == ["1", "3", "5"]);
  assert(normalizeDays(["31", "1"], false) == ["1", "31"]);
  assert(failsWith(AasErrorKind.invalid, () { normalizeDays(["8"], true); }));
  assert(failsWith(AasErrorKind.invalid, () { normalizeDays(["funday"], true); }));
}
