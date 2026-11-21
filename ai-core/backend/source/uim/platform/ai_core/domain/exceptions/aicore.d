/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business exceptions. Driving adapters translate the kind into their
/// protocol (HTTP status, OData error, CLI exit code, GUI dialog).
module uim.platform.ai_core.domain.exceptions.aicore;

import uim.platform.ai_core;

mixin(ShowModule!());

@safe:

/// Category of a failure.
enum AiCoreErrorKind {
  invalid, /// malformed or incomplete input (400)
  notFound, /// a referenced resource does not exist (404)
  conflict, /// uniqueness conflict (409)
  ruleViolation /// a business rule forbids the operation (412 in the AI API, 422 in OData)
}

class AiCoreException : Exception {
  AiCoreErrorKind kind;

  this(AiCoreErrorKind kind, string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
    this.kind = kind;
  }

  static AiCoreException invalid(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new AiCoreException(AiCoreErrorKind.invalid, msg, file, line);
  }

  static AiCoreException notFound(string what, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new AiCoreException(AiCoreErrorKind.notFound, what ~ " not found", file, line);
  }

  static AiCoreException conflict(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new AiCoreException(AiCoreErrorKind.conflict, msg, file, line);
  }

  static AiCoreException ruleViolation(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new AiCoreException(AiCoreErrorKind.ruleViolation, msg, file, line);
  }
}

/// True if dg throws an AiCoreException of the kind (test helper).
bool failsWith(AiCoreErrorKind kind, scope void delegate() @safe dg) {
  try
    dg();
  catch (AiCoreException e)
    return e.kind == kind;
  return false;
}

/// Throw invalid if a required text is empty.
void requireText(string value, string what) {
  if (value.strip.length == 0)
    throw AiCoreException.invalid(what ~ " is required");
}

/// Throw invalid if a text is longer than max characters.
void requireMaxLength(string value, size_t max, string what) {
  if (value.length > max)
    throw AiCoreException.invalid(format("%s must not exceed %d characters", what, max));
}

/// Throw invalid if a number is outside [min, max].
void requireRange(long value, long min, long max, string what) {
  if (value < min || value > max)
    throw AiCoreException.invalid(format("%s must be between %d and %d", what, min, max));
}

///
unittest {
  assert(failsWith(AiCoreErrorKind.notFound, () { throw AiCoreException.notFound("Scenario 'x'"); }));
  assert(!failsWith(AiCoreErrorKind.conflict, () {}));
  assert(failsWith(AiCoreErrorKind.invalid, () { requireText(" ", "Name"); }));
  assert(failsWith(AiCoreErrorKind.invalid, () { requireMaxLength("abc", 2, "Name"); }));
  assert(failsWith(AiCoreErrorKind.invalid, () { requireRange(0, 1, 10, "ttl"); }));
}
