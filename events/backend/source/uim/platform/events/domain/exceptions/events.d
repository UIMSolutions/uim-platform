/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business exceptions. Driving adapters translate the kind into their
/// protocol (HTTP status, CLI exit code, GUI dialog).
module uim.platform.events.domain.exceptions.events;

import uim.platform.events;

mixin(ShowModule!());

@safe:

/// Category of a business failure.
enum EventsErrorKind {
  invalid, /// malformed or incomplete input
  notFound, /// a referenced resource does not exist
  conflict, /// uniqueness conflict
  ruleViolation, /// a business rule forbids the operation
  quotaExceeded, /// a plan / queue limit is reached
  gateway /// a webhook endpoint failed
}

class EventsException : Exception {
  EventsErrorKind kind;

  this(EventsErrorKind kind, string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
    this.kind = kind;
  }

  static EventsException invalid(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new EventsException(EventsErrorKind.invalid, msg, file, line);
  }

  static EventsException notFound(string what, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new EventsException(EventsErrorKind.notFound, what ~ " not found", file, line);
  }

  static EventsException conflict(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new EventsException(EventsErrorKind.conflict, msg, file, line);
  }

  static EventsException ruleViolation(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new EventsException(EventsErrorKind.ruleViolation, msg, file, line);
  }

  static EventsException quotaExceeded(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new EventsException(EventsErrorKind.quotaExceeded, msg, file, line);
  }

  static EventsException gateway(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new EventsException(EventsErrorKind.gateway, msg, file, line);
  }
}

/// True if dg throws an EventsException of the kind (test helper).
bool failsWith(EventsErrorKind kind, scope void delegate() @safe dg) {
  try
    dg();
  catch (EventsException e)
    return e.kind == kind;
  return false;
}

/// Throw invalid if a required text is empty.
void requireText(string value, string what) {
  if (value.strip.length == 0)
    throw EventsException.invalid(what ~ " is required");
}

/// Throw invalid if a number is negative.
void requireNonNegative(long value, string what) {
  if (value < 0)
    throw EventsException.invalid(what ~ " must not be negative");
}

/// True for http:// and https:// URLs with a host.
bool isHttpUrl(string url) pure {
  foreach (scheme; ["http://", "https://"])
    if (url.startsWith(scheme) && url.length > scheme.length && url[scheme.length] != '/')
      return true;
  return false;
}

///
unittest {
  assert(failsWith(EventsErrorKind.notFound, () { throw EventsException.notFound("Queue 'x'"); }));
  assert(!failsWith(EventsErrorKind.conflict, () {}));
  assert(failsWith(EventsErrorKind.invalid, () { requireText(" ", "Name"); }));
  assert(isHttpUrl("https://hooks.example.com/x") && !isHttpUrl("ftp://x") && !isHttpUrl("http:///x"));
}
