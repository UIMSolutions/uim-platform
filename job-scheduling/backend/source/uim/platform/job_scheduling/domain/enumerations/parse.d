/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Parsing of the string valued domain enumerations (case insensitive).
module uim.platform.job_scheduling.domain.enumerations.parse;

import std.traits : EnumMembers;
import std.uni : icmp;
import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

/// All values of a string enum, in declaration order.
string[] domainEnumValues(E)() if (is(E : string) && is(E == enum)) {
  string[] values;
  static foreach (m; EnumMembers!E)
    values ~= cast(string) m;
  return values;
}

/// Parse a string enum value; throws JobSchedulingException.invalid.
E parseDomainEnum(E)(string text, string field = E.stringof) if (is(E : string) && is(E == enum)) {
  auto t = text.strip;
  static foreach (m; EnumMembers!E)
    if (icmp(cast(string) m, t) == 0)
      return m;
  throw JobSchedulingException.invalid("Invalid " ~ field ~ " '" ~ text ~ "' (allowed: " ~ domainEnumValues!E.join(", ") ~ ")");
}

/// Parse or fall back to a default (empty text → default).
E parseDomainEnumOr(E)(string text, E fallback, string field = E.stringof) if (is(E : string) && is(E == enum)) {
  return text.strip.length == 0 ? fallback : parseDomainEnum!E(text, field);
}

/// Parse, returning the fallback for unknown values (tolerant record reading).
E domainEnumOr(E)(string text, E fallback) if (is(E : string) && is(E == enum)) {
  try
    return parseDomainEnumOr!E(text, fallback);
  catch (JobSchedulingException)
    return fallback;
}

///
unittest {
  assert(parseDomainEnum!JobHttpMethod("post") == JobHttpMethod.post);
  assert(parseDomainEnum!ScheduleFormat("REPEATINTERVAL") == ScheduleFormat.repeatInterval);
  assert(parseDomainEnumOr!RunStatus("", RunStatus.scheduled) == RunStatus.scheduled);
  assert(domainEnumOr!RunStatus("garbage", RunStatus.failed) == RunStatus.failed);
  assert(failsWith(JsErrorKind.invalid, () { parseDomainEnum!JobHttpMethod("TRACE"); }));
  assert(domainEnumValues!ScheduleType == ["oneTime", "recurring"]);
}
