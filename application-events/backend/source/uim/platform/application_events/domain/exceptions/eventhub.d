/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business exceptions. Driving adapters translate the kind into their
/// protocol (HTTP status, OData error, CLI exit code, GUI dialog).
module uim.platform.application_events.domain.exceptions.eventhub;

import uim.platform.application_events;

mixin(ShowModule!());

@safe:

/// Category of a failure.
enum AehErrorKind {
  invalid, /// malformed or incomplete input (400)
  notFound, /// a referenced resource does not exist (404)
  conflict, /// uniqueness conflict (409)
  ruleViolation, /// a business rule forbids the operation (422)
  unauthorized /// missing or wrong credentials (401)
}

class EventHubException : Exception {
  AehErrorKind kind;

  this(AehErrorKind kind, string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
    this.kind = kind;
  }

  static EventHubException invalid(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new EventHubException(AehErrorKind.invalid, msg, file, line);
  }

  static EventHubException notFound(string what, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new EventHubException(AehErrorKind.notFound, what ~ " not found", file, line);
  }

  static EventHubException conflict(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new EventHubException(AehErrorKind.conflict, msg, file, line);
  }

  static EventHubException ruleViolation(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new EventHubException(AehErrorKind.ruleViolation, msg, file, line);
  }

  static EventHubException unauthorized(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new EventHubException(AehErrorKind.unauthorized, msg, file, line);
  }
}

alias AehException = EventHubException;

/// True if dg throws an EventHubException of the kind (test helper).
bool failsWith(AehErrorKind kind, scope void delegate() @safe dg) {
  try
    dg();
  catch (EventHubException e)
    return e.kind == kind;
  return false;
}

/// Throw invalid if a required text is empty.
void requireText(string value, string what) {
  if (value.strip.length == 0)
    throw AehException.invalid(what ~ " is required");
}

/// Throw invalid if a text is longer than max characters.
void requireMaxLength(string value, size_t max, string what) {
  if (value.length > max)
    throw AehException.invalid(format("%s must not exceed %d characters", what, max));
}

/// Throw invalid if a number is outside [min, max].
void requireRange(long value, long min, long max, string what) {
  if (value < min || value > max)
    throw AehException.invalid(format("%s must be between %d and %d", what, min, max));
}

/// Throw invalid unless the text is empty or an http(s) URL.
void requireHttpUrl(string value, string what, bool required = false) {
  auto v = value.strip;
  if (v.length == 0) {
    if (required)
      throw AehException.invalid(what ~ " is required");
    return;
  }
  auto ok = (v.startsWith("https://") && v.length > 8) || (v.startsWith("http://") && v.length > 7);
  if (!ok || v.canFind(' '))
    throw AehException.invalid(what ~ " '" ~ value ~ "' is not an http(s) URL");
  requireMaxLength(v, 2000, what);
}

///
unittest {
  assert(failsWith(AehErrorKind.notFound, () { throw AehException.notFound("System 'x'"); }));
  assert(!failsWith(AehErrorKind.conflict, () {}));
  assert(failsWith(AehErrorKind.invalid, () { requireText(" ", "Name"); }));
  assert(failsWith(AehErrorKind.invalid, () { requireMaxLength("abc", 2, "Name"); }));
  assert(failsWith(AehErrorKind.invalid, () { requireRange(0, 1, 10, "Retries"); }));
  assert(failsWith(AehErrorKind.invalid, () { requireHttpUrl("ftp://x", "Endpoint"); }));
  assert(failsWith(AehErrorKind.invalid, () { requireHttpUrl("", "Endpoint", true); }));
  requireHttpUrl("https://crm.example.com/events", "Endpoint");
  requireHttpUrl("", "Endpoint");
}
