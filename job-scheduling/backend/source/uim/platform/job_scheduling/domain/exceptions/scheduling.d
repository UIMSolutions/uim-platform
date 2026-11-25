/****************************************************************************************************************
* Copyright: © 2018-2026 Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
* License: Subject to the terms of the Apache 2.0 license, as written in the included LICENSE.txt file.
* Authors: Ozan Nurettin Süel (aka UI-Manufaktur UG *R.I.P*)
*****************************************************************************************************************/
/// Business exceptions. Driving adapters translate the kind into their
/// protocol (HTTP status, OData error, CLI exit code, GUI dialog).
module uim.platform.job_scheduling.domain.exceptions.scheduling;

import uim.platform.job_scheduling;

mixin(ShowModule!());

@safe:

/// Category of a failure.
enum JsErrorKind {
  invalid, /// malformed or incomplete input (400)
  notFound, /// a referenced resource does not exist (404)
  conflict, /// uniqueness conflict (409)
  ruleViolation, /// a business rule forbids the operation (422)
  unauthorized /// missing or wrong credentials (401)
}

class JobSchedulingException : Exception {
  JsErrorKind kind;

  this(JsErrorKind kind, string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    super(msg, file, line);
    this.kind = kind;
  }

  static JobSchedulingException invalid(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new JobSchedulingException(JsErrorKind.invalid, msg, file, line);
  }

  static JobSchedulingException notFound(string what, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new JobSchedulingException(JsErrorKind.notFound, what ~ " not found", file, line);
  }

  static JobSchedulingException conflict(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new JobSchedulingException(JsErrorKind.conflict, msg, file, line);
  }

  static JobSchedulingException ruleViolation(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new JobSchedulingException(JsErrorKind.ruleViolation, msg, file, line);
  }

  static JobSchedulingException unauthorized(string msg, string file = __FILE__, size_t line = __LINE__) pure nothrow {
    return new JobSchedulingException(JsErrorKind.unauthorized, msg, file, line);
  }
}

/// True if dg throws a JobSchedulingException of the kind (test helper).
bool failsWith(JsErrorKind kind, scope void delegate() @safe dg) {
  try
    dg();
  catch (JobSchedulingException e)
    return e.kind == kind;
  return false;
}

/// Throw invalid if a required text is empty.
void requireText(string value, string what) {
  if (value.strip.length == 0)
    throw JobSchedulingException.invalid(what ~ " is required");
}

/// Throw invalid if a text is longer than max characters.
void requireMaxLength(string value, size_t max, string what) {
  if (value.length > max)
    throw JobSchedulingException.invalid(format("%s must not exceed %d characters", what, max));
}

/// Throw invalid if a number is outside [min, max].
void requireRange(long value, long min, long max, string what) {
  if (value < min || value > max)
    throw JobSchedulingException.invalid(format("%s must be between %d and %d", what, min, max));
}

///
unittest {
  assert(failsWith(JsErrorKind.notFound, () { throw JobSchedulingException.notFound("Job 'x'"); }));
  assert(!failsWith(JsErrorKind.conflict, () {}));
  assert(failsWith(JsErrorKind.invalid, () { requireText(" ", "Name"); }));
  assert(failsWith(JsErrorKind.invalid, () { requireMaxLength("abc", 2, "Name"); }));
  assert(failsWith(JsErrorKind.invalid, () { requireRange(101, 0, 100, "Retries"); }));
}
