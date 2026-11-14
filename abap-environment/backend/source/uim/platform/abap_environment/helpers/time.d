/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Timestamps are stored as std time (hnsecs since 0001-01-01, UTC) and exchanged
/// as ISO 8601 / Edm.DateTimeOffset strings ("2026-11-10T10:00:00Z").
module uim.platform.abap_environment.helpers.time;

import core.time : Duration;
import std.datetime.systime : Clock, SysTime;
import std.datetime.timezone : UTC;
import std.string : strip, replace, stripRight, indexOf;
import vibe.data.json : Json;

@safe:

/// Current time as std time.
long nowStdTime() {
  return Clock.currStdTime();
}

/// One day in std time units.
enum long stdTimeDay = 864_000_000_000L;

/// std time → "2026-11-10T10:00:00Z"; 0 → "".
string isoText(long stdTime) {
  if (stdTime <= 0)
    return "";
  try {
    auto t = SysTime(stdTime, UTC());
    t.fracSecs = Duration.zero;
    return t.toISOExtString;
  } catch (Exception) {
    return "";
  }
}

/// std time → Edm.DateTimeOffset JSON value; 0 → null.
Json isoTime(long stdTime) {
  auto text = isoText(stdTime);
  return text.length == 0 ? Json(null) : Json(text);
}

/// "2026-11-10", "2026-11-10T10:00:00Z" or "2026-11-10 10:00:00" → std time.
/// Empty input gives 0; invalid input throws.
long parseIsoTime(string value) {
  auto v = value.strip;
  if (v.length == 0)
    return 0;
  if (v.length == 10)
    v ~= "T00:00:00Z";
  v = v.replace(" ", "T");
  if (v.indexOf('Z') < 0 && v.indexOf('+') < 0 && v[10 .. $].indexOf('-') < 0)
    v ~= "Z";
  return SysTime.fromISOExtString(v).stdTime;
}

/// std time → "2026-11-10 10:00:00" for tables; 0 → "".
string displayTime(long stdTime) {
  return isoText(stdTime).replace("T", " ").stripRight("Z");
}

///
unittest {
  auto t = parseIsoTime("2026-11-10T10:00:00Z");
  assert(isoText(t) == "2026-11-10T10:00:00Z");
  assert(parseIsoTime("2026-11-10") == parseIsoTime("2026-11-10 00:00:00"));
  assert(displayTime(t) == "2026-11-10 10:00:00");
  assert(isoTime(0).type == Json.Type.null_);
  assert(parseIsoTime("") == 0);
}
