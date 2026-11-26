/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Event types and subscription patterns.
///
///   type     dot separated segments of [A-Za-z0-9_-], e.g.
///            "sap.s4.beh.businesspartner.v1.BusinessPartner.Created.v1"
///   pattern  a type, "*" (everything), or segments where "*" matches
///            exactly one segment — except as the last segment, where it
///            matches one or more remaining segments:
///              "sap.s4.beh.businesspartner.v1.*"   all business partner events
///              "sap.s4.beh.*.v1.*.Created.v1"      every "Created" event of v1 objects
module uim.platform.application_events.domain.services.event_types;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

enum size_t maxEventTypeLength = 256;

private bool validSegment(string s, bool allowWildcard) pure {
  if (allowWildcard && s == "*")
    return true;
  if (s.length == 0)
    return false;
  foreach (c; s)
    if (!((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9') || c == '_' || c == '-'))
      return false;
  return true;
}

bool isValidEventType(string type) pure {
  if (type.length == 0 || type.length > maxEventTypeLength)
    return false;
  return type.split(".").all!(s => validSegment(s, false));
}

bool isValidEventTypePattern(string pattern) pure {
  if (pattern == "*")
    return true;
  if (pattern.length == 0 || pattern.length > maxEventTypeLength)
    return false;
  return pattern.split(".").all!(s => validSegment(s, true));
}

bool hasWildcard(string pattern) pure {
  return pattern.split(".").canFind("*");
}

void requireEventType(string type) {
  if (!isValidEventType(type.strip))
    throw AehException.invalid("Event type '" ~ type ~ "' is invalid (dot separated segments of letters, digits, '_', '-'; "
        ~ "at most 256 characters)");
}

void requireEventTypePattern(string pattern) {
  if (!isValidEventTypePattern(pattern.strip))
    throw AehException.invalid("Event type pattern '" ~ pattern ~ "' is invalid (an event type; '*' matches one segment, "
        ~ "a trailing '*' the rest)");
}

/// True if the event type matches the pattern.
bool matchesEventType(string pattern, string type) pure {
  if (pattern == "*")
    return true;
  auto p = pattern.split(".");
  auto t = type.split(".");
  foreach (i, seg; p) {
    auto last = i + 1 == p.length;
    if (seg == "*" && last)
      return t.length > i;
    if (i >= t.length)
      return false;
    if (seg != "*" && seg != t[i])
      return false;
  }
  return p.length == t.length;
}

///
unittest {
  enum bp = "sap.s4.beh.businesspartner.v1.BusinessPartner.Created.v1";
  assert(isValidEventType(bp) && !isValidEventType("a..b") && !isValidEventType("a.*") && !isValidEventType(""));
  assert(isValidEventTypePattern("sap.s4.*") && isValidEventTypePattern("*") && !isValidEventTypePattern("sap.s4*"));
  assert(matchesEventType(bp, bp) && matchesEventType("*", bp));
  assert(matchesEventType("sap.s4.beh.businesspartner.v1.*", bp));
  assert(matchesEventType("sap.s4.beh.*.v1.*.Created.v1", bp));
  assert(!matchesEventType("sap.s4.beh.*.v1.*.Changed.v1", bp));
  assert(!matchesEventType("sap.s4.beh.businesspartner.v1.BusinessPartner.Created.v1.*", bp), "trailing * needs one more segment");
  assert(!matchesEventType("sap.s4", bp) && !matchesEventType(bp ~ ".x", bp));
  assert(hasWildcard("a.*") && !hasWildcard(bp));
  assert(failsWith(AehErrorKind.invalid, () { requireEventTypePattern("a b"); }));
}
