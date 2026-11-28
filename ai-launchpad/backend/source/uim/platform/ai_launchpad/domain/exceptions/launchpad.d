/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business exceptions. Driving adapters translate the kind into their
/// protocol (HTTP status, OData error, CLI exit code, GUI dialog).
module uim.platform.ai_launchpad.domain.exceptions.launchpad;

import uim.platform.ai_launchpad;

mixin(ShowModule!());

@safe:

/// Category of a failure.
enum AilpErrorKind {
  invalid, /// malformed or incomplete input (400)
  notFound, /// a referenced resource does not exist (404)
  conflict, /// uniqueness conflict (409)
  ruleViolation, /// a business rule forbids the operation (422)
  unauthorized /// missing or wrong credentials (401)
}

class AiLaunchpadException : Exception {
  AilpErrorKind kind;

  this(AilpErrorKind kind, string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
    this.kind = kind;
  }

  static AiLaunchpadException invalid(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new AiLaunchpadException(AilpErrorKind.invalid, msg, file, line);
  }

  static AiLaunchpadException notFound(string what, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new AiLaunchpadException(AilpErrorKind.notFound, what ~ " not found", file, line);
  }

  static AiLaunchpadException conflict(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new AiLaunchpadException(AilpErrorKind.conflict, msg, file, line);
  }

  static AiLaunchpadException ruleViolation(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new AiLaunchpadException(AilpErrorKind.ruleViolation, msg, file, line);
  }

  static AiLaunchpadException unauthorized(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new AiLaunchpadException(AilpErrorKind.unauthorized, msg, file, line);
  }
}

alias AilpException = AiLaunchpadException;

/// True if dg throws an AiLaunchpadException of the kind (test helper).
bool failsWith(AilpErrorKind kind, scope void delegate() @safe dg) {
  try
    dg();
  catch (AiLaunchpadException e)
    return e.kind == kind;
  return false;
}

/// Throw invalid if a required text is empty.
void requireText(string value, string what) {
  if (value.strip.length == 0)
    throw AilpException.invalid(what ~ " is required");
}

/// Throw invalid if a text is longer than max characters.
void requireMaxLength(string value, size_t max, string what) {
  if (value.length > max)
    throw AilpException.invalid(format("%s must not exceed %d characters", what, max));
}

/// Throw invalid if a number is outside [min, max].
void requireRange(long value, long min, long max, string what) {
  if (value < min || value > max)
    throw AilpException.invalid(format("%s must be between %d and %d", what, min, max));
}

/// Throw invalid if a floating point number is outside [min, max].
void requireRangeF(double value, double min, double max, string what) {
  if (!(value >= min && value <= max))
    throw AilpException.invalid(format("%s must be between %g and %g", what, min, max));
}

/// Throw invalid unless the text is empty or an http(s) URL.
void requireUrl(string value, string what, bool required = false) {
  auto v = value.strip;
  if (v.length == 0) {
    if (required)
      throw AilpException.invalid(what ~ " is required");
    return;
  }
  if (!(v.startsWith("https://") || v.startsWith("http://")) || v.canFind(' ') || v.length < 10)
    throw AilpException.invalid(what ~ " '" ~ value ~ "' is not an http(s) URL");
  requireMaxLength(v, 2048, what);
}

///
unittest {
  assert(failsWith(AilpErrorKind.notFound, () { throw AilpException.notFound("Connection 'x'"); }));
  assert(!failsWith(AilpErrorKind.conflict, () {}));
  assert(failsWith(AilpErrorKind.invalid, () { requireText(" ", "Name"); }));
  assert(failsWith(AilpErrorKind.invalid, () { requireMaxLength("abc", 2, "Name"); }));
  assert(failsWith(AilpErrorKind.invalid, () { requireRange(0, 1, 10, "Replicas"); }));
  assert(failsWith(AilpErrorKind.invalid, () { requireRangeF(2.5, 0, 2, "Temperature"); }));
  assert(failsWith(AilpErrorKind.invalid, () { requireUrl("ftp://x.example", "URL"); }));
  assert(failsWith(AilpErrorKind.invalid, () { requireUrl("", "URL", true); }));
  requireUrl("https://api.ai.example.com/v2", "URL");
  requireUrl("", "URL");
}
