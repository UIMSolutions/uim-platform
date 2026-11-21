/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Time values. Entities store std time (hnsecs since 0001-01-01 UTC);
/// 0 means "not set".
module uim.platform.architecture.domain.types.time;

import uim.platform.architecture;

mixin(ShowModule!());

@safe:

enum long hnsecsPerSecondL = 10_000_000;
enum long secondsPerDayL = 86_400;

long nowStdTime() @trusted {
  return Clock.currStdTime();
}

/// std time + days
long plusDays(long stdTime, long days) pure {
  return stdTime + days * secondsPerDayL * hnsecsPerSecondL;
}

/// ISO 8601 date or timestamp (UTC) → std time; 0 for "" and invalid otherwise.
long parseIsoTime(string text) @trusted {
  auto t = text.strip;
  if (t.length == 0)
    return 0;
  try {
    if (t.length == 10) // YYYY-MM-DD
      return SysTime(Date.fromISOExtString(t), UTC()).stdTime;
    return SysTime.fromISOExtString(t).toUTC.stdTime;
  } catch (Exception) {
    throw ArchitectureException.invalid("'" ~ text ~ "' is not an ISO 8601 date or timestamp");
  }
}

/// std time → ISO 8601 (UTC, seconds), "" for 0.
string isoTimeText(long stdTime) @trusted {
  if (stdTime <= 0)
    return "";
  return SysTime(stdTime - stdTime % hnsecsPerSecondL, UTC()).toISOExtString;
}

///
unittest {
  auto t = parseIsoTime("2026-01-02T03:04:05Z");
  assert(isoTimeText(t) == "2026-01-02T03:04:05Z");
  assert(isoTimeText(parseIsoTime("2026-03-01")) == "2026-03-01T00:00:00Z");
  assert(plusDays(t, 1) > t && parseIsoTime("") == 0 && isoTimeText(0) == "");
  assert(failsWith(ArchitectureErrorKind.invalid, () { parseIsoTime("tomorrow"); }));
}
